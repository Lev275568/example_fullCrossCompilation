module;

#include <print> // prefer 'import std;'

module myspace.mexample:impl_part;

// import :interface_part;

namespace myspace::mexample {

void world()
{
    std::string str = "World";
    std::print("{}", str);
}

} // namespace myspace::mexample
