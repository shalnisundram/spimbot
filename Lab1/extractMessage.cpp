/**
 * @file
 * Contains an implementation of the extractMessage function.
 */

#include <iostream> // might be useful for debugging
#include <assert.h>
#include "extractMessage.h"

using namespace std;

int make_mask(int order) {
    int start = 1;
    start = start << (order);
    return start;
}

unsigned char *extractMessage(const unsigned char *message_in, int length) {
    // length must be a multiple of 8
    assert((length % 8) == 0);
    

    // allocate an array for the output
    unsigned char *message_out = new unsigned char[length];
    for (int i = 0; i < length; i++) {
        message_out[i] = 0;
    }
    
    for (int byte_group = 0; byte_group < length; byte_group += 8) { // iterate through bytes
        for (int byte = 0; byte < 8; byte++) { 
            for (int bit = 0; bit < 8; bit++) {
                char write_byte = message_out[byte_group + byte]; 
                char read_byte = message_in[byte_group + bit];    
                int read_bit = (read_byte & make_mask(byte)) != 0;
                write_byte = write_byte | (read_bit << bit);
                message_out[byte_group + byte] = write_byte;
            }
        }
    }

    return message_out;
}
