module Solver
using Test
using AoC
using AoC.Utils


const RGB = Vector{Int}

function parse_input(raw_data)
    games::Vector{Tuple{Int, Vector{RGB}}} = []
    for line in lines(raw_data|>strip)
        p1, p2 = split(line, ": ")
        ID = int(split(p1, " ")[2])
        sets_unparsed = split(p2, "; ")
        sets::Vector{RGB} = []
        for s in sets_unparsed
            red = green = blue = 0
            if (r = match(r"[0-9]+ red", s)) !== nothing
                red = int(split(r.match, " ")[1])
            end
            if (g = match(r"[0-9]+ green", s)) !== nothing
                green = int(split(g.match, " ")[1])
            end
            if (b = match(r"[0-9]+ blue", s)) !== nothing
                blue = int(split(b.match, " ")[1])
            end
            push!(sets, [red, green, blue])
        end
        push!(games, (ID, sets))
    end
    games
end


function solve1(parsed)
    n = 0
    for (ID, sets) in parsed
        if !any([any(s .> [12, 13, 14]) for s in sets])
            n += ID
        end
    end
    n
end


function solve2(parsed)
    power = 0
    for (ID, sets) in parsed
        colors = stack(sets)  # converts vector of vector to matrix
        minred = maximum(colors[1, :])
        mingreen = maximum(colors[2, :])
        minblue = maximum(colors[3, :])
        power += minred * mingreen * minblue
    end
    power
end


solution = Solution(parse_input, solve1, solve2)

testinput = """Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"""
testanswer_1 = 8
testanswer_2 = 2286
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main

end # module Solver
