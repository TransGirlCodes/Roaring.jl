

"""
Add `value` to an ArrayContainer. Returns true if `value` was not already
present.
"""
@inline function add!{T<:Unsigned}(container::ArrayContainer, value::T)
    insertpoint = searchsorted(container.arr, value)
    notpresent = isempty(insertpoint)
    if notpresent
        splice!(container.arr, insertpoint, value)
    end
    return notpresent
end

"""
Add a number of values to an `ArrayContainer`.
"""
@inline function add!{T<:AbstractArray{UInt16,1}}(container::ArrayContainer, values::T)
    for value in range
        add!(container, value)
    end
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
    end
    return present
end
