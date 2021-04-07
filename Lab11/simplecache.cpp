#include "simplecache.h"
#include <iostream>

int SimpleCache::find(int index, int tag, int block_offset) {
  // read handout for implementation details

  std::vector<SimpleCacheBlock> block_set = _cache[index];

  for (std::vector<SimpleCacheBlock>::iterator curr_block = block_set.begin(); curr_block != block_set.end(); ++curr_block) {
    if (curr_block->valid() && curr_block->tag() == tag) {
      return curr_block->get_byte(block_offset);
    }
  } 
  return 0xdeadbeef;
}

void SimpleCache::insert(int index, int tag, char data[]) {
  // read handout for implementation details
  // keep in mind what happens when you assign (see "C++ Rule of Three")

  std::vector<SimpleCacheBlock> &block_set = _cache[index];
  for (std::vector<SimpleCacheBlock>::iterator curr_block = block_set.begin(); curr_block != block_set.end(); ++curr_block) {
    if (!curr_block->valid()) {
      curr_block->replace(tag, data);
      return;
    }
  }
  block_set[0].replace(tag, data); 
}
