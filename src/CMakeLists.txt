add_library (Miguno miguno.c miguno.h)

add_executable (main main.c)
target_include_directories(main SYSTEM PRIVATE ${UTF8H_INCLUDE_DIRS})
target_link_libraries (main Miguno)
