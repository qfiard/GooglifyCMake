#include "tools/buildifier/ast/command.h"

#include <algorithm>
#include <iostream>
#include <ostream>
#include <sstream>
#include <string>
#include <unordered_set>
#include <vector>
#include "util/dev/config.h"

namespace tools {
namespace buildifier {
namespace ast {

using util::dev::config::kContinuationIndentLength;
using util::dev::config::kMaxLineLength;

std::unordered_set<std::string> Command::create_target_commands_(
    {"cc_binary", "cc_library", "cc_test", "j2e_binary", "java_binary",
     "java_library", "mysql_udf_cc_library", "py_binary", "py_library",
     "r_binary"}),
    Command::generate_files_commands_({"bison_generate_parser",
                                       "flex_generate_scanner",
                                       "protobuf_generate_cc",
                                       "protobuf_generate_java",
                                       "protobuf_generate_py"}),
    Command::link_commands_({"link"}),
    Command::link_local_commands_({"link_local"});

Command::Type Command::GetType() const { return GetTypeForCommandName(name_); }

Command::Type Command::GetTypeForCommandName(const std::string &command_name) {
  if (command_name == "add_subdirectory") return kAddSubdirectory;
  if (command_name == "set") return kSetGlobalProperty;
  if (create_target_commands_.find(command_name) !=
      create_target_commands_.end())
    return kCreateTarget;
  if (generate_files_commands_.find(command_name) !=
      generate_files_commands_.end())
    return kGenerateFiles;
  if (link_commands_.find(command_name) != link_commands_.end()) return kLink;
  if (link_local_commands_.find(command_name) != link_local_commands_.end())
    return kLinkLocal;
  return kOther;
}

void Command::SaveToStream(std::ostream *stream) const {
  WrapToCharactersLimit(stream);
}

void Command::WrapToCharactersLimit(std::ostream *stream) const {
  {
    // Check if we could avoid wrapping completely.
    std::stringstream line_stream;
    line_stream << name_ << "(";
    bool first = true;
    for (const std::string &arg : args_) {
      if (!first) line_stream << " ";
      first = false;
      line_stream << arg;
    }
    line_stream << ")";
    if (line_stream.str().size() <= kMaxLineLength) {
      *stream << line_stream.str() << "\n";
      return;
    }
  }
  // The command does not fit on one line at this point.

  // Two possibilities:
  // 1. Wrap at the parenthesis.
  // 2. Indent on a new line and wrap.
  std::stringstream wrapped_at_paren, wrapped_on_newline;
  WrapToCharactersLimitAtParen(&wrapped_at_paren);
  WrapToCharactersLimitOnNewLine(&wrapped_on_newline);
  const std::string &wrapped_at_paren_str = wrapped_at_paren.str();
  const std::string &wrapped_on_newline_str = wrapped_on_newline.str();
  // Check if content wrapped at parenthesis is valid.
  {
    std::string tmp_line;
    while (std::getline(wrapped_at_paren, tmp_line)) {
      if (tmp_line.size() > kMaxLineLength) {
        *stream << wrapped_on_newline_str;
        return;
      }
    }
  }
  // Wrapped at parenthesis is valid, in this case we return the content that
  // has the minimum number of newlines, with a preference for newline wrapping
  // if they have the same number of newlines (ASCII art issue).
  if (std::count(wrapped_at_paren_str.begin(), wrapped_at_paren_str.end(),
                 '\n') < std::count(wrapped_on_newline_str.begin(),
                                    wrapped_on_newline_str.end(), '\n')) {
    *stream << wrapped_at_paren_str;
    return;
  }
  *stream << wrapped_on_newline_str;
}

void Command::WrapToCharactersLimitAtParen(std::ostream *stream) const {
  std::size_t indent_size = name_.size() + 1;
  *stream << name_ << "(";
  std::string indent(indent_size, ' ');
  std::size_t current_line_length = indent_size;
  for (std::size_t i = 0; i < args_.size(); ++i) {
    if (current_line_length == indent_size) {
      // First on line, no choice but to write it.
      *stream << args_[i];
      current_line_length += args_[i].size();
    } else if (i == args_.size() - 1 &&
               current_line_length + args_[i].size() + 2 > kMaxLineLength) {
      // Add a new line and write the argument at the correct indentation.
      *stream << "\n" << indent << args_[i];
      current_line_length = indent_size + args_[i].size();
    } else if (current_line_length + args_[i].size() + 1 > kMaxLineLength) {
      // Add a new line and write the argument at the correct indentation.
      *stream << "\n" << indent << args_[i];
      current_line_length = indent_size + args_[i].size();
    } else {
      *stream << " " << args_[i];
      current_line_length += args_[i].size() + 1;
    }
  }
  *stream << ")\n";
}

void Command::WrapToCharactersLimitOnNewLine(std::ostream *stream) const {
  *stream << name_ << "(";
  std::string indent(kContinuationIndentLength, ' ');
  std::size_t current_line_length;
  for (std::size_t i = 0; i < args_.size(); ++i) {
    if (i == 0) {
      *stream << "\n" << indent << args_[i];
      current_line_length = kContinuationIndentLength + args_[i].size();
    } else if (i == args_.size() - 1 &&
               current_line_length + args_[i].size() + 2 > kMaxLineLength) {
      *stream << "\n" << indent << args_[i];
      current_line_length = kContinuationIndentLength + args_[i].size();
    } else if (current_line_length + args_[i].size() + 1 > kMaxLineLength) {
      *stream << "\n" << indent << args_[i];
      current_line_length = kContinuationIndentLength + args_[i].size();
    } else {
      *stream << " " << args_[i];
      current_line_length += args_[i].size() + 1;
    }
  }
  *stream << ")\n";
}

const std::vector<std::string> &Command::args() const { return args_; }

bool operator<(const Command &c1, const Command &c2) {
  Command::Type type1 = c1.GetType(), type2 = c2.GetType();
  if (type1 != type2) return type1 < type2;
  int compare_names = c1.name_.compare(c2.name_);
  if (compare_names != 0) return compare_names < 0;
  for (std::size_t i = 0, j = 0; i < c1.args_.size() && j < c2.args_.size();
       ++i, ++j) {
    int compare_ij = c1.args_[i].compare(c2.args_[j]);
    if (compare_ij != 0) return compare_ij < 0;
  }
  return false;
}

}  // namespace ast
}  // namespace buildifier
}  // namespace tools
