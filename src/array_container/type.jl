

type ArrayContainer <: RoaringContainer
    arr::Vector{UInt16}
end

function ArrayContainer()
    return ArrayContainer(Vector{UInt16}())
end

cardinality(x::ArrayContainer) = length(x.arr)

@inline function Base.copy(x::ArrayContainer)
    return ArrayContainer(copy(x.arr))
end

"Check whether `value` is present in the `ArrayContainer` `container`."
@inline function contains{T<:Unsigned}(container::ArrayContainer, value::T)
    return !isempty(searchsorted(container.arr, value))
end

@inline function isequal(a::ArrayContainer, b::ArrayContainer)
    return (cardinality(a) == cardinality(b)) && (a.arr == b.arr)
end

"Test that the `ArrayContainer` `x` is empty."
isempty(x::ArrayContainer) = cardinality(x) == 0

#=
/**
 * If the element of given rank is in this container, supposing that the first
 * element has rank start_rank, then the function returns true and sets element
 * accordingly.
 * Otherwise, it returns false and update start_rank.
 */
static inline bool array_container_select(const array_container_t *container,
                                          uint32_t *start_rank, uint32_t rank,
                                          uint32_t *element) {
    int card = array_container_cardinality(container);
    if (*start_rank + card <= rank) {
        *start_rank += card;
        return false;
    } else {
        *element = container->array[rank - *start_rank];
        return true;
    }
}
=#
"""
If the element of given rank is in this container, supposing that the first
element has rank start_rank, then the function returns true and sets element
accordingly.
Otherwise, it returns false and update start_rank.
"""
@inline function select(x::ArrayContainer, startrank::UInt32, rank::UInt32)
    c = cardinality(x)
    if (startrank + c) <= rank
        return (false, startrank + c, 0x00000000)
    else
        return (true, startrank, x.arr[(rank - startrank) + 1])
    end
end
