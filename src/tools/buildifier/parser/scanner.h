#ifndef UTIL_CONFIG_EDITOR_SCANNER_H_
#define UTIL_CONFIG_EDITOR_SCANNER_H_

#if !defined(yyFlexLexerOnce)
#include "FlexLexer.h"
#endif

#include <iostream>
#include "base/base.h"
#include "tools/buildifier/parser/parser.h"

#undef YY_DECL
#define YY_DECL int tools::buildifier::parser::Scanner::yylex()

namespace tools {
namespace buildifier {
namespace parser {

class Scanner : public yyFlexLexer {
 public:
  explicit Scanner(std::istream *in);
  int yylex(Parser::semantic_type *lval);

 private:
  int yylex();
  Parser::semantic_type *yylval;

  DISALLOW_COPY_AND_ASSIGN(Scanner);
};

}  // namespace parser
}  // namespace buildifier
}  // namespace tools

#endif  // UTIL_CONFIG_EDITOR_SCANNER_H_
