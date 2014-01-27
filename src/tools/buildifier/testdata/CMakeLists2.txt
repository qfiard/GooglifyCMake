bison_generate_parser(parser.y PARSER_SRC PARSER_HDR)
flex_generate_scanner(lexer.l LEXER_SRC LEXER_HDR)

cc_library(parser scanner.h scanner.cc ${PARSER_SRC} ${PARSER_HDR} ${LEXER_SRC}
           ${LEXER_SRC})
link(parser :processor base.base third_party.boost_filesystem
     third_party.boost_headers util.logging)

cc_test(parser_test parser_test.cc)
link(parser_test :parser third_party.gmock third_party.gtest)

cc_library(processor processor.h)
link(processor base.base)
