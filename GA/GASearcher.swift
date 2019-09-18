//
//  GASearch.swift
//  GA
//
//  Created by Jon Tingvold on 05.02.2016.
//  Copyright © 2016 Jon Tingvold. All rights reserved.
//

import Foundation

typealias Parent = (mother: Phenotype, father: Phenotype)
typealias Parents = [Parent]

enum AdultSelectionStrategy {
    case FullGenerationReplacement
    case OverProduction
    case GenerationMixing
}

enum MatingSelectionStrategy {
    case ProportionalScaling
    case SigmaScaling
    case BolzmannScaling
    case UniformScaling
    case TournamentSelection
    case NOTIMPLEMENTED
}

struct GenerationStatistics: CustomStringConvertible {
    var generation: Int
    var bestIndividual: Phenotype
    var bestFitness: Double
    var avgFitness: Double
    var stdFitness: Double
    var foundGoalState: Bool
    
    var description: String {
        return asCSV
    }
    
    var asCSV: String {
        return "\(generation), \(bestFitness.f3()), \(avgFitness.f3()), \(stdFitness.f3())"
    }
}

enum SimulationType {
    case Dynamic
    case Static
}

class GASearcher {
    var maxGenerations: Int
    var populationSize: Int
    var numberOfChildren: Int
    
    var adultSelectionStrategy: AdultSelectionStrategy
    var matingSelectionStrategy: MatingSelectionStrategy
    
    //Bolzmann Mating Strategy Settings
    var bolzmannSelectionTemperatur: Double
    var bolzmannTemperaturRateFallPerGeneration: Double
    // Tournament Mating Strategy Settings
    //      High tournamentSize and low probability gives hight selection pressure
    var tournamentSize: Int
    var tournamentProbabilityOfChoosingRandom: Double
    
    var crossoverProbability: Double
    
    var gtype: Genotype.Type
    var ptype: Phenotype.Type
    
    var simulationType: SimulationType
    
    var initGenotypes = [Genotype]()
    
    init() {
        FlatlandGenotype.layers = [6, 30, 3]
        FlatlandGenotype.length = ANN.totalNumberOfWeights(FlatlandGenotype.layers)
        
        simulationType = .Dynamic
        
        maxGenerations = 50
        populationSize = 20
        numberOfChildren = populationSize / 3 * 2
        
        adultSelectionStrategy = .GenerationMixing
        matingSelectionStrategy = .SigmaScaling
        
        //Bolzmann Mating Strategy Settings
        bolzmannSelectionTemperatur = 100
        bolzmannTemperaturRateFallPerGeneration = 0.10
        // Tournament Mating Strategy Settings
        //      High tournamentSize and low probability gives hight selection pressure
        tournamentSize = 2
        tournamentProbabilityOfChoosingRandom = 0.25
        
        crossoverProbability = 0.80
        FlatlandGenotype.mutationProbability = 0.02
        FlatlandGenotype.mutationStd = 0.3
        
        gtype = FlatlandGenotype.self
        ptype = FlatlandPhenotype.self
        
        newGenotypes = (0..<populationSize).map { _ in
            gtype.init()
        }
        
        population = develop(newGenotypes)
    }
    
    var newGenotypes = [Genotype]()
    var population = [Phenotype]()
    var generation_i = 0
    var generationStatistics = [GenerationStatistics]()
    
    func run() {
        while true {
            evolveOneGeneration()
            
            if generationStatistics.last!.foundGoalState {
                break
            }
            
            if generation_i >= maxGenerations {
                print("Reached max number of generations.")
                break
            }
            
            // Continoue
            generation_i += 1
        }
    }
    
    func evolveOneGeneration() {
        if simulationType == .Dynamic {
            FlatlandPhenotype.generateNewScenarios()
        }
        
        let children = develop(newGenotypes)
        population = adultSelection(children, adultPhenotypes: population)
        
        generationStatistics.append(getStatistics(population, generation: generation_i))
        print(generationStatistics.last!.asCSV)
        //printWholePopulation(population)
        
        let parents = matingSelection(population, generation: generation_i)
        newGenotypes = makeChildren(parents)
    }
    
