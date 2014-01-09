bison_generate_parser(parser.y PARSER_SRC PARSER_HDR)
flex_generate_scanner(lexer.l LEXER_SRC LEXER_HDR)

cc_library(
    parser scanner.h scanner.cc ${PARSER_SRC} ${PARSER_HDR} ${LEXER_SRC}
    ${LEXER_SRC})
link_local(parser processor)
link(parser base.base)
link(parser third_party.boost_filesystem)
link(parser third_party.boost_headers)
link(parser util.logging)

cc_test(parser_test parser_test.cc)
link_local(parser_test parser)
link(parser_test third_party.gmock)
link(parser_test third_party.gtest)

cc_library(processor processor.h)
link(processor base.base)
