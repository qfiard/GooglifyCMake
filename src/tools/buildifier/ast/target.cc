#include "tools/buildifier/ast/target.h"

#include <list>
#include <set>

namespace tools {
namespace buildifier {
namespace ast {

Target::Target(const std::string &name) : name_(name) {}

void Target::AddCommand(Command *command) { commands_.emplace(command); }

void Target::Normalize() {
  std::set<std::string> link_args, link_local_args;
  auto it = commands_.begin();
  while (it != commands_.end()) {
    const auto &command = *it;
    if (command->GetType() == Command::kLink) {
      // First argument is the target name.
      link_args.insert(command->args().begin() + 1, command->args().end());
      it = commands_.erase(it);
    } else if (command->GetType() == Command::kLinkLocal) {
      // First argument is the target name.
      link_local_args.insert(command->args().begin() + 1,
                             command->args().end());
      it = commands_.erase(it);
    } else {
      ++it;
    }
  }
  if (!link_args.empty()) {
    std::list<std::string> args(link_args.begin(), link_args.end());
    args.push_front(name_);
    commands_.emplace(new Command("link", args.begin(), args.end()));
  }
  if (!link_local_args.empty()) {
    std::list<std::string> args(link_local_args.begin(), link_local_args.end());
    args.push_front(name_);
    commands_.emplace(new Command("link_local", args.begin(),
                                  args.end()));
  }
}

void Target::SaveToStream(std::ostream *stream) const {
  for (const auto &command : commands_) {
    command->SaveToStream(stream);
  }
}

}  // namespace ast
}  // namespace buildifier
}  // namespace tools
