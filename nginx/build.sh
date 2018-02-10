#!/bin/bash
set -e

auto/configure --with-http_ssl_module

echo 'cmake_minimum_required(VERSION 3.6)' > CMakeLists.txt
echo 'project(nginx)' >> CMakeLists.txt

echo 'set(SOURCE_FILES' >> CMakeLists.txt

grep '\.c$' objs/Makefile |tr -d '[:blank:]'|uniq >> CMakeLists.txt

echo  >>objs/Makefile
echo 'print_deps:' >>objs/Makefile
echo '	@echo $(HTTP_DEPS) $(CORE_DEPS)' >>objs/Makefile
echo  >>objs/Makefile
echo 'print_incs:' >>objs/Makefile
echo '	@echo $(ALL_INCS)' >>objs/Makefile

make -f objs/Makefile print_deps |tr ' ' '\n' >> CMakeLists.txt

echo ')' >> CMakeLists.txt

echo 'include_directories(' >> CMakeLists.txt
make -f objs/Makefile print_incs|sed 's/-I //g' |tr ' ' '\n' >> CMakeLists.txt
echo ')' >> CMakeLists.txt

echo 'add_executable(nginx ${SOURCE_FILES})' >> CMakeLists.txt

echo -n 'target_link_libraries(nginx ' >> CMakeLists.txt

LIBS=`grep '\-ldl' objs/Makefile |sed 's/\\\//g'|sed 's/-l//g'`

echo $LIBS ")" >> CMakeLists.txt
