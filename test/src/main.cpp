#include <iostream>
#include "test.h"

// Change the name of 'XXX_VERSION...' below to the targetname in makefile!
// void printVersion()
// {
// 	extern char libtest_VERSION_MAJOR_REF;
// 	extern char libtest_VERSION_MINOR_REF;
// 	extern char libtest_VERSION_PATCH_REF;
// 	extern char libtest_VERSION_REVISION_REF;
// 	extern char libtest_BUILD_NUMBER_REF;

// 	std::cout << "Version: v" << (unsigned long) &libtest_VERSION_MAJOR_REF;
// 	std::cout << "." << (unsigned long) &libtest_VERSION_MINOR_REF;
// 	std::cout << "." << (unsigned long) &libtest_VERSION_PATCH_REF;
// 	std::cout << "." << (unsigned long) &libtest_VERSION_REVISION_REF;
// 	std::cout << "." << (unsigned long) &libtest_BUILD_NUMBER_REF << std::endl;
// }

int main(){
	std::cout << __PRETTY_FUNCTION__ << std::endl;
	Test test;
	test.printVersion();
}
