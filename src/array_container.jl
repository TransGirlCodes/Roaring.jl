
type ArrayContainer <: RoaringContainer
    card::UInt
    cap::UInt
    arr::Vector{UInt16}
end

ArrayContainer(size::Integer = ARRAY_DEFAULT_SIZE) = ArrayContainer(0, size, Vector{UInt16}(size))

cardinality(x::ArrayContainer) = x.card

capacity(x::ArrayContainer) = x.cap

@inline function capacity!(x::ArrayContainer, y::Integer)
    x.cap = y
end

@inline function Base.copy(x::ArrayContainer)
    return ArrayContainer(cardinality(x), capacity(x), copy(x.arr))
end

@inline function Base.copy!(dest::ArrayContainer, source::ArrayContainer)
    cardi = cardinality(source)
    if cardinality(dest) > capacity(dest)
        grow!(dest, cardi, typemax(UInt32), false)
    end
    cardinality!(dest, cardi)
    copy!(dest.arr, 1, source.arr, 1, length(source.arr))
end

@inline function shrink!(x::ArrayContainer)
    if cardinality(x) != capacity(x)
        cp = capacity(x)
        cd = cardinality(x)
        savings = cp - cd
        capacity!(x, cd)
        resize!(x.arr, cd)
    else
        savings = UInt(0)
    end
    return savings
end

@inline function growth_capacity(c::Integer)
    if c <= 0
        return ARRAY_DEFAULT_SIZE
    elseif c < 64
        return Int32(c * 2)
    elseif c < 1024
        return Int32(floor(c * 3 / 2))
    else
        return Int32(floor(c * 5 / 4))
    end
end
@inline function growth_capacity(x::ArrayContainer)
    return growth_capacity(capacity(x))
end

function grow!(x::ArrayContainer, min::Integer, max::Integer, preserve::Bool)
    ncap = clamp(growth_capacity(x), min, max)
    ncap = ncap > (max - max / 16) ? max : ncap
    capacity!(x, ncap)
    if preserve
        resize!(x.arr, ncap)
    else
        x.arr = Vector{UInt16}(ncap)
    end
    return x
end

"Test that the `ArrayContainer` `x` is full."
isfull(x::ArrayContainer) = cardinality(x) == capacity(x)

"Test that the `ArrayContainer` `x` is empty."
isempty(x::ArrayContainer) = cardinality(x) == 0





#=
/* Append x to the set. Assumes that the value is larger than any preceding
 * values.  */
static void array_container_append(array_container_t *arr, uint16_t pos) {
    const int32_t capacity = arr->capacity;

    if (array_container_full(arr)) {
        array_container_grow(arr, capacity + 1, INT32_MAX, true);
    }

    arr->array[arr->cardinality++] = pos;
}
=#
"""
    append!(arr::ArrayContainer, pos::UInt16)

Append `pos` to the `ArrayContainer` `arr`, this assumes that the value being
appended is larger than any value currently in the container.
"""
function append!(arr::ArrayContainer, pos::UInt16)
    cap = capacity(arr)
    if isfull(arr)
        grow!(arr, cap + 1, typemax(Int32), true)
    end
    arr.card += 1
    arr.arr[arr.card] = pos
end


#=
Add all the values in [min,max) (included) at a distance k*step from min.
The container must have a size less or equal to ARRAY_DEFAULT_MAX_SIZE
after this addition.

void array_container_add_from_range(array_container_t *arr, uint32_t min,
                                    uint32_t max, uint16_t step) {
    for (uint32_t value = min; value < max; value += step) {
        array_container_append(arr, value);
    }
}
=#
function add!{T<:Unsigned}(container::ArrayContainer, r::UnitRange{T})
    for i in r
        append!(container, value)
    end
    return container
end

"""
Add `value` to an ArrayContainer. Returns true if `value` was not already
present.
"""
function add!{T<:Unsigned}(container::ArrayContainer, value::T)
    insertpoint = searchsorted(container.arr, value)
    notpresent = isempty(insertpoint)
    if notpresent
        splice!(container.arr, insertpoint, value)
        container.card += 1
    end
    return notpresent
end

function isequal(a::ArrayContainer, b::ArrayContainer)
    return (cardinality(a) == cardinality(b)) && (a.arr == b.arr)
end
