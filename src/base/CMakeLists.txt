cc_library(base base.h)

cc_library(signal_handler signal_handler.h signal_handler.cc)
link(signal_handler :base)
