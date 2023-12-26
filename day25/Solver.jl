module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Graphs
import DataStructures: DefaultDict
import Combinatorics: combinations


function parse_input(raw_data)
    graph = DefaultDict(Set)
    for line in lines(raw_data)
        node, connections = split(line, ": ")
        node = String(node)
        connections = map(String, split(connections, " "))
        union!(graph[node], connections)
        # add the reverse connections
        for c in connections
            push!(graph[c], node)
        end
    end
    graph
end
export parse_input


Graphs.neighbours(graph, node::String) = graph[node]


function solve1(graph)
    graph = deepcopy(graph)
    disconnected_1 = disconnected_2 = nothing
    for _ = 1:3
        common_links = DefaultDict(0)
        start = collect(keys(graph))[1]  # start randomly
        paths = BFS(graph, start, "")   # shortest path from start to every other node
        # do BFS for each pair of points, then count the links that appear in all those paths
        # remove the most common link and do it again; after three steps, the graph should be cut
        for (n1, n2) in combinations(keys(graph)|>collect, 2)
            shortest = shortestpath(paths, n1, n2)
            if shortest == []
                # do bfs again
                # println("do it again")
                new_paths = BFS(graph, n1, n2)
                # save the result
                paths = Dict(paths ∪ new_paths)
                shortest = shortestpath(paths, n1, n2)
            end
            # println("from $n1 to $n2")
            # println(shortest)
            for link in zip(shortest, shortest[2:end])
                common_links[link] += 1
            end
        end
        most_common = reverse(sort(common_links, by=p->p[2]))[1]
        println(most_common)
        disconnected_1 = most_common[1][1]
        disconnected_2 = most_common[1][2]
        # remove that most common link from the graph
        pop!(graph[disconnected_1], disconnected_2)
        pop!(graph[disconnected_2], disconnected_1)
    end
    # use bfs again to find the sizes of the two disconnected graphs
    size_1 = length(BFS(graph, disconnected_1, ""))
    size_2 = length(BFS(graph, disconnected_2, ""))
    size_1 * size_2
end
export solve1


function solve2(parsed)
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr
"""
testanswer_1 = 54
testanswer_2 = nothing
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
