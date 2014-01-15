add_subdirectory(ast)
add_subdirectory(parser)

cc_library(app app.h app.cc)
link(app tools.buildifier.ast.ast tools.buildifier.parser.parser
     tools.buildifier.parser.processor)

cc_test(app_test app_test.cc)
link_local(app_test app)
link(app_test third_party.gflags third_party.gtest util.logging)
add_local_data(app_test testdata)

cc_binary(buildifier main.cc)
link_local(buildifier app)
link(buildifier third_party.boost_filesystem third_party.gflags util.logging)
