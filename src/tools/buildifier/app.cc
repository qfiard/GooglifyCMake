#include "tools/buildifier/app.h"

#include <fstream>
#include "tools/buildifier/parser/parser.h"
#include "tools/buildifier/parser/scanner.h"

namespace tools {
namespace buildifier {

using parser::Parser;
using parser::Scanner;

App::App(const std::string &build_file_path)
    : build_file_path_(build_file_path) {}

int App::Run() {
  std::ifstream build_file(build_file_path_);
  Scanner scanner(&build_file);
  Parser parser(&scanner, &ast_);
  int parse_result = parser.parse();
  if (parse_result != 0) {
    std::cout << "Build file parsing failed." << std::endl;
    return parse_result;
  }
  ast_.Normalize();
  ast_.SaveToBuildFile(build_file_path_);
  return 0;
}

}  // namespace buildifier
}  // namespace tools
