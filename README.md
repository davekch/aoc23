# AoC 2023
My solutions for advent of code 2023 in Julia.

## setup
```bash
git clone  --recursive
```
in a julia repl:
```julia
] activate .
] instantiate
```

## workflow
```bash
source setup.sh
initjl
cd dayDD
julia --project
```
```julia
push!(LOAD_PATH, cwd())
using Revise
using AoC, Solver
# edit Solver.jl
test()
main()
```

