
abstract RoaringContainer

# Constants for containers.

## Array containers.
const ARRAY_DEFAULT_MAX_SIZE = 4096
#const ARRAY_DEFAULT_SIZE = 16

## Bitset containers.
const BITSET_CONTAINER_SIZE_IN_WORDS = (1 << 16) / 64

# Container type definitions and methods.
include("array_container/type.jl")
include("array_container/manipulation.jl")
include("bitset_container.jl")
