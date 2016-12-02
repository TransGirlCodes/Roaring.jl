
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
        #container.card += 1
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
        #container.card -= 1
    end
    return present
end
