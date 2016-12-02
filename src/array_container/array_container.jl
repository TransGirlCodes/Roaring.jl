










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
