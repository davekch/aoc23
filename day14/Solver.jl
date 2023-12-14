module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry
using Bijections


function parse_input(raw_data)
    fixed = Set{Point2D}()
    movable = Set{Point2D}()
    for (y, line) in raw_data |> strip |> lines |> enumerate
        for (x, c) in line |> enumerate
            if c == '#'
                push!(fixed, Point2D(x-1, y-1))   # coordinate system should be 0-indexed
            elseif c == 'O'
                push!(movable, Point2D(x-1, y-1))
            end
        end
    end
    fixed, movable
end
export parse_input


function all_north(fixed, movable)
    moved = Set{Point2D}()
    cur_grid = fixed ∪ moved
    for p in sort(movable|>collect, by=p->p.y)
        northest_y = 0
        # find closest y north to this point
        for y = p.y:-1:0
            if Point2D(p.x, y) ∈ cur_grid #&& Point2D(p.x, y+1) ∉ cur_grid
                northest_y = y + 1
                break
            end
        end
        push!(moved, Point2D(p.x, northest_y))
        push!(cur_grid, Point2D(p.x, northest_y))
    end
    moved
end
export all_north


function rotate(points, center)
    # rotate clockwise; that's a left turn in lefthanded coordinate system
    rot90l.(points .- center) .+ center
end
export rotate


function solve1((fixed, moved))
    moved = all_north(fixed, moved)
    _,_,_,maxy = corners(fixed ∪ moved)
    sum([maxy + 1 - p.y for p in moved])
end
export solve1


function solve2((fixed, moved))
    _,maxx,_,maxy = corners(fixed ∪ moved)
    center = Point2D((maxx+1)÷2, (maxy+1)÷2)
    seen = Bijection()
    loop_start = 0
    loop_end = 0
    for i = 1:1000000000
        # if i % 10 == 0
        #     println("$i ($(i/1000000000))%)")
        # end
        for _ = 1:4
            moved = all_north(fixed, moved)
            moved = rotate(moved, center)
            fixed = rotate(fixed, center)
        end
        # prettyprint(fixed, moved)
        # convert grid to string to store it in a hashtable
        serialized = grid_to_string(Dict(moved.=>'O'))
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
    println((loop_start, loop_end))
    _, moved = parse_input(seen(final_index))
    sum([maxy + 1 - p.y for p in moved])
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


# -------- helpers
function prettyprint(fixed, moved)
    grid = Dict(Dict(fixed.=>'#') ∪ Dict(moved.=>'O'))
    println(grid_to_string(grid))
end
export prettyprint

end # module Solver
