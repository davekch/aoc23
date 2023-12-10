module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry


function parse_input(raw_data)
    start = missing
    grid = Dict{Point2D,Char}()
    for (y, line) in raw_data |> strip |> lines |> enumerate
        for (x, c) in line |> enumerate
            if c == '.'
                continue
            elseif c == 'S'
                start = Point2D(x, y)
            end
            grid[Point2D(x,y)] = c
        end
    end
    # find points on the loop
    # the loop is closed and there can be no branches (all pipe elements only have
    # two ends) so we can just walk from the start
    loop = []
    current = start
    while grid[current] != 'S' || length(loop) == 0
        push!(loop, current)
        next = [n for n in neighbours(grid, current) if n ∉ loop]
        # println("$current => $(grid[current])")
        # println(next)
        if length(next) == 0
            break
        end
        current = next[1]
    end
    loop
end
export parse_input


"""
get a list of relative points that a pipe leads to, eg F -> (0,1), (1,0)
"""
function leads_to(c)
    if c == '-'
        [Point2D(-1,0), Point2D(1,0)]
    elseif c == '|'
        [Point2D(0,1), Point2D(0,-1)]
    elseif c == 'F'
        [Point2D(0,1), Point2D(1,0)]
    elseif c == '7'
        [Point2D(0,1), Point2D(-1,0)]
    elseif c == 'L'
        [Point2D(0,-1), Point2D(1,0)]
    elseif c == 'J'
        [Point2D(-1,0), Point2D(0,-1)]
    else
        []
    end
end


function neighbours(grid, p)
    # special treatment for starting point
    if grid[p] == 'S'
        [n for n in neighbours4(p) if n ∈ keys(grid) && p-n ∈ leads_to(grid[n])]
    else
        # now go for regular points
        [p + dp for dp in leads_to(grid[p]) if (p + dp) ∈ keys(grid)]
    end
end


function solve1(loop)
    return Int(length(loop) // 2)
end
export solve1


function solve2(parsed)
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
"""
testanswer_1 = 8
testanswer_2 = nothing
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
