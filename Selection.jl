module Selection
include("PopulationStructs.jl")
include("PatchesConstants.jl")
using .PopulationStructs,.const
 
export selection, calculate_size, calculate_fittness

const absolute_optimum_size::Int64 = 2
const effect_size::Float64 = absolute_optimum_size/number_of_loci

function calculate_size(individual::Individual)::Float64
    
    genome = individual.genome
    allele_wise_effect = effect_size .* (genome .* 2 .- 1)
    return sum(allele_wise_effect)
end

function calculate_fittness(optimum_size::Float64,size::Float64)::Float64
    inverse_selection_strenght_squared = -((2*absolute_optimum_size)^2)/(2*log(0.7))
    fittness = exp(-((size - optimum_size)^2)/(2*inverse_selection_strenght_squared))
    return fittness
end




function selection(population::Patch, size_after_selection::Int64)::Patch
    #we use the optimum fittness as the refrence
    #s = |ω - 1| 
    #ω = λ/λ_refrence
    #λ = N_born/N_dead
    #N_born = constant::50
    #N_dead = the value we need to calculate
    #N_dead = N_born/λ
    optimum_size = (population.patch_number <= 200) ? 2.0 : -2.0
    fittnesses = calculate_fittness.(calculate_size.(population.individuals),optimum_size)
    reduced_population = Patch(sample(population.individuals,Weights(fittnesses),size_after_selection),
                               population.sex,
                               population.patch_number)
    return reduced_population
end
end