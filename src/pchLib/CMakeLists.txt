add_library(pchLib dummy.cpp)

target_include_directories(pchLib
    PUBLIC
        "${WC_ROOT}/src"
)

target_precompile_headers(pchLib PUBLIC pch.hpp)
