

#include "someHeader.hpp"

import myspace.mexample;

import std;

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
