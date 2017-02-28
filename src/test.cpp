#include "test.h"
#include <stdio.h>

// extern char test_VERSION_MAJOR_REF;
// extern char test_VERSION_MINOR_REF;
// extern char test_VERSION_PATCH_REF;
// extern char test_VERSION_REVISION_REF;
// extern char test_BUILD_NUMBER_REF;

void Test::printVersion()
{
	std::cout << __PRETTY_FUNCTION__ << std::endl;
	// printf("Version of test: v:%lu.%lu.%lu.%lu.%lu\n", (unsigned long) &test_VERSION_MAJOR_REF,
	// 								  (unsigned long) &test_VERSION_MINOR_REF,
	// 								  (unsigned long) &test_VERSION_PATCH_REF,
	// 								  (unsigned long) &test_VERSION_REVISION_REF,
	// 								  (unsigned long) &test_BUILD_NUMBER_REF);
}
