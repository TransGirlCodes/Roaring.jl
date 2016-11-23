
const MAX_ARRAY_SIZE = 4096
const ARRAY_DEFAULT_SIZE = Int32(16)

abstract RoaringContainer

type ArrayContainer <: RoaringContainer
    card::UInt
    cap::UInt
    arr::Vector{UInt16}
end

function ArrayContainer(size::Integer)
    a = Vector{UInt16}(size)
    return ArrayContainer(0, size, a)
end

function ArrayContainer()
    return ArrayContainer(ARRAY_DEFAULT_SIZE)
end

@inline function cardinality(x::ArrayContainer)
    return x.card
end

@inline function capacity(x::ArrayContainer)
    return x.cap
end

@inline function capacity!(x::ArrayContainer, y::Integer)
    x.cap = y
end

@inline function Base.copy(x::ArrayContainer)
    return ArrayContainer(cardinality(x), capacity(x), copy(x.arr))
end

@inline function Base.copy(src::ArrayContainer, dst::ArrayContainer)
    cardi = cardinality(src)
    if cardinality(dst) > capacity(dst)
        grow!(dst, cardi, typemax(UInt32), false)
    end
    cardinality!(dst, cardi)
    @inbounds for i in 1:length(src.arr)
        dst.arr[i] = src.arr[i]
    end
end

@inline function shrink!(x::ArrayContainer)
    if cardinality(x) != capacity(x)
        cp = capacity(x)
        cd = cardinality(x)
        savings = cp - cd
        capacity!(x, cd)
        resize!(x.arr, cd)
        return savings
    end
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
end
