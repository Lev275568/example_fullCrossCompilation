#pragma once

// #include <sys/socket.h>

// #include "globalInc.hpp"

#if GLOBAL_DEFINE != 100
#error
#endif

namespace myspace {

inline int add(int a, int b)
{
    return a + b;
}

} // namespace myspace
