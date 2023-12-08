module Solver
using Test
using AoC
using AoC.Utils


function parse_input(raw_data)
    instructions, block = split(raw_data|>strip, "\n\n")
    tree = Dict()
    for line in split(block, "\n")
        node, rest = split(line, " = ")
        left, right = split(rest[2:end-1], ", ")
        tree[node] = (left, right)
    end
    # convert RL to [2, 1] (indices in the tuple)
    instructions = map(int, replace(instructions, "L"=>"1", "R"=>"2")|>collect)
    (instructions, tree)
end
export parse_input


function solve1((instructions, tree))
    steps = 0
    l = length(instructions)
    current = "AAA"
    while (current = tree[current][instructions[steps%l+1]]) != "ZZZ"
        steps += 1
    end
    steps + 1
end
export solve1


function solve2((instructions, tree))
    l = length(instructions)
    currents = [n for n in keys(tree) if n[end] == 'A']
    all_steps = Int[]
    for current in currents
        steps = 0
        while current[end] != 'Z'
            current = tree[current][instructions[steps%l+1]]
            steps += 1
        end
        push!(all_steps, steps)
    end
    lcm(all_steps)
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
"""
testanswer_1 = 6
testanswer_2 = nothing
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

testinput2 = """LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
"""

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
