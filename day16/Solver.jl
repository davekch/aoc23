module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry
using DataStructures


function parse_input(raw_data)
    raw_data |> strip |> lines
    # grid = Dict{Point2D, Char}()
    # for (y, line) in raw_data |> strip |> lines |> enumerate
    #     for (x, c) in line |> enumerate
    #         grid[Point2D(x, y)] = c
    #     end
    # end
    # grid
end
export parse_input


"""
move a lightbeam with dir at pos one step forward.
return a list of new (pos, dir) tuples
"""
function move(pos, dir, grid)
    x, y = pos
    dx, dy = dir
    c = grid[y][x]
    if c == '.'
        return [((x+dx, y+dy), dir)]
    elseif c == '-'
        if dir == (1, 0) || dir == (-1, 0)
            return [((x+dx, y), dir)]
        else
            return [((x+1, y), (1, 0)), ((x-1, y), (-1, 0))]
        end
    elseif c == '|'
        if dir == (0, 1) || dir == (0, -1)
            return [((x, y+dy), dir)]
        else
            return [((x, y+1), (0, 1)), ((x, y-1), (0, -1))]
        end
    elseif c == '/'
        if dir == (1, 0)   # right
            return [((x, y-1), (0, -1))]
        elseif dir == (0, 1)  # down
            return [((x-1, y), (-1, 0))]
        elseif dir == (-1, 0)  # left
            return [((x, y+1), (0, 1))]
        elseif dir == (0, -1)  # up
            return [((x+1, y), (1, 0))]
        end
    elseif c == '\\'
        if dir == (1, 0)   # right
            return [((x, y+1), (0, 1))]
        elseif dir == (0, 1)  # down
            return [((x+1, y), (1, 0))]
        elseif dir == (-1, 0)  # left
            return [((x, y-1), (0, -1))]
        elseif dir == (0, -1)  # up
            return [((x-1, y), (-1, 0))]
        end
    end
end


function prettyprint(seen)
    v(dir) = if dir == (1,0) '>' elseif dir == (-1, 0) '<' elseif dir == (0, 1) 'v' elseif dir == (0, -1) '^' end
    grid = Dict(Point2D(x, y) => v(d) for ((x,y), d) in seen)
    println(grid_to_string(grid))
end


function beam(startpos, startdir, grid)
    H = length(grid)
    W = length(grid[1])
    q = Queue{Tuple}()
    enqueue!(q, (startpos, startdir))
    path = Set()
    seen = Set()
    while !isempty(q)
        pos, dir = dequeue!(q)
        # print("$pos, $dir ($(grid[pos[2]][pos[1]])): ")
        push!(seen, pos)
        push!(path, (pos, dir))
        # prettyprint(path)
        for (newpos, newdir) in move(pos, dir, grid)
            if 1 <= newpos[1] <= W && 1 <= newpos[2] <= H && (newpos, newdir) ∉ path
                # print("$newpos $newdir, ")
                enqueue!(q, (newpos, newdir))
            end
        end
        # println("")
    end
    length(seen)
end


function solve1(grid)
    beam((1, 1), (1, 0), grid)
end
export solve1


function solve2(grid)
    H = length(grid)
    W = length(grid[1])
    energized = []
    for x in 1:W
        push!(energized, beam((x,1), (0,1), grid))
        push!(energized, beam((x,H), (0,-1), grid))
    end
    for y in 1:H
        push!(energized, beam((1,y), (1,0), grid))
        push!(energized, beam((W,y), (-1,0), grid))
    end
    maximum(energized)
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """.|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|....
"""
testanswer_1 = 46
testanswer_2 = 51
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
