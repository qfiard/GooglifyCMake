cc_binary(cc_exe main.cc)
link_local(cc_exe my_lib)
link(cc_exe examples.other_package.my_lib)

py_binary(hello_world_py hello_world.py)
link_local(hello_world_py my_lib_py)

r_binary(hello_world_r hello_world.R)

java_binary(java_exe Main.java)
link_local(java_exe my_lib_java)
link(java_exe examples.other_package.my_lib_java)

cc_library(my_lib my_lib.h my_lib.cc)
py_library(my_lib_py my_lib.py)

java_library(my_lib_java MyLib.java)
