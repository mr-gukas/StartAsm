# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.25

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/gukas/myDos/DOSBox/gthb

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/gukas/myDos/DOSBox/gthb/build

# Include any dependencies generated for this target.
include CMakeFiles/hack.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/hack.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/hack.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/hack.dir/flags.make

CMakeFiles/hack.dir/main.cpp.o: CMakeFiles/hack.dir/flags.make
CMakeFiles/hack.dir/main.cpp.o: /home/gukas/myDos/DOSBox/gthb/main.cpp
CMakeFiles/hack.dir/main.cpp.o: CMakeFiles/hack.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/gukas/myDos/DOSBox/gthb/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/hack.dir/main.cpp.o"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT CMakeFiles/hack.dir/main.cpp.o -MF CMakeFiles/hack.dir/main.cpp.o.d -o CMakeFiles/hack.dir/main.cpp.o -c /home/gukas/myDos/DOSBox/gthb/main.cpp

CMakeFiles/hack.dir/main.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/hack.dir/main.cpp.i"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/gukas/myDos/DOSBox/gthb/main.cpp > CMakeFiles/hack.dir/main.cpp.i

CMakeFiles/hack.dir/main.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/hack.dir/main.cpp.s"
	/usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/gukas/myDos/DOSBox/gthb/main.cpp -o CMakeFiles/hack.dir/main.cpp.s

# Object files for target hack
hack_OBJECTS = \
"CMakeFiles/hack.dir/main.cpp.o"

# External object files for target hack
hack_EXTERNAL_OBJECTS =

hack: CMakeFiles/hack.dir/main.cpp.o
hack: CMakeFiles/hack.dir/build.make
hack: /usr/lib/libsfml-graphics.so.2.5.1
hack: /usr/lib/libsfml-window.so.2.5.1
hack: /usr/lib/libsfml-audio.so.2.5.1
hack: /usr/lib/libsfml-system.so.2.5.1
hack: CMakeFiles/hack.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/gukas/myDos/DOSBox/gthb/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable hack"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/hack.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/hack.dir/build: hack
.PHONY : CMakeFiles/hack.dir/build

CMakeFiles/hack.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/hack.dir/cmake_clean.cmake
.PHONY : CMakeFiles/hack.dir/clean

CMakeFiles/hack.dir/depend:
	cd /home/gukas/myDos/DOSBox/gthb/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/gukas/myDos/DOSBox/gthb /home/gukas/myDos/DOSBox/gthb /home/gukas/myDos/DOSBox/gthb/build /home/gukas/myDos/DOSBox/gthb/build /home/gukas/myDos/DOSBox/gthb/build/CMakeFiles/hack.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/hack.dir/depend

