
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

"""
Add all the values in a given `UnitRange` `range` to an `ArrayContainer`.
The container must have a size less or equal to ARRAY_DEFAULT_MAX_SIZE
after this addition.
"""
@inline function add!{T<:Unsigned}(container::ArrayContainer, range::UnitRange{T})
    for value in range
        add!(container, value)
    end
    return container
end

"""
Add `value` to an ArrayContainer. Returns true if `value` was not already
present.
"""
@inline function add!{T<:Unsigned}(container::ArrayContainer, value::T)
    insertpoint = searchsorted(container.arr, value)
    notpresent = isempty(insertpoint)
    if notpresent
        splice!(container.arr, insertpoint, value)
        container.card += 1
    end
    return notpresent
end

"""
    append!(arr::ArrayContainer, pos::UInt16)

Append `value` to the `ArrayContainer` `arr`, this assumes that the value being
appended is larger than any value currently in the container.
"""
@inline function append!{T<:Unsigned}(container::ArrayContainer, value::T)
    push!(container.arr, value)
end

"Remove `value` from an ArrayContainer. Returns true if `value` was present."
@inline function remove!{T<:Unsigned}(container::ArrayContainer, value::T)
    rempoint = searchsorted(container.arr, value)
    present = !isempty(rempoint)
    if present
        deleteat!(container.arr, rempoint)
        container.card -= 1
    end
    return present
end

"Check whether `value` is present in the `ArrayContainer` `container`."
@inline function contains{T<:Unsigned}(container::ArrayContainer, value::T)
    return !isempty(searchsorted(container.arr, value))
end

@inline function isequal(a::ArrayContainer, b::ArrayContainer)
    return (cardinality(a) == cardinality(b)) && (a.arr == b.arr)
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

#"Test that the `ArrayContainer` `x` is full."
#isfull(x::ArrayContainer) = cardinality(x) == capacity(x)

#"Test that the `ArrayContainer` `x` is empty."
#isempty(x::ArrayContainer) = cardinality(x) == 0

#capacity(x::ArrayContainer) = x.cap

#@inline function capacity!(x::ArrayContainer, y::Integer)
#    x.cap = y
#end
