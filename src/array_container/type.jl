

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
