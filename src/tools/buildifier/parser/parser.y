// Request C++ parser.
%skeleton "lalr1.cc"
%require  "3.0"
%debug
%define api.namespace {tools::buildifier::parser}
%define parser_class_name {Parser}
%error-verbose

%code requires{
#include <functional>
namespace tools {
namespace buildifier {
namespace parser {
class Processor;
class Scanner;
typedef std::function<void()> Callback;
}  // namespace parser
}  // namespace buildifier
}  // namespace tools
}

%lex-param { Scanner *scanner  }
%parse-param { Scanner *scanner  }
%lex-param { Processor *processor  }
%parse-param { Processor *processor  }

%code{
#ifndef TOOLS_BUILDIFIER_PARSER_PARSER_H_
#define TOOLS_BUILDIFIER_PARSER_PARSER_H_

#include <iostream>
#include <cstdlib>
#include <fstream>
#include <string>
#include <vector>
#include "boost/algorithm/hex.hpp"
#include "boost/filesystem.hpp"
#include "tools/buildifier/parser/processor.h"
#include "util/logging.h"


static int yylex(
  tools::buildifier::parser::Parser::semantic_type *yylval,
  tools::buildifier::parser::Scanner *scanner,
  tools::buildifier::parser::Processor *processor);
}

%union {
  std::string *string_value;
  std::vector<std::string> *string_vector_value;
}

%destructor { if($$) { delete $$; $$ = NULL; } } <string_value>
%destructor { if($$) { delete $$; $$ = NULL; } } <string_vector_value>

%token LPAREN RPAREN NEWLINE DOLLAR IF LBRACKET RBRACKET SPACE
%token <string_value> STRING
%type <string_value> command argument cmake_var cmake_var_name
%type <string_vector_value> arguments stripped_arguments

%start build_rules

%%

build_rules:
    separator_or_empty
  | build_rule build_rules
;

build_rule: separator_or_empty command LPAREN arguments RPAREN {
  processor->AddCommand(*$2, *$4);
}
;

command: STRING { $$ = $1; };

argument:
    STRING { $$ = $1; }
  | cmake_var { $$ = $1; }
  | STRING argument { $$ = new std::string(*$1 + *$2); }
  | cmake_var argument { $$ = new std::string(*$1 + *$2); }
;

cmake_var: DOLLAR LBRACKET cmake_var_name RBRACKET {
  *$3 = "${" + *$3 + "}"; $$ = $3;
};

cmake_var_name:
    STRING { $$ = $1; }
  | cmake_var { $$ = $1; }
;

arguments:
    separator_or_empty { $$ = new std::vector<std::string>(); }
  | separator_or_empty stripped_arguments separator_or_empty { $$ = $2; };

stripped_arguments:
    argument { $$ = new std::vector<std::string>(1, *$1); }
  | stripped_arguments separator argument  { $1->push_back(*$3); $$ = $1; }
;

separator_or_empty:
    %empty
  | separator
;

separator:
    SPACE
  | NEWLINE
  | separator NEWLINE
  | separator SPACE
;

%%

void tools::buildifier::parser::Parser::error(
    const std::string &err_message) {
  std::cerr << "Error: " << err_message << std::endl;
}

#include "tools/buildifier/parser/scanner.h"
static int yylex(
    tools::buildifier::parser::Parser::semantic_type *yylval,
    tools::buildifier::parser::Scanner *scanner,
    tools::buildifier::parser::Processor *processor) {
  return scanner->yylex(yylval);
}

#endif  // TOOLS_BUILDIFIER_PARSER_PARSER_H_
