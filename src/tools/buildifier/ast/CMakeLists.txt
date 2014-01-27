cc_library(ast ast.h ast.cc)
link(ast :command :target base.base tools.buildifier.parser.processor
     util.algorithm)

cc_library(command command.h command.cc)
link(command util.dev.config)

cc_library(target target.h target.cc)
link(target :command base.base)
