
module arraySortCheck_control(sorted, done, load_input, load_index, select_index, go, inversion_found, end_of_array, zero_length_array, clock, reset);
	output sorted, done, load_input, load_index, select_index;
	input go, inversion_found, end_of_array, zero_length_array;
	input clock, reset;
	wire sGarbage, sStart, sCheck, sLoad, sDoneUnsorted, sDoneSorted;

	wire s_garbage_next = (sGarbage & ~go) | reset;
	wire s_start_next = ((sStart & go) | (sGarbage & go) | (sDoneUnsorted & go) | (sDoneSorted & go)) & ~reset;
	wire s_check_next = ((sStart & ~go) | (sLoad)) & ~reset;
	wire s_load_next = (sCheck & ~inversion_found & ~end_of_array & ~zero_length_array) & ~reset;
	wire s_done_unsorted_next = ((sCheck & inversion_found & ~end_of_array) | (sDoneUnsorted & ~go)) & ~reset;
	wire s_done_sorted_next = ((sCheck & end_of_array) | (sCheck & zero_length_array) | (sDoneSorted & ~go)) & ~reset;

	dffe fsGarbage(sGarbage, s_garbage_next, clock, 1'b1, 1'b0);
	dffe fsStart(sStart, s_start_next, clock, 1'b1, 1'b0);
	dffe fsCheck(sCheck, s_check_next, clock, 1'b1, 1'b0);
	dffe fsLoad(sLoad, s_load_next, clock, 1'b1, 1'b0);
	dffe fsDoneSorted(sDoneSorted, s_done_sorted_next, clock, 1'b1, 1'b0);
	dffe fsDoneUnsorted(sDoneUnsorted, s_done_unsorted_next, clock, 1'b1, 1'b0);

	assign sorted = sDoneSorted;
	assign done = sDoneSorted | sDoneUnsorted;
	assign load_input = sStart;
	assign select_index = sLoad;
	assign load_index = sLoad | sStart;
	
endmodule