    func develop(genotypes: [Genotype]) -> [Phenotype] {
        /*
        PARALLELL OPTIMALIZATION. DOES NOT OPTIMIZE MUCH IF NOT FITNESS IS VERY HEAVY TO RUN.
         
        let group = dispatch_group_create()
        let queue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        
        var phenotypes = Array<Phenotype?>(count: genotypes.count, repeatedValue: nil)
        
        for i in 0 ..< genotypes.count {
            dispatch_group_async(group, queue, {
                phenotypes[i] = self.ptype.init(genotype: genotypes[i])
            })
        }
    
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        let phenotypesNoOptionals: [Phenotype] = phenotypes.map { $0! }
        
        return phenotypesNoOptionals
         */
        let phenotypes = genotypes.map {
            return ptype.init(genotype: $0)
        }
        return phenotypes
    }

    func adultSelection(newPhenotypes: [Phenotype], adultPhenotypes: [Phenotype]) -> [Phenotype] {
        
        switch adultSelectionStrategy {
        
        case .FullGenerationReplacement:
            return newPhenotypes
            
        case .OverProduction:
            let kBest = kBestSelection(newPhenotypes, k: populationSize)
            return kBest
            
        case .GenerationMixing:
            let kBestAdults = kBestSelection(adultPhenotypes, k: populationSize)
            let combinedPhenotypes = newPhenotypes + kBestAdults
            let kBest = kBestSelection(combinedPhenotypes, k: populationSize)
            return kBest
            
        }
    }
    
    func matingSelection(population: [Phenotype], generation: Int) -> Parents {
        
        let fitnessDistribution = population.map { $0.fitness }
        
        switch matingSelectionStrategy {
        
        case .ProportionalScaling:
            let propDist = proportionalDistribution(fitnessDistribution)
            return getRandomParents(population, distribution: propDist, numberOfChildren: numberOfChildren)
            
        case .SigmaScaling:
            let sigmaDist = sigmaDistribution(fitnessDistribution)
            return getRandomParents(population, distribution: sigmaDist, numberOfChildren: numberOfChildren)
        
        case .BolzmannScaling:
            let bolzmannDist = bolzmannSelectionDistribution(fitnessDistribution,
                                                    generation: generation)
            return getRandomParents(population, distribution: bolzmannDist, numberOfChildren: numberOfChildren)
            
        case .UniformScaling:
            let uniformDist = uniformDistribution(fitnessDistribution.count)
            return getRandomParents(population, distribution: uniformDist, numberOfChildren: numberOfChildren)
            
        case .TournamentSelection:
            return getRandomParentsWithTournamentSelection(population)
            
        default:
            print("Error: Case not implemented")
            return Parents()
        }
    }
    
    func proportionalDistribution(distribution: [Double]) -> [Double] {
        let sum = distribution.reduce(0.0, combine: +)
        let propotionalDistribution = distribution.map {
            return $0 / sum
        }
        
        return propotionalDistribution
    }
    
    func uniformDistribution(numberOfElements: Int) -> [Double] {
        let uniformDistribution = [Double](count: numberOfElements, repeatedValue: 1.0/Double(numberOfElements))
        return uniformDistribution
    }
    
    func sigmaDistribution(distribution: [Double]) -> [Double] {
        let avg = σ.average(distribution)!
        let std = σ.standardDeviationSample(distribution)!
        let sigmaDistribution: [Double] = distribution.map {
            if(std != 0) {
                return max(1 + ($0 - avg)/(2 * std), 0)
            } else {
                return $0
            }
        }
        return sigmaDistribution
    }
    
    func getTemperatur(time time: Double) -> Double {
        let fallRate = bolzmannTemperaturRateFallPerGeneration
        let k = exp(-1.0 * fallRate * time)
        return bolzmannSelectionTemperatur * k
    }
    
