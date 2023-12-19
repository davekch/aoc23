module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry
import AoC.Utils.Graphs: shortestpath
using DataStructures


function parse_input(raw_data)
    field = Dict{Point2D, Int}()
    for (y, line) in raw_data |> strip |> lines |> enumerate
        for (x, c) in line |> enumerate
            field[Point2D(x, y)] = int(c)
        end
    end
    field
end
export parse_input

# function dijkstra(graph, start, finish)
# 	unvisited = priorityqueue()
# 	distances = -inf for all nodes
# 	distances[start] = 0
# 	path = {start: undefined}
# 	unvisited.add(start, 0)
# 	while unvisited is not empty
# 		current = unvisited.pop_min()
# 		for neighbor in unvisited neighbors of current
# 			d = distances[current] + distance(current, neighbor)
# 			if d < distances[neighbor]
# 				distances[neighbor] = d
# 				path[neighbor] = current
# 				unvisited.add(neighbor, d)
# 				if neighbor == finish
# 					break
# 	return distances, path


function distance(current, neighbor, graph)
    graph[neighbor]
end

function neighbours(graph, current, path)
    ns = []
    # check if we're already moving in the same direction for 3 steps
    if length(path) >= 3
        # get the last three steps (might not be possible though)
        _i = 1
        p = current
        lastthree = [p]
        while (p = get(path, p, nothing)) !== nothing && _i < 3
            push!(lastthree, p)
            _i += 1
        end
        if length(lastthree) == 3
            # if moving in x direction
            if all(p->p.y==lastthree[1].y, lastthree)
                ns = [current + Point2D(0, 1), current + Point2D(0, -1)]
            elseif all(p->p.x==lastthree[1].x, lastthree)
                ns = [current + Point2D(1, 0), current + Point2D(-1, 0)]
            else
                ns = neighbours4(current)
            end
        else
            ns = neighbours4(current)
        end
    else
        ns = neighbours4(current)
    end
    last = get(path, current, nothing)
    println(ns)
    filter(p->p∈keys(graph) && p != last, ns)
end



function path_dependent_dijkstra(graph, start, finish)
    unvisited = PriorityQueue()
    distances = DefaultDict(10000000)
    distances[start] = 0
    path = Dict{Point2D, Union{Point2D, Nothing}}(start => nothing)
    enqueue!(unvisited, start=>0)
    while !isempty(unvisited)
        current = dequeue!(unvisited)

        ps = shortestpath(path, start, current)
        grid = Dict(ps.=>'o')
        grid[current] = 'X'
        println("$(distances[current]): $current")
        println(grid_to_string(grid))

        for neighbor in neighbours(graph, current, path)
            if neighbor ∈ keys(path)
                println("skip $neighbor")
                continue
            end
            d = distances[current] + distance(current, neighbor, graph)
            if d < distances[neighbor]
                distances[neighbor] = d
                path[neighbor] = current
                enqueue!(unvisited, neighbor=>d)
                println(neighbor=>d)
                if neighbor == finish
                    return distances, path
                end
            end
        end
        println("-------------")
    end
    distances, path
end


function solve1(parsed)
    _,maxx,_,maxy = corners(keys(parsed))
    start = Point2D(1,1)
    # finish = Point2D(maxx, maxy)
    finish = Point2D(3,2)
    distances, paths = path_dependent_dijkstra(parsed, start, finish)
    path = shortestpath(paths, start, finish)
    println(grid_to_string(Dict(path.=>'o')))
    distances[finish]
end
export solve1


function solve2(parsed)
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
"""
testanswer_1 = 102
testanswer_2 = nothing
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
