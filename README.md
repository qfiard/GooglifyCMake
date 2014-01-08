GooglifyCMake
============

A project that allows using CMake like Blaze (Google's build system) for C++, Java, Python and R.

Installation instructions
-------------------------

TODO

Rules
-----

### Defining targets

cc_binary
cc_library
cc_test
j2e_binary
java_binary
java_library
py_binary
py_library
r_binary

### Linking targets

link_local
link

### Generating sub-products

bison_generate_parser
flex_generate_scanner
protobuf_generate_cc
protobuf_generate_java
protobuf_generate_py

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

Specifications
--------------

TODO


