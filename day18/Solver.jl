module Solver
using Test
using AoC
using AoC.Utils
using AoC.Utils.Geometry
using DataStructures


function parse_input(raw_data)::Vector{Tuple{String, Int, String}}
    instructions = []
    for line in raw_data |> strip |> lines
        d, ll, rest = split(line, " ")
        l = int(ll)
        color = rest[3:end-1]
        push!(instructions, (d, l, color))
    end
    instructions
end
export parse_input


function follow_loop(instructions)
    current = Point2D(1,1)
    points = [current]
    for (d, l) in instructions
        dir = Point2D(0,0)
        if d == "L"
            dir = Point2D(-1, 0)
        elseif d == "R"
            dir = Point2D(1, 0)
        elseif d == "U"
            dir = Point2D(0, -1)
        elseif d == "D"
            dir = Point2D(0, 1)
        end
        current += l * dir
        push!(points, current)
    end
    points
end


function sidelength(points)
    L = 0
    N = length(points)
    for i = 1:N
        x1,y1 = points[i]
        x2,y2 = points[i%N + 1]
        L += abs(x2 - x1) + abs(y2 - y1)
    end
    L
end


function solve1(parsed)
    dirs, ls, _ = unzip(parsed)
    instructions = zip(dirs, ls)
    loop = follow_loop(instructions)
    B = sidelength(loop)
    A = polyarea(loop)
    # picks theorem: points inside loop
    I = A - B // 2 + 1
    I + B 
end
export solve1


function convert_instructions(colors)
    instructions = []
    for c in colors
        l = parse(Int, c[1:end-1]; base=16)
        dd = c[end]
        d = ""
        if dd == '0'
            d = "R"
        elseif dd == '1'
            d = "D"
        elseif dd == '2'
            d = "L"
        elseif dd == '3'
            d = "U"
        end
        push!(instructions, (d, l))
    end
    instructions
end


function solve2(parsed)
    _,_,colors = unzip(parsed)
    instructions = convert_instructions(colors)
    loop = follow_loop(instructions)
    # println(loop)
    B = sidelength(loop)
    A = polyarea(loop)
    # picks theorem: points inside loop
    I = A - B // 2 + 1
    I + B 
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
"""
testanswer_1 = 62
testanswer_2 = 952408144115
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
