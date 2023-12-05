module Solver
using Test
using AoC
using AoC.Utils

const Map = Vector{Vector{Pair{UnitRange, UnitRange}}}

function parse_input(raw_data)
    blocks = split(raw_data, "\n\n")
    seeds = ints(blocks[1])
    maps::Map = []
    for block in blocks[2:end]
        ranges = []
        for line in lines(block)[2:end]
            dest, source, l = ints(line)
            push!(ranges, (source:source+l-1)=>(dest:dest+l-1))
        end
        push!(maps, ranges)
    end
    (seeds, maps)
end
export parse_input


function solve1((seeds, maps))
    locations = []
    for seed in seeds
        current = seed
        for map in maps
            for (source, destination) in map
                if current in source
                    current = destination.start + (current - source.start)
                    break
                end
            end
        end
        push!(locations, current)
    end
    minimum(locations)
end
export solve1


function solve2((seeds, maps))
    location = Inf
    for (seedstart, len) in Iterators.partition(seeds, 2)
        println("working on $seedstart - $(seedstart+len-1)")
        for seed in seedstart:seedstart+len-1
            if seed % 500000 == 0
                println("   $(seedstart+len-1-seed) left to go")
            end
            current = seed
            for map in maps
                for (source, destination) in map
                    if current in source
                        current = destination.start + (current - source.start)
                        break
                    end
                end
            end
            if current < location
                location = current
            end
        end
    end
    location
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"""
testanswer_1 = 35
testanswer_2 = 46
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
