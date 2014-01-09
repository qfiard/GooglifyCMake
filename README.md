GooglifyCMake
============

A project that allows using CMake like Blaze (Google's build system) for C++, Java, Python and R.

Motivation
----------

I started this project following a three-month internship at Google to continue developing software in the Google fashion. **Blaze**, Google's build system, is an impressive piece of software that provides support for in-the-cloud compilation, highly ramified source dependency graphs and a dozen programming languages in a unified environment. A more in depth presentation of Blaze can be found on [Google Engineering Tools blog](http://google-engtools.blogspot.fr/2011/08/build-in-cloud-how-build-system-works.html).

Blaze is designed to work in Google's highly hierarchical codebase, where each module is defined in a very simple way with rules in a BUILD file. The following snippet shows an example definition of a module `//search` with two targets, a library and an executable (source: [Google Engineering Tools blog](http://google-engtools.blogspot.fr/2011/08/build-in-cloud-how-build-system-works.html)).

    /search/BUILD:
    cc_binary(name = ‘google_search_page’,
              deps = [ ‘:search’,
                       ‘:show_results’])

    cc_library(name = ‘search’,
               srcs = [ ‘search.h’,‘search.cc’],
               deps = [‘//index:query’])

None of the build systems that I have tested prior to starting this project (Make, raw CMake, Boost.Build, SCons, Maven) achieved the same simplicity at defining modules and linking libraries (third-party or not). Furthermore most of them are limited to a specific programming language (Boost.Build: C++; Maven: Java, C++), require you to write substantial amounts of code to define your projects (Make, raw CMake) or have a verbose syntax for even very simple tasks (SCons).

These frustrations were a main motivation to develop a new tool whose syntax would be as close as possible to that of Google's BUILD file and that would allow the rapid development of highly modular code (to promote code reuse) with an optional easy link to popular third party libraries ([Boost](http://boost.org), [OpenCV](http://opencv.org), [Google's Protocol Buffers](https://code.google.com/p/protobuf/) [GMP](http://gmplib.org), [JsonCpp](http://jsoncpp.sourceforge.net), [RapidXML](http://rapidxml.sourceforge.net)... --- as of now more than 30 external libraries are integrated in the build system).

Specification and syntax
------------------------

This tool is built on top of CMake, which was chosen for its non-verbose syntax, its portability and ease of include of external libraries (through the ExternalProject module).

Before going any further let's consider a real-life example of a CMakeLists.txt file using this project:

```CMake
add_subdirectory(dev)
add_subdirectory(proto)

cc_library(abi abi.h)

cc_test(abi_test abi_test.cc)
link(abi_test third_party.gtest)

cc_library(algorithm algorithm.h)

cc_library(csv csv.h csv.cc)
link_local(csv logging)
link(csv third_party.gflags)

cc_library(date_time date_time.h date_time.cc)
link_local(date_time csv)
link_local(date_time logging)
link(date_time third_party.boost_date_time)
add_data(date_time ${BOOST_TIME_ZONE_CSV})

cc_test(date_time_test date_time_test.cc)
link_local(date_time_test date_time)
link_local(date_time_test logging)
link(date_time_test third_party.gtest)

cc_library(iterators iterators.h)

cc_library(logging logging.h logging.cc)
link(logging third_party.g2log)

cc_test(logging_test logging_test.cc)
link_local(logging_test logging)
link(logging_test third_party.boost_filesystem)
link(logging_test third_party.gtest)

cc_library(ptr_set ptr_set.h)

cc_library(socket socket.h socket.cc)
link(socket base.base)
link(socket third_party.boost_asio)
link(socket third_party.gflags)

java_library(socket_java Socket.java)

cc_library(streams streams.h streams.cc)

cc_library(strings strings.h strings.cc)
link_local(strings logging)

cc_test(strings_test strings_test.cc)
link_local(strings_test strings)
link(strings_test third_party.gtest)

cc_library(system system.h system.cc)
link_local(system logging)

cc_test(system_test system_test.cc)
link_local(system_test system)
link(system_test third_party.gtest)
```

Installation instructions
-------------------------

```bash
cd GooglifyCmake
mkdir build && cd build
cmake ..
make
```

See the `src/examples` package for use cases and examples. To run a few examples you can execute the following commands (starting from the `build` directory):

```bash
cd src/examples/a_package
./cc_exe
./java_exe
```

Rules
-----

### Defining targets

`cc_binary`

`cc_library`

`cc_test`

`j2e_binary`

`java_binary`

`java_library`

`py_binary`

`py_library`

`r_binary`

### Linking targets

`link`

`link_local`

### Including required data

`add_data`

`add_local_data`

`add_file` ---j2e_binary only---

`add_local_file` ---j2e_binary only---

### Generating sub-products

`bison_generate_parser`

`flex_generate_scanner`

`protobuf_generate_cc`

`protobuf_generate_java`

`protobuf_generate_py`


