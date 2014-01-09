#include "tools/buildifier/parser/scanner.h"

namespace tools {
namespace buildifier {
namespace parser {

Scanner::Scanner(std::istream *in) : yyFlexLexer(in), yylval(NULL) {}

int Scanner::yylex(Parser::semantic_type *lval) {
  yylval = lval;
  return yylex();
}

}  // namespace parser
}  // namespace buildifier
}  // namespace tools
