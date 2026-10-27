cmake_minimum_required(VERSION 4.5)

set(WC_ROOT "${WC_ROOT}")
if(WC_ROOT STREQUAL "")
    message( FATAL_ERROR "WC_ROOT is empty" )
endif()

add_subdirectory(pchLib)
add_subdirectory(mexample)
