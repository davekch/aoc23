module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry
using DataStructures


function parse_input(raw_data)
    rocks = Set{Point2D}()
    start = Point2D(1, 1)  # initial value
    for (y, line) in raw_data |> strip |> lines |> enumerate
        for (x, c) in line |> enumerate
            if c == '#'
                push!(rocks, Point2D(x, y))
            elseif c == 'S'
                start = Point2D(x, y)
            end
        end
    end
    start, rocks
end
export parse_input


function solve(nsteps, (start, rocks))
    reached = 0
    current = start
    q = Set{Point2D}()
    push!(q, current)
    for i = 1:nsteps
        newq = Set{Point2D}()
        while !isempty(q)
            current = pop!(q)
            for n ∈ neighbours4(current)
                if n ∉ rocks
                    push!(newq, n)
                end
            end
        end
        reached = length(newq)
        q = newq
    end
    reached
end


function solve1(parsed)
    solve(64, parsed)
end
export solve1


function solve2(parsed)
end
export solve2


solution = Solution(parse_input, solve1, solve2)
testsolution = Solution(parse_input, p -> solve(6, p), solve2)

testinput = """...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
"""
testanswer_1 = 16
testanswer_2 = nothing
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(testsolution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
