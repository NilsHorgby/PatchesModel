exit()
include("PatchesConstants.jl")
include("PopulationStructs.jl")
include("Mating.jl")
include("Migration.jl")

include("Selection.jl")

using .Mating, .Migration, .Selection, .PopulationStructs, Distributions, StatsBase, .const


male_population = [Patch([Individual(j + (i-1)*males_per_patch,"male",rand([0,1],(number_of_loci,2)))
                          for j=1:males_per_patch],"male",i) 
                   for i=1:number_of_patches]
female_population = [Patch([Individual(j + (i-1)*males_per_patch,"female",rand([0,1],(number_of_loci,2)))
                            for j=1:females_per_patch],"female",i)
                    for i=1:number_of_patches]
population = (male_population,female_population)
migration(population[1])
random_mating.(male_population,female_population)
male_population

