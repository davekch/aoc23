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
        # # debug stuff for part 2 --------------------
        # println("after $i steps: $reached")
        # printable = Dict([
        #     p => (p.x ∈ 1:11 && p.y ∈ 1:11) ? "\033[48;5;57m$c\033[0m" : c
        #     for (p, c) in grid ∪ Dict(newq.=>'O')
        # ])
        # println(grid_to_string(printable))
        # # println("reached in original grid: $(length(filter(p -> p.x ∈ 1:11 && p.y ∈ 1:11, newq)))")
        # sleep(0.03)
        # # -------------------------------------------
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


const Grid = Dict{Point2D, Char}

function solve_infinite(nsteps, (start, grid))
    minx,maxx,miny,maxy = corners(keys(grid))
    reached = 0
    current = start
    # the first point is an index in which grid we are
    # for some reason (Point2D(i,j), Point(x,y)) in Set([(Point2D(i,j), Point(x,y))]) is false 
    # while (Point2D(i,j), Point(x,y)) in [(Point2D(i,j), Point(x,y))] is true so i guess i need to use a vector
    q = Tuple{Point2D, Point2D}[]
    push!(q, (Point2D(0,0), current))
    # history of how many we reached for each grid
    occupied = DefaultDict{Point2D, Vector{Int}}([])
    oscillates = Point2D[]
    for i = 1:nsteps
        println(i)
        newq = Tuple{Point2D, Point2D}[]
        while !isempty(q)
            grid_ij, current = pop!(q)
            for n ∈ neighbours4(current)
                # check if this neighbour moves to a next 
                n_grid_ij = grid_ij
                if n.x < minx
                    n_grid_ij += Point2D(-1,0)
                elseif n.x > maxx
                    n_grid_ij += Point2D(1,0)
                elseif n.y < miny
                    n_grid_ij += Point2D(0,-1)
                elseif n.y > maxy
                    n_grid_ij += Point2D(0,1)
                end
                n = Point2D(mod(n.x, minx:maxx), mod(n.y, miny:maxy))
                if grid[n] != '#' && (n_grid_ij, n) ∉ newq && n_grid_ij ∉ oscillates  # the border does not contain rocks
                    push!(newq, (n_grid_ij, n))
                end
            end
        end
        # stupid
        # println(newq)
        occs = DefaultDict{Point2D, Int}(0)
        for (grid_ij, _) in newq
            occs[grid_ij] += 1
        end
        # display(newq)
        # check if one of the grids is oscillating
        for (grid_ij, occ) in occs
            history = occupied[grid_ij]
            if length(history) >= 2 && occ == history[end-1]
                # this grid is oscillating; remove all its points from the queue
                filter!(item->item[1]!=grid_ij, newq)
                # we now know what this grid will contribute to the number of reached points;
                # depends only on whether we are at an odd or even step
                if nsteps % 2 == i % 2
                    println("$grid_ij oscillates, will be $(occ)")
                    reached += occ
                else
                    println("$grid_ij oscillates, will be $(history[end])")
                    reached += history[end]
                end
                pop!(occupied, grid_ij)
                push!(oscillates, grid_ij)
            else
                push!(history, occ)
            end
        end
        q = newq
    end
    # display(occupied)
    reached += sum([h[end] for h in values(occupied)])
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
