#include "tools/buildifier/ast/ast.h"

#include <fstream>
#include <iostream>
#include "tools/buildifier/ast/command.h"

namespace tools {
namespace buildifier {
namespace ast {

bool AST::AddCommand(const std::string &command,
                     const std::vector<std::string> &args) {
  Command::Type type = Command::GetTypeForCommandName(command);
  if (type >= Command::Type::kNonTargetCommand) {
    non_target_commands_.emplace(
        new Command(command, args.begin(), args.end()));
    return true;
  }
  // The command is expected to be associated with a target.
  if (args.size() == 0) {
    std::cerr << "Command " << command << " has no target." << std::endl;
    return false;
  }
  std::string target_name = args[0];
  if (!targets_[target_name]) {
    targets_[target_name].reset(new Target(target_name));
  }
  Target &target = *targets_[target_name];
  target.AddCommand(new Command(command, args.begin(), args.end()));
  return true;
}

void AST::SaveToBuildFile(const std::string build_file_path) const {
  std::ofstream build_file(build_file_path);
  bool first = true;
  Command::Type last_command_type;
  for (const auto &command : non_target_commands_) {
    Command::Type command_type = command->GetType();
    if (!first && command_type != last_command_type) build_file << "\n";
    first = false;
    last_command_type = command_type;
    command->SaveToStream(&build_file);
  }
  for (const auto &target : targets_) {
    if (!first) build_file << "\n";
    first = false;
    target.second->SaveToStream(&build_file);
  }
}

}  // namespace ast
}  // namespace buildifier
}  // namespace tools
