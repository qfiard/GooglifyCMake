cc_binary(cc_exe main.cc)
link_local(cc_exe my_lib)
link(cc_exe examples.other_package.my_lib)

cc_library(my_lib my_lib.h my_lib.cc)

java_binary(java_exe Main.java)
link_local(java_exe my_lib_java)
link(java_exe examples.other_package.my_lib_java)

java_library(my_lib_java MyLib.java)
