
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
