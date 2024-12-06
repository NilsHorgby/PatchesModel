
include("PopulationStructs.jl")
include("PatchesConstants.jl")
using .PopulationStructs
using StatsBase: sample
using .const

#Individual: id: Int, genome: BitArray, sex: String
#Gamete: id: Int, genome: BitVector, sex: String
#patch: individuals: Vector{Individual}, Sex: String, patch_number: Int


#randomly permuate the input patch
#this needs to bootstrap the popualtion up to a constant size
function random_parent(population::Patch)::Patch
    return Patch(permute!(population.individuals,1:males_per_patch),
                 population.sex,
                 population.patch_number)
end

#input - one individual
#output - a random selection of half the allels in a gamete
function mieosis(individual::Individual)::Gamete
    #introduce sex-specific behavior
    random_allele = rand(0:1,number_of_loci)
    genome = individual.genome[number_of_loci*random_allele+Vector(1:number_of_loci)]
    gamete = Gamete(individual.id,individual.sex,genome)
    return gamete
end

#input - one individual
#output - many gametes
function gamete_production(individual)
    return [mieosis(individual) for _=1:100]
end

#input - A vector of individuals, length N
#output - A vector of gametes, length 100N
function broadcast_gamete_production(population)
    gametes = Vector{Gamete}(undef, length(population) * 100)
    for i in eachindex(population)
        gametes[100*(i-1)+1:100*i] = gamete_production(population[i])
    end
    return gametes
end

#input - one male and one female gamete
#output - one offspring
function fertilize(male_gamete,female_gamete)
    offspring_id = male_gamete.id #Could change to something where both parents are kept track of, this would very quicly require a lot of data (exponential growth)
    offspring_genome = hcat(male_gamete.genome,female_gamete.genome)
    offspring_sex = rand(["male","female"])
    return Individual(offspring_id,offspring_sex,offspring_genome)
end


function random_mating(males::Patch,females::Patch)::Tuple{Patch,Patch}
    #selecting male and females from the current patch
    male_gametes::Vector{Gamete} = broadcast_gamete_production(random_parent(males).individuals)
    female_gametes::Vector{Gamete} = broadcast_gamete_production(random_parent(females).individuals)


    mixed_offspring = fertilize.(female_gametes,male_gametes)

    male_offspring = Patch(filter((Ind) -> Ind.sex == "male",mixed_offspring),
                        "male",
                        males.patch_number)
    female_offspring = Patch(filter((Ind) -> Ind.sex == "female",mixed_offspring),
                            "female",
                            females.patch_number)
    return male_offspring,female_offspring
end

male_population = [Patch([Individual(j + (i-1)*males_per_patch,"male",rand([0,1],(number_of_loci,2)))
                          for j=1:males_per_patch],"male",i) 
                   for i=1:number_of_patches]
female_population = [Patch([Individual(j + (i-1)*males_per_patch,"female",rand([0,1],(number_of_loci,2)))
                            for j=1:females_per_patch],"female",i)
                    for i=1:number_of_patches]
population = (male_population,female_population)

using BenchmarkTools

@benchmark random_mating(male_population[1], female_population[1])


