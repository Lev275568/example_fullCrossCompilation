

#include "someHeader.hpp"

import myspace.mexample;

import std;

#if GLOBAL_DEFINE != 100
#error
#endif

int main()
{
    try {
        myspace::mexample::hello();
        myspace::mexample::world();
        myspace::mexample::dot();
        std::println("");

        // std::println("addresult={}", myspace::add(10, 20));
    }
    catch (...) {
    }
    return 0;
}
