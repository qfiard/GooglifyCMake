GooglifyCMake
============

A project that allows using CMake like Blaze (Google's build system) for C++, Objective-C, Java, Python and R. iOS apps are now supported, as well as the compilation of a few third-party libraries (Boost, OpenSSL, gflags, protobuf, ...) under i386 and armv7-armv7s architectures for the iOS simulator and iPhone targets. Check this out!

TODO
----

- [ ] Create a Wiki to explain the use of each target and rule.
- [ ] Build in the Wiki a list of all included third-party libraries along with their portability status (Mac OS X, Linux, Windows, iOS, iOS simulator, ...).

Warning
-------

Some of the third-party libraries included may not compile on a system that is not identical to the one used for the development of this project:
- Mac OS X 10.9 Maverick (x86_64-apple-darwin13.0.0)
- Clang 3.5
- Latest libc++ (http://libcxx.llvm.org) and libc++abi installed

Clang 3.5, libc++ and libc++abi are included as third-party targets in this project, feel free to build them and install them on your system.

Pull requests are greatly welcome for all non-portable third-party libraries and targets, notably:
- HAProxy
- ICU
- IMAP-2007f
- LDAP SASL
- libcurl

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

Before going any further let's consider a real-life example of a `CMakeLists.txt` file using this project (it is the definition of the `util` module provided in this project):

Module `util`:

```CMake
add_subdirectory(dev)

cc_library(abi abi.h)

cc_test(abi_test abi_test.cc)
link(abi_test third_party.gtest)

cc_library(algorithm algorithm.h)

cc_library(csv csv.h csv.cc)
link(csv :logging third_party.gflags)

cc_library(date_time date_time.h date_time.cc)
link(date_time :csv :logging third_party.boost_date_time)
add_data(date_time ${BOOST_TIME_ZONE_CSV})

cc_test(date_time_test date_time_test.cc)
link(date_time_test :date_time :logging third_party.gtest)

cc_library(iterators iterators.h)

cc_library(logging logging.h logging.cc)
link(logging third_party.g2log)

cc_test(logging_test logging_test.cc)
link(logging_test :logging third_party.boost_filesystem third_party.gtest)

cc_library(ptr_set ptr_set.h)

cc_library(socket socket.h socket.cc)
link(socket :logging base.base third_party.boost_asio third_party.gflags)

java_library(socket_java Socket.java)

cc_library(streams streams.h streams.cc)

cc_library(strings strings.h strings.cc)
link(strings :logging)

cc_test(strings_test strings_test.cc)
link(strings_test :strings third_party.gtest)

cc_library(system system.h system.cc)
link(system :logging)

cc_test(system_test system_test.cc)
link(system_test :system third_party.gtest)
```

The first line recursively includes the definitions of the module `util.dev`. Each following section is of the form:

1. A target definition rule (`cc_library`, `cc_test` or `java_library` in this example, see the section on **Rules** below for more target types), called with the name of the target (relative to the current package --- e.g. the rule `cc_library(strings ...)` will define a target named `util.strings`) and a list of sources.
2. An optional `link` rule to link with local targets (identified by a colon followed by the name of the target) and global ones.
3. A number of other rules to modify target properties (here `add_data` to allow a target to access a data file).

The other of the rules is not impose by CMake, which only requires that the target definition rule be placed before any other rule associated with that target. By convention and to imitate Google Blaze we choose to always follow the above order, an automatic formatting tool is provided in the package `tools.buildifier` to easily maintain `CMakeLists.txt` files using this syntax.

Here is another example where generating rules are required (it is the definition of the `tools.buildifier.parser` module provided in this project):

```CMake
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
```

By convention we list generating rules at the beginning of the `CMakeLists.txt` file, after `add_subdirectory` commands. See the subsection **Rules -> Generating sub-products** for more details on the available generative rules.

Installation instructions
-------------------------

### Standard build
```bash
cd GooglifyCmake
mkdir build && cd build
cmake ..
```

See the [`examples`](https://github.com/QuentinFiard/GooglifyCMake/tree/master/src/examples) package for use cases and examples. To run a few examples you can execute the following commands (starting from the `build` directory):

```bash
cd src/examples/a_package
make
./cc_exe
./java_exe
```

### iOS simulator build

```bash
cd GooglifyCmake
mkdir build_ios_sim && cd build_ios_sim
cmake .. -DIOS_SIMULATOR_BUILD=ON -DBUILD_SHARED_LIBS=OFF
```

An example iOS app can be found in the [`examples.ios_app`](https://github.com/QuentinFiard/GooglifyCMake/tree/master/src/examples/ios_app) package. To run it in the iOS simulator, install [ios-sim](https://github.com/phonegap/ios-sim) (with `brew install ios-sim` for example if you have `brew` installed on your machine) and execute the following commands (starting from the `build_ios_sim` directory).

```bash
cd src/examples/ios_app
make
ios-sim launch TestApp.app
```

### iOS build

```bash
cd GooglifyCmake
mkdir build_ios && cd build_ios
cmake .. -DIOS_BUILD=ON -DBUILD_SHARED_LIBS=OFF
make
```

Rules
-----

### Defining targets

`cc_binary`

`cc_library`

`cc_test`

`ios_app`

`j2e_binary`

`java_binary`

`java_library`

`objc_binary`

`objc_library`

`objc_test`

`py_binary`

`py_library`

`r_binary`

### Linking targets

`link`

`link_framework`

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


