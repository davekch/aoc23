module Solver
using Test
using AoC
using AoC.Utils
import DataStructures: OrderedDict


function parse_input(raw_data)
    split(raw_data |> strip, ",")
end
export parse_input


function hash(s)
    current = 0
    for c in s
        current += Int(c)
        current *= 17
        current = current % 256
    end
    current
end


function solve1(parsed)
    map(hash, parsed) |> sum
end
export solve1


function solve2(parsed)
    boxes = [OrderedDict{String, Int}() for _ in 0:255]
    for instruction in parsed
        if '=' in instruction
            label, n = split(instruction, "=")
            box_idx = hash(label) + 1  # julia is 1-indexed
            # replaces existing labels, adds new ones to the end
            boxes[box_idx][label] = int(n)
        elseif '-' in instruction
            label = instruction[1:end-1]
            box_idx = hash(label) + 1
            pop!(boxes[box_idx], label, nothing)
        end
    end
    result = 0
    for (i, box) in boxes |> enumerate
        for (s, f) in values(box) |> enumerate
            result += i * s * f
        end
    end
    result
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
"""
testanswer_1 = 1320
testanswer_2 = 145
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
