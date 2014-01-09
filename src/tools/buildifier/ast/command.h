#ifndef TOOLS_BUILDIFIER_AST_COMMAND_H_
#define TOOLS_BUILDIFIER_AST_COMMAND_H_

#include <ostream>
#include <string>
#include <unordered_set>
#include <vector>

namespace tools {
namespace buildifier {
namespace ast {

class Command;
bool operator<(const Command &c1, const Command &c2);

class Command {
 public:
  enum Type {
    kCreateTarget = 0,
    kLink = 2,
    kLinkLocal = 1,
    kOther = 3,
    kNonTargetCommand = 1000,
    kSetGlobalProperty = 1001,
    kAddSubdirectory = 1002,
    kGenerateFiles = 1003,
  };
  template <class StringIterator>
  Command(const std::string &name, const StringIterator &args_begin,
          const StringIterator &args_end);
  Type GetType() const;
  static Type GetTypeForCommandName(const std::string &command_name);
  void SaveToStream(std::ostream *stream) const;

 private:
  void WrapToCharactersLimit(std::ostream *output) const;
  void WrapToCharactersLimitAtParen(std::ostream *output) const;
  void WrapToCharactersLimitOnNewLine(std::ostream *output) const;
  friend bool operator<(const Command &c1, const Command &c2);
  static std::unordered_set<std::string> create_target_commands_,
      link_commands_, link_local_commands_, generate_files_commands_;
  std::vector<std::string> args_;
  std::string name_;
};

template <class StringIterator>
Command::Command(const std::string &name, const StringIterator &args_begin,
                 const StringIterator &args_end)
    : name_(name), args_(args_begin, args_end) {}

}  // namespace ast
}  // namespace buildifier
}  // namespace tools

#endif  // TOOLS_BUILDIFIER_AST_COMMAND_H_
