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

#                 location,direction,count
const Node = Tuple{Point2D, Point2D, Int}


function neighbours(graph, node)
    p, dir, c = node
    d1 = rot90l(dir)
    d2 = rot90r(dir)
    ns = [(p+d1, d1, 1), (p+d2, d2, 1)]
    if c <= 2
        # we can also go one step forward
        push!(ns, (p+dir, dir, c+1))
    end
    ns |> filter(n -> n[1] ∈ keys(graph) && n != p - dir)
end

function distance(current::Node, neighbor::Node, graph)
    graph[neighbor[1]]
end


function simple_dijkstra(graph, start, finish)
    queue = PriorityQueue{Node,Int}()
    queue[start] = 0
    distances = DefaultDict(1000000)
    distances[start] = 0
    path = Dict{Node, Union{Node, Nothing}}()
    path[start] = nothing
    seen = Set(start)
    current = start
    while !isempty(queue)
        current = dequeue!(queue)
        push!(seen, current)
        # display(queue)
        println(current)
        println(length(seen))
        println(length(queue))

        for n in neighbours(graph, current) |> filter(∉(seen))
            # if n in keys(path)
            #     continue
            # end
            d = distances[current] + distance(current, n, graph)
            if d < distances[n]
                distances[n] = d
                path[n] = current
                queue[n] = d
                if finish(n)
                    return n, distances, path
                end
            end
        end
    end
    current, distances, path
end


function dijkstra(graph, start::Node, finish::Function)
    unvisited = PriorityQueue()
    distances = DefaultDict(10000000)
    distances[start] = 0
    path = Dict{Node, Union{Node, Nothing}}(start => nothing)
    enqueue!(unvisited, start=>0)
    while !isempty(unvisited)
        current = dequeue!(unvisited)
        # println(length(unvisited))

        # println(length(path))
        ps = shortestpath(path, start, current)
        grid = Dict(getindex.(ps, 1).=>'o')
        grid[current[1]] = 'X'
        println("$(distances[current]): $current")
        println(grid_to_string(grid))

        for neighbour in neighbours(graph, current)
            # if there is already point with same coordinates and either both count 1 or same direction but higher count
            if any([neighbour[1] == p[1] && (neighbour[3] == p[3] == 1 || (neighbour[2] == p[2] && neighbour[3] >= p[3])) for p in keys(path)])
                continue
            # if neighbour ∈ keys(path) || (neighbour[3] == 1 && neighbour[1] ∈ [p[1] for p in keys(path) if p[3] == 1])
            #     # println("skip $neighbour")
            #     continue
            end
            d = distances[current] + distance(current, neighbour, graph)
            if d < distances[neighbour]
                distances[neighbour] = d
                path[neighbour] = current
                unvisited[neighbour] = d
                # if neighbour ∉ keys(unvisited) #&& !(neighbour[3] == 1 && neighbour[1] ∈ [p[1] for p in keys(unvisited) if p[3] == 1])
                #     enqueue!(unvisited, neighbour=>d)
                # end
                println(neighbour=>d)
                if finish(neighbour)
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
    # maxx, maxy = 6, 1
    start = (Point2D(1,1), Point2D(1,0), 1)
    finish(node) = node[1] == Point2D(maxx, maxy)
    finishpoint, distances, paths = simple_dijkstra(parsed, start, finish)
    # path = shortestpath(paths, start, paths[end])
    # println(grid_to_string(Dict(getindex.(path, 1).=>'o')))
    # distances |> filter(p->p[1][1] == Point2D(maxx, maxy)) |> values |> minimum
    distances[finishpoint]
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
