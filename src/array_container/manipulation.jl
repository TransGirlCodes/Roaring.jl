

"""
Add `value` to an ArrayContainer. Returns true if `value` was not already
present.
"""
@inline function add!{T<:Unsigned}(container::ArrayContainer, value::T)
    insertpoint = searchsorted(container.arr, value)
    # splice! won't do anything if the array already has the value (insertpoint)
    # has a length of 1.
    splice!(container.arr, insertpoint, value)
    return isempty(insertpoint)
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
    # deleteat! won't do anything if rempoint is empty.
    deleteat!(container.arr, rempoint)
    return !isempty(rempoint)
end

"Clear all values from an ArrayContainer"
@inline function clear!(container::ArrayContainer)
    container.arr = Vector{UInt16}()
end
