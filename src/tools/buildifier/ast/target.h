#ifndef TOOLS_BUILDIFIER_AST_TARGET_H_
#define TOOLS_BUILDIFIER_AST_TARGET_H_

#include <memory>
#include <ostream>
#include <set>
#include <string>
#include <vector>
#include "base/base.h"
#include "tools/buildifier/ast/command.h"
#include "util/algorithm.h"

namespace tools {
namespace buildifier {
namespace ast {

class Target {
 public:
  Target(const std::string &name);
  void AddCommand(Command *command);
  void Normalize();
  void SaveToStream(std::ostream *stream) const;

 private:
  std::string name_;
  std::multiset<std::unique_ptr<Command>,
                util::algorithm::PointerComparator<Command> > commands_;

  DISALLOW_COPY_AND_ASSIGN(Target);
};

}  // namespace ast
}  // namespace buildifier
}  // namespace tools

#endif  // TOOLS_BUILDIFIER_AST_TARGET_H_
