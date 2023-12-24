module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry
using DataStructures


function parse_input(raw_data)
    read_grid(raw_data)
end
export parse_input


function neighbours(grid, node)
    c = grid[node]
    if c == '>'
        [node + Point2D(1, 0)]
    elseif c == '<'
        [node + Point2D(-1, 0)]
    elseif c == '^'
        [node + Point2D(0, -1)]
    elseif c == 'v'
        [node + Point2D(0, 1)]
    else
        neighbours4(node) |> filter(n->n∈keys(grid)&&grid[n]!='#')
    end
end


function possible_paths(grid, start, finish)
    paths = Vector{Point2D}[]
    q = Queue{Vector{Point2D}}()
    enqueue!(q, [start])
    while !isempty(q)
        current_path = dequeue!(q)
        current = last(current_path)
        # if this point is already in a queued path but at a later point, we can skip
        println(length(q))
        while current != finish
            ns = neighbours(grid, current) |> filter(n->n∉current_path)
            if length(ns) == 0
                break
            else
                current, others... = ns
                for n in others
                    enqueue!(q, vcat(current_path, [n]))
                end
                push!(current_path, current)
            end
        end
        # check if we actually made it to the end
        if last(current_path) == finish
            push!(paths, current_path)
        end
    end
    paths
end


function solve1(grid)
    _,maxx,_,maxy = corners(keys(grid))
    start = Point2D(2, 1)
    finish = Point2D(maxx-1, maxy)
    paths = possible_paths(grid, start, finish)
    (map(length, paths) |> maximum) - 1
end
export solve1


function solve2(grid)
    grid = Dict([k => v ∈ "><v^" ? '.' : v for (k,v) in grid])
    solve1(grid)
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """
#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#
"""
testanswer_1 = 94
testanswer_2 = 154
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
