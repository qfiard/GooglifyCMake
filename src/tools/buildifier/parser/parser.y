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

%token LPAREN RPAREN NEWLINE DOLLAR LBRACKET RBRACKET
%token <string_value> STRING
%type <string_value> command argument cmake_var cmake_var_name
%type <string_vector_value> arguments stripped_arguments

%start build_rules

%%

build_rules:
    %empty
  | build_rule
  | build_rule new_line_plus build_rules
;

build_rule: command LPAREN arguments RPAREN { processor->AddCommand(*$1, *$3); }
;

command: STRING { $$ = $1; };

argument:
    STRING { $$ = $1; }
  | cmake_var { $$ = $1; }
;

cmake_var: DOLLAR LBRACKET cmake_var_name RBRACKET {
  *$3 = "${" + *$3 + "}"; $$ = $3;
};

cmake_var_name:
    STRING { $$ = $1; }
  | cmake_var { $$ = $1; }
;

arguments:
    %empty { $$ = new std::vector<std::string>(); }
  | new_line_star stripped_arguments new_line_star { $$ = $2; };

stripped_arguments:
    argument { $$ = new std::vector<std::string>(1, *$1); }
  | stripped_arguments new_line_star argument  { $1->push_back(*$3); $$ = $1; }
;

new_line_star:
    %empty
  | new_line_star NEWLINE
;

new_line_plus:
    NEWLINE
  | new_line_plus NEWLINE
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
