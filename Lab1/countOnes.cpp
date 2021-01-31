/**
 * @file
 * Contains an implementation of the countOnes function.
 */

unsigned countOnes(unsigned input) {
	// TODO: write your code here
	unsigned left_mask_1 = 0xAAAAAAAA;
	unsigned right_mask_1 = 0x55555555;
	unsigned left_mask_2 = 0xCCCCCCCC;
	unsigned right_mask_2 = 0x33333333;
	unsigned left_mask_3 = 0xF0F0F0F0;
	unsigned right_mask_3 = 0x0F0F0F0F;
	unsigned left_mask_4 = 0xFF00FF00;
	unsigned right_mask_4 = 0x00FF00FF;
	unsigned left_mask_5 = 0xFFFF0000;
	unsigned right_mask_5 = 0x0000FFFF;

	unsigned right_counter = input & right_mask_1;
	unsigned left_counter = input & left_mask_1;
	input = (left_counter >> 1) + right_counter;
	
	right_counter = input & right_mask_2;
	left_counter = input & left_mask_2;
	input = (left_counter >> 2) + right_counter;

	right_counter = input & right_mask_3;
	left_counter = input & left_mask_3;
	input = (left_counter >> 4) + right_counter;

	right_counter = input & right_mask_4;
	left_counter = input & left_mask_4;
	input = (left_counter >> 8) + right_counter;

	right_counter = input & right_mask_5;
	left_counter = input & left_mask_5;
	input = (left_counter >> 16) + right_counter;
	return input;
}
