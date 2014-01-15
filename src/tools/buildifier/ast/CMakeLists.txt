cc_library(ast ast.h ast.cc)
link_local(ast command target)
link(ast base.base tools.buildifier.parser.processor util.algorithm)

cc_library(command command.h command.cc)
link(command util.dev.config)

cc_library(target target.h target.cc)
link_local(target command)
link(target base.base)
