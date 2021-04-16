#include "cacheblock.h"

uint32_t Cache::Block::get_address() const {
  // TODO
  uint32_t starting_address = get_tag() << _cache_config.get_num_index_bits();
  starting_address += _index;
  starting_address = starting_address << _cache_config.get_num_block_offset_bits();
  return starting_address;
}
