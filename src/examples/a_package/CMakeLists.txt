cc_binary(cc_exe main.cc)
link(cc_exe :my_lib examples.other_package.my_lib)

py_binary(hello_world_py hello_world.py)
link(hello_world_py :my_lib_py)

r_binary(hello_world_r hello_world.R)

java_binary(java_exe Main.java)
link(java_exe :my_lib_java examples.other_package.my_lib_java)

cc_library(my_lib my_lib.h my_lib.cc)

java_library(my_lib_java MyLib.java)

py_library(my_lib_py my_lib.py)

cc_test(my_lib_test my_lib_test.cc)
link(my_lib_test :my_lib third_party.gmock third_party.gtest)

objc_binary(objc_exe main.mm)
link_framework(objc_exe Foundation)
