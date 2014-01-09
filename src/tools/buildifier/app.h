#ifndef TOOLS_BUILDIFIER_APP_H_
#define TOOLS_BUILDIFIER_APP_H_

#include "base/base.h"
#include "tools/buildifier/ast/ast.h"

namespace tools {
namespace buildifier {

class App {
 public:
  App(const std::string &build_file_path);
  int Run();

 private:
  ast::AST ast_;
  std::string build_file_path_;
  DISALLOW_COPY_AND_ASSIGN(App);
};

}  // namespace buildifier
}  // namespace tools

#endif  // TOOLS_BUILDIFIER_APP_H_
