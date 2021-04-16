#include "utils.h"

uint32_t extract_tag(uint32_t address, const CacheConfig& cache_config) {
  // TODO
 if (cache_config.get_num_tag_bits() == 0) {
   return 0;
 }

 if (cache_config.get_num_tag_bits() > 31) {
   return address;
 }
 return address >> (cache_config.get_num_index_bits() + cache_config.get_num_block_offset_bits());
}

uint32_t extract_index(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  if (cache_config.get_num_index_bits() == 0 || cache_config.get_num_tag_bits() > 31) {
    return 0;
  }

  uint32_t without_tag = address << (cache_config.get_num_tag_bits());
  uint32_t final_index = without_tag >> (cache_config.get_num_tag_bits() + cache_config.get_num_block_offset_bits());
  return final_index;
}

uint32_t extract_block_offset(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  if (cache_config.get_num_block_offset_bits() == 0 || cache_config.get_num_tag_bits() > 31) {
    return 0;
  }
  uint32_t only_offset = address << (cache_config.get_num_tag_bits() + cache_config.get_num_index_bits());
  uint32_t to_return = only_offset >> (cache_config.get_num_tag_bits() + cache_config.get_num_index_bits());
  return to_return;

}

