add_library (Miguno miguno.c miguno.h)

add_executable (main main.c)
target_link_libraries (main Miguno)
