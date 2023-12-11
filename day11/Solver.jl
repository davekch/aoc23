module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry
import Combinatorics: combinations


function parse_input(raw_data)
    galaxies = Vector{Point2D}()
    for (y, line) in raw_data |> strip |> lines |> enumerate
        for (x, c) in line |> enumerate
            if c == '#'
                push!(galaxies, Point2D(x, y))
            end
        end
    end
    galaxies
end
export parse_input


function solve(galaxies)
    result1 = 0
    result2 = 0
    # find empty rows and columns
    minx, maxx, miny, maxy = corners(galaxies)
    expandx = [x for x in minx:maxx if !any([g.x == x for g in galaxies])]
    expandy = [y for y in miny:maxy if !any([g.y == y for g in galaxies])]
    # calculate distances
    for (g1, g2) in combinations(galaxies, 2)
        x1 = min(g1.x, g2.x)
        x2 = max(g1.x, g2.x)
        y1 = min(g1.y, g2.y)
        y2 = max(g1.y, g2.y)
        d = x2-x1 + y2-y1
        result1 += d
        result2 += d
        # for every empty row and column between g1 and g2, distance grows by 1 or 99999
        emptyx = filter(x->x1<x<x2, expandx) |> length
        emptyy = filter(y->y1<y<y2, expandy) |> length
        result1 += emptyx + emptyy
        result2 += (emptyx + emptyy) * 99999
    end
    result1, result2
end


solution = Solution(parse_input, solve)

testinput = """...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
"""
testanswer_1 = 374
testanswer_2 = nothing
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
