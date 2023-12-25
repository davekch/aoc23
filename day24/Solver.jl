module Solver
using Test
using AoC
using AoC.Utils
import Combinatorics: combinations


function parse_input(raw_data)
    hailstones = []
    for line in raw_data |> lines
        x,y,z,vx,vy,vz = ints(line)
        push!(hailstones, ((x,y,z), (vx,vy,vz)))
    end
    hailstones
end
export parse_input


function line_intersect(m1, b1, m2, b2)
    # m1*x + b1 = m2*x + b2 -> x = (b2 - b1) / (m1 - m2)
    if m1 == m2
        nothing
    else
        x = (b2 - b1) / (m1 - m2)
        y = m1 * x + b1
        x, y
    end
end


"""
get m, b parameters of the y = mx + b form from an initial point and slope
"""
function line_parameters(x, y, dx, dy)
    # y = m*x + b
    # y + dy = m*(x + dx) + b
    m = dy / dx
    b = y - m*x
    m, b
end


function generic_solve(parsed, min, max)
    count = 0
    for (h1, h2) in combinations(parsed, 2)
        ((x1,y1,_), (vx1,vy1,_)) = h1
        ((x2,y2,_), (vx2,vy2,_)) = h2
        # println("haistone A: $x1, $y1 @ $vx1, $vy1")
        # println("haistone B: $x2, $y2 @ $vx2, $vy2")
        m1, b1 = line_parameters(x1, y1, vx1, vy1)
        m2, b2 = line_parameters(x2, y2, vx2, vy2)
        i = line_intersect(m1, b1, m2, b2)
        if i === nothing
            # println("  never intersect")
            continue
        else
            xi, yi = i
            # println("  intersect at $xi, $yi")
            # check if the intersection is in the required interval
            if min <= xi <= max && min <= yi <= max
                # println("  inside region")
                # check if the intersection is in the future or past
                past = (
                    ((sign(vx1) ==1 && xi < x1) || (sign(vx1) == -1 && xi > x1))
                    || ((sign(vx2) ==1 && xi < x2) || (sign(vx2) == -1 && xi > x2))
                )
                if !past
                    # println("  in future")
                    count += 1
                else
                    # println("  in past")
                end
            else
                # println("  outside region")
            end
        end
    end
    count
end


function solve1(parsed)
    generic_solve(parsed, 200000000000000, 400000000000000)
end
export solve1


function solve2(parsed)
end
export solve2


solution = Solution(parse_input, solve1, solve2)
testsolution = Solution(parse_input, p -> generic_solve(p, 7, 27), solve2)

testinput = """19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3
"""
testanswer_1 = 2
testanswer_2 = nothing
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(testsolution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
