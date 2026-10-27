
add_executable(mexample)
target_sources(mexample
    PRIVATE
        user.cpp
    PUBLIC FILE_SET all_my_modules TYPE CXX_MODULES FILES
        impl_part.cppm
        impl.cppm
        interface_part.cppm
        mexample.cppm
)
target_compile_features(mexample PUBLIC cxx_std_26)

target_precompile_headers(mexample REUSE_FROM pchLib)
target_link_libraries(mexample
    pchLib
)

