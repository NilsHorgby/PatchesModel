module Mating
include("PopulationStructs.jl")
include("PatchesConstants.jl")
using ..PopulationStructs: Individual, Patch, Gamete 
using StatsBase: sample
using .const
export random_mating

#randomly permuate the input patch
#this needs to bootstrap the popualtion up to a constant size
function random_parent(population::Patch)::Patch
    indecies = sample(1:length(population.individuals), individuals_per_patch)
    return Patch(population.individuals[indecies],
                 population.sex,
                 population.patch_number)
end

#input - one individual
#output - a random selection of half the allels in a gamete
function mieosis(individual::Individual)::Gamete
    #introduce sex-specific behavior
    random_allele=rand(0:1,number_of_loci)
    genome = individual.genome[number_of_loci*random_allele+Vector(1:number_of_loci)]
    gamete = Gamete(individual.id,individual.sex,genome)
    return gamete
end

#input - one individual
#output - many gametes
function gamete_production(individual)
    return [mieosis(individual) for _=1:100]
end

#input - A vector of gametes and an individual
#output - A vector of gametes including the gametes of the individual
function vcat_gamete_production(gametes, individual)
    return vcat(gametes, gamete_production(individual))
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
end


