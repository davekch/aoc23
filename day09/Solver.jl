module Solver
using Test
using AoC
using AoC.Utils
import Base: diff


function parse_input(raw_data)
    map(ints, lines(raw_data|>strip))
end
export parse_input


function solve1(parsed)
    result = 0
    for nums in parsed
        extrapolated = nums[end]
        diffs = diff(nums)
        extrapolated += diffs[end]
        while !all(diffs .== 0)
            diffs = diff(diffs)
            extrapolated += diffs[end]
        end
        result += extrapolated
    end
    result
end
export solve1


function solve2(parsed)
    result = 0
    for nums in parsed
        extrapolated = nums[1]
        diffs = diff(nums)
        # the calculation for `extrapolated` has the form
        # a - (b - (c - (d - e))) which can be simplified to
        # a - b + c - d + e so when iterating over the layers of diffs,
        # the sign of the number to be added must oscillate
        neg = -1
        extrapolated += neg*diffs[1]
        while !all(diffs .== 0)
            diffs = diff(diffs)
            neg *= -1
            extrapolated += neg*diffs[1]
        end
        result += extrapolated
    end
    result
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"""
testanswer_1 = 114
testanswer_2 = 2
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
