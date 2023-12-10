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
    loop = Dict{Point2D, Char}()
    current = start
    while grid[current] != 'S' || length(loop) == 0
        loop[current] = grid[current]
        next = [n for n in neighbours(grid, current) if n ∉ keys(loop)]
        # println("$current => $(grid[current])")
        # println(next)
        if length(next) == 0
            break
        end
        current = next[1]
    end
    loop[start] = '|'   # this is specific to my input
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


function solve2(loop)
    minx, maxx, miny, maxy = corners(keys(loop))
    area = 0
    inside = false
    lastturn = nothing  # when moving along a horizontal pipe, keep the last turn
    for y in miny:maxy, x in minx:maxx
        p = Point2D(x, y)
        if p ∉ keys(loop) && inside
            area += 1
        elseif p ∈ keys(loop)
            c = loop[p]
            if c == '|'
                # we pass a vertical pipe
                inside = !inside
            elseif c ∈ "FL"  # any of the corners that open to the right
                lastturn = c
            elseif c ∈ "7J"  # any of the corners that open to the left
                if (c == 'J' && lastturn == 'F') || (c == '7' && lastturn == 'L')
                    inside = !inside
                end
                lastturn = nothing
            end
        end
    end
    area
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

testinput2 = """
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
"""

testinput3 = """
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
"""

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
