#include "cachesimulator.h"

Cache::Block* CacheSimulator::find_block(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `_cache->get_blocks_in_set` to get all the blocks that could
   *    possibly have `address` cached.
   * 2. Loop through all these blocks to see if any one of them actually has
   *    `address` cached (i.e. the block is valid and the tags match).
   * 3. If you find the block, increment `_hits` and return a pointer to the
   *    block. Otherwise, return NULL.
   */
   const CacheConfig & _cache_config = _cache->get_config();
   uint32_t address_index = extract_index(address, _cache_config);
   uint32_t address_tag = extract_tag(address, _cache_config);
   std::vector<Cache::Block*> set_blocks = _cache->get_blocks_in_set(address_index);

   for (int i = 0; i < set_blocks.size(); i++) {
     if (set_blocks[i]->is_valid() && set_blocks[i]->get_tag() == address_tag) {
       _hits++;
       return set_blocks[i];
     }
   }
   return NULL;
}

Cache::Block* CacheSimulator::bring_block_into_cache(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `_cache->get_blocks_in_set` to get all the blocks that could
   *    cache `address`.
   * 2. Loop through all these blocks to find an invalid `block`. If found,
   *    skip to step 4.
   * 3. Loop through all these blocks to find the least recently used `block`.
   *    If the block is dirty, write it back to memory.
   * 4. Update the `block`'s tag. Read data into it from memory. Mark it as
   *    valid. Mark it as clean. Return a pointer to the `block`.
   */
   const CacheConfig & _cache_config = _cache->get_config();
   uint32_t address_index = extract_index(address, _cache_config);
   uint32_t address_tag = extract_tag(address, _cache_config);
   std::vector<Cache::Block*> set_blocks = _cache->get_blocks_in_set(address_index);

   Cache::Block *LRU_block;
   uint32_t LRU_time = 1000000;
   
   for (int i = 0; i < set_blocks.size(); i++) {
     if (!set_blocks[i]->is_valid()) {
       set_blocks[i]->set_tag(address_tag);
       set_blocks[i]->read_data_from_memory(_memory);
       set_blocks[i]->mark_as_valid();
       set_blocks[i]->mark_as_clean();
       return set_blocks[i];
     }

    if (set_blocks[i]->get_last_used_time() < LRU_time) {
        LRU_block = set_blocks[i];
        LRU_time = set_blocks[i]->get_last_used_time();
    }
   }

   if (LRU_block->is_dirty()) {
     LRU_block->write_data_to_memory(_memory);
   }
   LRU_block->set_tag(address_tag);
   LRU_block->read_data_from_memory(_memory);
   LRU_block->mark_as_valid();
   LRU_block->mark_as_clean();
   return LRU_block;
}

uint32_t CacheSimulator::read_access(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `find_block` to find the `block` caching `address`.
   * 2. If not found, use `bring_block_into_cache` cache `address` in `block`.
   * 3. Update the `last_used_time` for the `block`.
   * 4. Use `read_word_at_offset` to return the data at `address`.
   */
   const CacheConfig & _cache_config = _cache->get_config();
   Cache::Block* address_block = find_block(address);
   uint32_t address_offset = extract_block_offset(address, _cache_config);

   if (address_block == NULL) {
     address_block = bring_block_into_cache(address);
   }

   _use_clock++;
   address_block->set_last_used_time((_use_clock).get_count());
   return address_block->read_word_at_offset(address_offset);
}

void CacheSimulator::write_access(uint32_t address, uint32_t word) const {
  /**
   * TODO
   *
   * 1. Use `find_block` to find the `block` caching `address`.
   * 2. If not found
   *    a. If the policy is write allocate, use `bring_block_into_cache`.
   *    a. Otherwise, directly write the `word` to `address` in the memory
   *       using `_memory->write_word` and return.
   * 3. Update the `last_used_time` for the `block`.
   * 4. Use `write_word_at_offset` to to write `word` to `address`.
   * 5. a. If the policy is write back, mark `block` as dirty.
   *    b. Otherwise, write `word` to `address` in memory.
   */
   const CacheConfig & _cache_config = _cache->get_config();
   uint32_t address_offset = extract_block_offset(address, _cache_config);
   Cache::Block* address_block = find_block(address);

   if (address_block == NULL) {
     if (_policy.is_write_allocate()) {
       address_block = bring_block_into_cache(address);
     } else {
       _memory->write_word(address, word);
       return;
     }
   }
   _use_clock++;
   address_block->set_last_used_time((_use_clock).get_count());
   address_block->write_word_at_offset(word, address_offset);

     if (_policy.is_write_back()) {
       address_block->mark_as_dirty();
     } else {
       address_block->write_data_to_memory(_memory);
     }
}