    func bolzmannSelectionDistribution(distribution: [Double], generation: Int) -> [Double] {
        let expTempDistribution: [Double] = distribution.map {
            let temp = getTemperatur(time: Double(generation))
            let tempScaledValue = exp($0 / (temp + 0.001))
            return tempScaledValue
        }
        let bolzmannSelectionDistribution = proportionalDistribution(expTempDistribution)
        return bolzmannSelectionDistribution
    }
    
    func getRandomParents(population: [Phenotype], distribution: [Double], numberOfChildren: Int)
        -> Parents {
        
        let randomParents: Parents = (0..<numberOfChildren).map { _ in
            let mother = getRandomIndividual(population, distribution: distribution)
            let father = getRandomIndividual(population, distribution: distribution)
            
            return (mother: mother, father: father)
        }
            
        return randomParents
    }
    
    func getRandomIndividual(population: [Phenotype], distribution: [Double]) -> Phenotype {
        let randomIndex = GASearcher.drawRandom(distribution)
        let randomIndividual = population[randomIndex]
        return randomIndividual
    }
    
    static func drawRandom(distribution: [Double]) -> Int {
        let sum = distribution.reduce(0.0, combine: +)
        let random = Random.double() * sum
        
        var countedTo = Double(0.0)
        
        for i in 0..<distribution.count {
            countedTo = countedTo + distribution[i]
            if countedTo >= random {
                let indexOfRandomPickedElement = i
                
                return indexOfRandomPickedElement
            }
        }
        
        print("Error")
        return Int.max
    }
    
    func getRandomParentsWithTournamentSelection(population: [Phenotype]) -> Parents {
        let randomParents: Parents = (0..<numberOfChildren).map { _ in
            let mother = tournamentSelection(population)
            let father = tournamentSelection(population)
            
            return (mother: mother, father: father)
        }
        
        return randomParents
    }
    
    func tournamentSelection(population: [Phenotype]) -> Phenotype {
        let uniformDist = uniformDistribution(population.count)
        
        let chooseRandom = Random.double() < tournamentProbabilityOfChoosingRandom
        
        var k: Int
        if chooseRandom { k = 1 } else { k = tournamentSize }
            
        let kIndividuals: [Phenotype] = (0..<k).map { _ in
            return getRandomIndividual(population, distribution: uniformDist)
        }
        
        return kBestSelection(kIndividuals, k: 1).first!
    }
    
    func makeChildren(parents: Parents) -> [Genotype]{
        let newGenotypes: [Genotype] = parents.map {
            var child: Genotype
            let doCrossover = Random.isTrue(probability: crossoverProbability)
            if(doCrossover) {
                child = gtype.init(mother: $0.mother.genotype, father: $0.father.genotype)
            } else {
                child = gtype.init(genotype: $0.mother.genotype) // Or father
            }
            
            return child
        }
        
        return newGenotypes
    }

    func filterGoalPhenotypes(genotypes: [Phenotype]) -> [Phenotype] {
        return genotypes.filter { $0.isGoalState }
    }
    
    func kBestSelection(population: [Phenotype], k: Int) -> [Phenotype] {
        if(k < population.count) {
            let sortedPopulation = sortedByFitness(population)
            let kBest = [Phenotype](sortedPopulation[0..<k])
            return kBest
            
        } else {
            let kBest = population
            return kBest
        }
    }
    
    func sortedByFitness(population: [Phenotype]) -> [Phenotype] {
        return population.sort {
            $0.fitness > $1.fitness
        }
    }
    
    func getStatistics(population: [Phenotype], generation: Int) -> GenerationStatistics {
        let fitnesses = population.map { $0.fitness }
        let sortedPopulation = sortedByFitness(population)
        let bestIndividual = sortedPopulation[0]
        
        let statistics = GenerationStatistics(
            generation: generation,
            bestIndividual: bestIndividual,
            bestFitness: bestIndividual.fitness,
            avgFitness: σ.average(fitnesses)!,
            stdFitness: σ.standardDeviationSample(fitnesses)!,
            foundGoalState: filterGoalPhenotypes(population).count != 0
        )
        
        return statistics
    }
    
    func printWholePopulation(population: [Phenotype]) {
        for individ in sortedByFitness(population) {
            print(individ, individ.fitness.f3())
        }
    }
}
