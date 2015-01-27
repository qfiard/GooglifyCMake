#!/bin/bash
set -ex
wget https://github.com/Kitware/CMake/archive/v3.1.1.tar.gz
tar -xvf v3.1.1.tar.gz
cd CMake-3.1.1
cmake . && make && sudo make install
