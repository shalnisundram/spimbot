#include "cacheconfig.h"
#include "utils.h"
# include "math.h"

CacheConfig::CacheConfig(uint32_t size, uint32_t block_size, uint32_t associativity)
: _size(size), _block_size(block_size), _associativity(associativity) {
  /**
   * TODO
   * Compute and set `_num_block_offset_bits`, `_num_index_bits`, `_num_tag_bits`.
  */ 
  // associativity = # of blocks per set
  uint32_t set_count = size / associativity; // bytes per set
  set_count = set_count / block_size; // set_count = blocks per set
  _num_index_bits = log2(set_count);
  _num_block_offset_bits = log2(block_size);
  _num_tag_bits = 32 - _num_index_bits - _num_block_offset_bits;
}
