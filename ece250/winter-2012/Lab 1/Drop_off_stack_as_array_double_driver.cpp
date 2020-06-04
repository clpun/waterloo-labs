/****************************************************
 * Executable:   Drop_off_stack_as_array_driver
 * Author:  Douglas Wilhelm Harder
 * Copyright (c) 2006-8 by Douglas Wilhelm Harder.  All rights reserved.
 *
 * DO NOT EDIT THIS FILE
 *
 * Create an instance of the Drop_off_stack_as_array<double> class
 * and call the member function run().
 *
 * The member function run() will interpret the
 * input appropriately and exit when the interpreter
 * receives either the command 'exit' or and
 * end-of-file.
 ****************************************************/

#include "Drop_off_stack_as_array_tester.h"

int main() {
	Drop_off_stack_as_array_tester<double> tester;

	std::cout << "Starting Test Run" << std::endl;

	tester.run();

	std::cout << "Finishing Test Run" << std::endl;

	return 0;
}
