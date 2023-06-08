add_library (Helloc helloc.c helloc.h)

add_executable (main main.c)
target_link_libraries (main Helloc)
