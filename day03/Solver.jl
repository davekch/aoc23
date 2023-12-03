module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry



function parse_input(raw_data)
    grid::Dict{Point2D, Any} = Dict()
    for (y, line) in lines(raw_data|>strip) |> enumerate
        idxs = findall(r"\d+", line)
        # put the whole number at each point where there is a digit
        for idx in idxs
            n = int(line[idx])
            for x in idx
                grid[Point2D(x, y)] = n
            end
        end
        # put the rest into the grid
        for (x, c) in enumerate(line)
            if !isdigit(c)
                grid[Point2D(x, y)] = c
            end
        end
    end
    grid
end


function solve(grid)
    partnum = 0 # part 1
    ratios = 0 # part 2
    for (p, v) in grid
        # println("checking $p, $v:")
        if !(typeof(v) <: Int) && !(v == '.')
            # println("found symbol $v")
            seen = Set()   # don't count numbers twice; this only works if there are no symbols with the same number attached twice
            neighbors = []
            for n in neighbours8(p)
                # println("  checking neighbor $n")
                if n in keys(grid) && typeof(grid[n]) <: Int && !(grid[n] in seen)
                    push!(neighbors, grid[n])
                    push!(seen, grid[n])
                end
            end
            # part 1
            partnum += sum(neighbors)
            # part 2
            if v == '*' && length(neighbors) == 2
                ratios += prod(neighbors)
            end
        end
    end
    (partnum, ratios)
end
export solve


solution = Solution(parse_input, solve)

testinput = """467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...\$.*....
.664.598..
"""
testanswer_1 = 4361
testanswer_2 = 467835
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
