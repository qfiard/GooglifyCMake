%{
#include <iostream>
#include "tools/buildifier/parser/scanner.h"
#include "tools/buildifier/parser/parser.h"

/* typedef to make the returns for the tokens shorter */
typedef tools::buildifier::parser::Parser::token token;

/* define yyterminate as this instead of NULL */
// #define yyterminate() return( token::END )

%}

%option debug
%option nodefault
%option yyclass="tools::buildifier::parser::Scanner"
%option noyywrap
%option c++

NAME [a-zA-Z0-9_\./\-:\+]+
QUOTED_STRING "\""(?:[^"\""\\]|\\.)*"\""

%%
\( { return token::LPAREN; }
\) { return token::RPAREN; }
\n { return token::NEWLINE; }
\$ { return token::DOLLAR; }
\{ { return token::LBRACKET; }
\} { return token::RBRACKET; }
[ \t]+ { return token::SPACE; }
{NAME} { yylval->string_value = new std::string(yytext); return token::STRING; }
{QUOTED_STRING} { yylval->string_value = new std::string(yytext); return token::STRING; }
. { std::cerr << "Unknown token '" << yytext << "'\n"; return 1; }
%%
