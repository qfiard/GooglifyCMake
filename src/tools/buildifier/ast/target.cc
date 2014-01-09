#include "tools/buildifier/ast/target.h"

namespace tools {
namespace buildifier {
namespace ast {

Target::Target(const std::string &name) : name_(name) {}

void Target::AddCommand(Command *command) { commands_.emplace(command); }

void Target::SaveToStream(std::ostream *stream) const {
  for (const auto &command : commands_) {
    command->SaveToStream(stream);
  }
}

}  // namespace ast
}  // namespace buildifier
}  // namespace tools
