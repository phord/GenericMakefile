#include "test.hpp"
#include "jversion.hpp"
#include <iostream>

void Test::DoSth()
{
    JVersion::Test::PrintVersion();
    std::cout << "This library can do something" << std::endl;
}