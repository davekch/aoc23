module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry
using Bijections


function parse_input(raw_data)
    grid = Dict{Point2D, Char}()
    for (y, line) in raw_data |> strip |> lines |> enumerate
        for (x, c) in line |> enumerate
            if c == '#' || c == 'O'
                grid[Point2D(x, y)] = c
            end
        end
    end
    grid
end
export parse_input


function all_north(grid)
    moved = Dict{Point2D, Char}()
    for p in sort(keys(grid)|>collect, by=p->p.y)
        # it's important to have a loop over sorted y to ensure we fill the moved
        # grid from top to bottom
        if grid[p] == '#'
            # does not move
            moved[p] = grid[p]
        else
            # should be as far up north as possible
            northest_y = 1
            ys = [pp.y for pp in keys(moved) if pp.x == p.x]
            if length(ys) > 0
                northest_y = maximum(ys) + 1
            end
            moved[Point2D(p.x, northest_y)] = grid[p]
        end
        # println(grid_to_string(moved))
    end
    moved
end

function all_south(grid, southest)
    moved = Dict{Point2D, Char}()
    for p in sort(keys(grid)|>collect, by=p->p.y, rev=true)
        # loop over reversed sorted y to ensure we fill the moved
        # grid from bottom to top
        if grid[p] == '#'
            # does not move
            moved[p] = grid[p]
        else
            # should be as far down south as possible
            southest_y = southest
            ys = [pp.y for pp in keys(moved) if pp.x == p.x]
            if length(ys) > 0
                southest_y = minimum(ys) - 1
            end
            moved[Point2D(p.x, southest_y)] = grid[p]
        end
        # println(grid_to_string(moved))
    end
    moved
end

function all_west(grid)
    moved = Dict{Point2D, Char}()
    for p in sort(keys(grid)|>collect, by=p->p.x)
        # loop over sorted x to ensure we fill the moved
        # grid from left to right
        if grid[p] == '#'
            # does not move
            moved[p] = grid[p]
        else
            # should be as far west as possible
            westest_x = 1
            xs = [pp.x for pp in keys(moved) if pp.y == p.y]
            if length(xs) > 0
                westest_x = maximum(xs) + 1
            end
            moved[Point2D(westest_x, p.y)] = grid[p]
        end
        # println(grid_to_string(moved))
    end
    moved
end

function all_east(grid, eastest)
    moved = Dict{Point2D, Char}()
    for p in sort(keys(grid)|>collect, by=p->p.x, rev=true)
        # loop over reversed sorted x to ensure we fill the moved
        # grid from right to left
        if grid[p] == '#'
            # does not move
            moved[p] = grid[p]
        else
            # should be as far east as possible
            eastest_x = eastest
            xs = [pp.x for pp in keys(moved) if pp.y == p.y]
            if length(xs) > 0
                eastest_x = minimum(xs) - 1
            end
            moved[Point2D(eastest_x, p.y)] = grid[p]
        end
        # println(grid_to_string(moved))
    end
    moved
end


function solve1(parsed)
    moved = all_north(parsed)
    _,_,_,maxy = corners(keys(parsed))
    result = 0
    for (p, c) in moved
        if c == 'O'
            result += maxy - p.y + 1
        end
    end
    result
end
export solve1


function solve2(grid)
    _,maxx,_,maxy = corners(keys(grid))
    seen = Bijection()
    loop_start = 0
    loop_end = 0
    for i = 1:1000000000
        # if i % 10 == 0
        #     println("$i ($(i/1000000000))%)")
        # end
        grid = all_north(grid)
        grid = all_west(grid)
        grid = all_south(grid, maxy)
        grid = all_east(grid, maxx)
        serialized = grid_to_string(grid)
        # println(serialized)
        if serialized in keys(seen)
            loop_start = seen[serialized]
            loop_end = i
            break
        else
            seen[serialized] = i
        end
    end
    final_index = (1000000000 - loop_start) % (loop_end - loop_start) + loop_start
    # println((loop_start, loop_end))
    grid = parse_input(seen(final_index))
    result = 0
    for (p, c) in grid
        if c == 'O'
            result += maxy - p.y + 1
        end
    end
    result
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
"""
testanswer_1 = 136
testanswer_2 = 64
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
