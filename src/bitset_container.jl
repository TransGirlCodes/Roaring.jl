
type BitsContainer <: RoaringContainer
    card::UInt
    data::Vector{UInt64}
end

function BitsContainer()
    Vector{UInt64}()
    return BitsContainer()
end




bitset_container_t *bitset_container_create(void) {
    bitset_container_t *bitset =
        (bitset_container_t *)calloc(1, sizeof(bitset_container_t));

    if (!bitset) {
        return NULL;
    }
    // sizeof(__m256i) == 32
    bitset->array = (uint64_t *) aligned_malloc(32, sizeof(uint64_t) * BITSET_CONTAINER_SIZE_IN_WORDS);
    if (! bitset->array) {
        free(bitset);
        return NULL;
    }
    bitset_container_clear(bitset);
    return bitset;
}
