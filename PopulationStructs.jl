module PopulationStructs


struct Individual
    id::Int
    sex::String
    genome::BitMatrix
end

struct Gamete
    id::Int
    sex::String
    genome::BitVector
end

mutable struct Patch
    individuals:: Vector{Individual}
    sex::String
    patch_number::Int
end
export Individual, Gamete, Patch
end