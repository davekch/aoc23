module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry
using DataStructures


function parse_input(raw_data)
    grid = Dict{Point2D, Char}()
    start = Point2D(1, 1)  # initial value
    for (y, line) in raw_data |> strip |> lines |> enumerate
        for (x, c) in line |> enumerate
            if c in "#."
                grid[Point2D(x, y)] = c
            elseif c == 'S'
                grid[Point2D(x, y)] = '.'
                start = Point2D(x, y)
            end
        end
    end
    start, grid
end
export parse_input


function solve(nsteps, (start, grid))
    rocks = keys(filter(p->p[2]=='#', grid))
    reached = 0
    current = start
    q = Set{Point2D}()
    push!(q, current)
    for i = 1:nsteps
        newq = Set{Point2D}()
        while !isempty(q)
            current = pop!(q)
            for n ∈ neighbours4(current)
                if n ∉ rocks
                    push!(newq, n)
                end
            end
        end
        reached = length(newq)
        # debug stuff for part 2 --------------------
        println("after $i steps: $reached")
        printable = Dict([
            p => (p.x ∈ 1:11 && p.y ∈ 1:11) ? "\033[48;5;57m$c\033[0m" : c
            for (p, c) in grid ∪ Dict(newq.=>'O')
        ])
        println(grid_to_string(printable))
        # println("reached in original grid: $(length(filter(p -> p.x ∈ 1:11 && p.y ∈ 1:11, newq)))")
        sleep(0.1)
        # -------------------------------------------
        q = newq
    end
    reached
end


# for debugging & printing
function repeat_grid(grid; n=2)
    _,maxx,_,maxy = corners(keys(grid))
    Dict(union([
        Dict([p + Point2D(i * maxx, j * maxy) => c for (p, c) in grid])
        for i = -n:n, j = -n:n
    ]...))
end


function solve1(parsed)
    solve(64, parsed)
end
export solve1


function solve_infinite(nsteps, (start, grid))
    minx,maxx,miny,maxy = corners(keys(grid))
    reached = 0
    current = start
    q = DefaultDict{Point2D, Int}(0)
    q[current] = 1
    for i = 1:nsteps
        newq = DefaultDict{Point2D, Int}(0)
        while !isempty(q)
            current, count = pop!(q)
            for n ∈ neighbours4(current)
                if grid[Point2D(mod(n.x, minx:maxx), mod(n.y, miny:maxy))] != '#' && n ∉ keys(newq)
                    newq[n] += count
                end
            end
        end
        # wrap outside points back to inside of the grid
        wrapped = DefaultDict{Point2D, Int}(0)
        for (p,c) ∈ newq
            wrapped[Point2D(mod(p.x, minx:maxx), mod(p.y, miny:maxy))] += c
        end
        reached = sum(values(wrapped))
        println("after $i steps: $reached")
        println(grid_to_string(Dict(grid ∪ wrapped)))
        q = wrapped
    end
    reached
end
export solve_infinite


function solve2(parsed)
    solve_infinite(26501365, parsed)
end
export solve2


solution = Solution(parse_input, solve1, solve2)
testsolution = Solution(parse_input, p -> solve(6, p), solve2)

testinput = """
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
"""
testanswer_1 = 16
testanswer_2 = nothing
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(testsolution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
