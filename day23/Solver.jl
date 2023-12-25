module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry
import AoC.Utils.Graphs: possible_paths
import AoC.Utils.Graphs
using DataStructures


function parse_input(raw_data)
    read_grid(raw_data)
end
export parse_input


function Graphs.neighbours(grid::Dict{<:Point2D, Char}, node::Point2D)
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


"""
reduce the grid to a weighted graph where the only vertices are path intersections
"""
function reduce_grid(grid::Dict{<:Point2D, Char}, start::Point2D)
    graph = WeightedGraph{Point2D}(Dict())
    q = Queue{Tuple{Point2D, Vector{Point2D}}}()
    enqueue!(q, (start, [start]))
    seen = Set()
    while !isempty(q)
        vertex, current_path = dequeue!(q)
        l = length(current_path) - 1
        current = last(current_path)
        push!(seen, current)
        ns = Graphs.neighbours(grid, current) |> filter(n -> n ∉ current_path)
        if length(ns) == 1
            # we are not at an intersection
            enqueue!(q, (vertex, vcat(current_path, ns)))
        else
            # we are at an intersection -> add a new vertex
            graph[vertex][current] = l
            graph[current][vertex] = l
            for n in filter(n -> n ∉ seen, ns)
                enqueue!(q, (current, [current, n]))
            end
        end
    end
    graph
end
export reduce_grid


const WeightedGraph = DefaultDict{T, Dict{T, Int}} where T

function Graphs.neighbours(graph::WeightedGraph{Point2D}, node::Point2D)
    graph[node] |> keys
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
    _,maxx,_,maxy = corners(keys(grid))
    start = Point2D(2, 1)
    finish = Point2D(maxx-1, maxy)
    graph = reduce_grid(grid, start)
    paths = possible_paths(graph, start, finish)
    lengths = []
    for path in paths
        l = 0
        for (p1,p2) in zip(path, path[2:end])
            l += graph[p1][p2]
        end
        push!(lengths, l)
    end
    maximum(lengths)
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
