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


"""
add a new mapping to a dict of mappings. override specifies whether
the new mapping takes precedence over existing intervals or not
"""
function add_mapping!((interval, n), mappings, override=false)
    a, b = interval.start, interval.stop
    # check for any intersections with existing intervals
    # if intersections get detected, either a,b get modified or the
    # existing intervals get modified (based on override)
    # the new interval gets added at the end of the function
    for (interval2, m) in mappings |> collect
        c, d = interval2.start, interval2.stop
        if a < c && c < b < d
            # b intersects
            if override
                # (c,d) gets smaller
                pop!(mappings, interval2)
                mappings[b:d] = m
            else
                # (a,b) gets smaller
                b = c
            end
        elseif c < a < d && c < b < d
            # (a,b) is enclosed by (c,d)
            if override
                # (c,d) gets split up
                pop!(mappings, interval2)
                mappings[c:a] = m
                mappigns[b:d] = m
            else
                # nothing to add
                return
            end
        elseif a < c && b > d
            # (a,b) encloses (c,d)
            # ??
        elseif c < a < d && b > d
            # a intersects
            if override
                # (c,d) gets smaller
                pop!(mappings, interval2)
                mappings[c:a] = m
            else
                # (a,b) gets smaller
                a = d
            end
        end
    end
    mappings[a:b] = n
end

"""
reduce maps to a single list of maps
mapping seeds to their final locations
"""
function reduce_maps(maps)
    # finalmaps = []
    finalmaps = Dict()  # maps intervals to the number that gets added
    for map in maps
        # currentmaps = []
        currentmaps = Dict()
        for (source, destination) in map
            a, b = source.start, source.stop
            newintervals = Dict()
            for (interval, n) in finalmaps
                # check if the source interval intersects with any of the destination
                # intervals we have so far
                c, d = interval.start+n, interval.stop+n
                if a < c && c < b < d
                    # b intersects
                    newintervals[c-n:b-n] = n + destination.start - source.start  # this one is certain
                    newintervals[a:b] = destination.start - source.start  # should get overwritten by existing intervals
                elseif c < a < d && c < b < d
                    # (a,b) is enclosed by (c,d)
                    newintervals[a-n:b-n] = n + destination.start - source.start  # certain
                elseif a < c && b > d
                    # (a,b) encloses (c,d)
                    # ??
                elseif c < a < d && b > d
                    # a intersects
                    newintervals[a-n:d-n] = n  + destination.start - source.start  # certain
                    newintervals[a:b] = destination.start - source.start  # not certain
                else
                    # no intersection
                    newintervals[a:b] = destination.start - source.start  # not certain
                end
            end
        end
    end
    finalmaps
end


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
