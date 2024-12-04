module Migration
include("PopulationStructs.jl")
include("PatchesConstants.jl")
using ..PopulationStructs: Individual, Patch, Gamete 
using Distributions: Normal
using .const
function migration(population::Vector{Patch})::Vector{Patch}
    next_population::Vector{Patch} = [Patch([],population[i].sex,population[i].patch_number)
                                      for i=eachindex(population)]
    #migration one by one:

    #for each patch
        #for each individual
            #move the individual from index i in the current population to index i + norm(something) in the next popualtion
    function put_within_boundaries(patch_number,signed_distance)
        new_patch::Int64 = patch_number + signed_distance
        if new_patch <= 0
            return 1
        elseif new_patch > number_of_patches
            return number_of_patches
        else 
            return new_patch
        end
    end
    
    function migrate_one_individual(population::Vector{Patch},next_population::Vector{Patch})
        individual::Individual=population[1].individuals[1]
        signed_distance::Int64 = Int(round(rand(Normal(0,1.5),1)[1]))
        deleteat!(population[1].individuals,1)
        
        #Boundary condition: if the individual tries to go outside the area, it doesn't move
        new_patch = put_within_boundaries(population[1].patch_number,signed_distance)
        append!(next_population[new_patch].individuals,[individual])  
        if length(population[1].individuals) == 0
            deleteat!(population,1)
        end
        return population,next_population
    end
    
    #we should be able to do tail recursion here
    function migrate(population::Vector{Patch},next_population::Vector{Patch})
        if population == []
            return next_population
        else
            return migrate(migrate_one_individual(population,next_population)...)
        end
    end

    return migrate(population,next_population)
end
export migration

end
