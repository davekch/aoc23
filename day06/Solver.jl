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
# d(x) > r -> find zeros of d - r

distance(x, T) = x * (T - x)

function find_zeros(time, record)
    x1 = (time-sqrt(time^2-4record)) / 2
    x2 = (time+sqrt(time^2-4record)) / 2
    Int(floor(x1+1)), Int(ceil(x2-1))
end


function solve1((times, distances))
    solution = 1
    for (t, d) in zip(times, distances)
        x1, x2 = find_zeros(t, d)
        breaks_record = x2 - x1 + 1
        solution *= breaks_record
    end
    solution
end
export solve1


function solve2((times, distances))
    t = map(string, times) |> prod |> int
    d = map(string, distances) |> prod |> int
    x1, x2 = find_zeros(t, d)
    x2 - x1 + 1
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
