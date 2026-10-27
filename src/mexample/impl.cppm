
module;

#include <print> // prefer 'import std;' instead

module myspace.mexample:impl;

// import std;

namespace myspace::mexample {

void hello() { std::print("Hello "); }

} // namespace myspace::mexample
