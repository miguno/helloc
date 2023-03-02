# This file was taken from https://github.com/raysan5/raylib/blob/master/cmake/AddIfFlagCompiles.cmake

# https://github.com/Kitware/CMake/blob/master/Modules/CheckCCompilerFlag.cmake
include(CheckCCompilerFlag)

# Examples:
#
# add_if_flag_compiles(-Wall COMPILE_OPTIONS) # same as add_compile_options(-Wall)
#
# add_if_flag_compiles(-fsanitize=address CMAKE_C_FLAGS CMAKE_EXE_LINKER_FLAGS)
#
function(add_if_flag_compiles flag)
  CHECK_C_COMPILER_FLAG("${flag}" COMPILER_HAS_THOSE_TOGGLES)
  set(outcome "Failed")
  if(COMPILER_HAS_THOSE_TOGGLES)
    foreach(var ${ARGN})
      set(${var} "${flag} ${${var}}" PARENT_SCOPE)
    endforeach()
    set(outcome "compiles")
  endif()
  message(STATUS "Testing if ${flag} can be used -- ${outcome}")
endfunction()
