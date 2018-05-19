# A grammatical evolution playground

This is a [genetic programming](https://en.wikipedia.org/wiki/Genetic_programming) (GP) system inspired by the [grammatical evolution](https://en.wikipedia.org/wiki/Grammatical_evolution) (GE) technique.

Unlike a pure GE system, this one uses a _subtree_ crossover and a _subtree-local_ mutation operator, thus eliminating the destructive effect of (naive) GE genetic operators, and always operates on valid pruned genotypes.

Unlike a classical GP system, this one operates on linear genotypes mapping them to executable phenotypes by applying a grammar-based transformation.

## Santa Fe Trail problem

Santa Fe Trail problem is used as a test problem during the development of the system.

## Running

```
$ swift run
```
