module Solver
using Test
using AoC
using AoC.Utils


function parse_input(raw_data)
    map(ints, raw_data|>strip|>lines)
end
export parse_input


# let d = traveled distance, T = duration of race, x = ms to hold the button
# d(x) = v*t = x*(T-x)
# d(x) > a -> find zeros of d - a // brute force probably also fast enough

distance(x, T) = x * (T - x)

function solve1((times, distances))
    # brute force
    solution = 1
    for (t, d) in zip(times, distances)
        breaks_record = 0
        for x = 0:t
            dd = distance(x, t)
            if dd > d
                breaks_record += 1
            end
        end
        solution *= breaks_record
    end
    solution
end
export solve1


function solve2((times, distances))
    t = map(string, times) |> prod |> int
    d = map(string, distances) |> prod |> int
    breaks_record = 0
    for x = 0:t
        dd = distance(x, t)
        if dd > d
            breaks_record += 1
        end
    end
    breaks_record
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """Time:      7  15   30
Distance:  9  40  200
"""
testanswer_1 = 288
testanswer_2 = 71503
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
