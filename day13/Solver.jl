module Solver
using Test
using AoC
using AoC.Utils


function parse_input(raw_data)
    images = Matrix{Bool}[]
    for block in split(raw_data, "\n\n")
        rows = lines(block)
        image = [rows[i][j] == '#' for i = eachindex(rows), j = eachindex(rows[1])]
        push!(images, image)
    end
    images
end
export parse_input


function prettyprint(image)
    s = join(map(prod, eachrow(image)), "\n")
    println(s * "\n")
end
export prettyprint
    


function find_h_mirrors(image, smudge=false)
    # loop through indices at which to mirror horizontally
    _,w = size(image)
    for hm = 1:w-1
        left = image[:, 1:hm]
        right = image[:, hm+1:end]
        # only the part that actually fits into the image is relevant
        if hm <= w//2
            right = right[:, 1:hm]
        else
            left = left[:, end-(w-hm-1):end]
        end
        mirrored = left[:, end:-1:1]
        # println("compare ------------------------")
        # prettyprint(left)
        # prettyprint(mirrored)
        # prettyprint(right)
        # if no smudge, the mirrored image must equal the right image,
        # if smudge, the mirrored image must be off by exactly 1
        if (!smudge && mirrored == right) || (smudge && count(==(1), abs.(mirrored-right)) == 1)
            return hm
        end
    end
    return 0
end


function find_v_mirrors(image, smudge=false)
    # loop through indices at which to mirror vertically
    h,_ = size(image)
    for vm = 1:h-1
        upper = image[1:vm, :]
        lower = image[vm+1:end, :]
        # only the part that actually fits into the image is relevant
        if vm <= h//2
            lower = lower[1:vm, :]
        else
            # println(vm)
            # println(size(upper))
            upper = upper[end-(h-vm-1):end, :]
        end
        mirrored = lower[end:-1:1, :]
        # println("compare ------------------------")
        # prettyprint(upper)
        # prettyprint(lower)
        # prettyprint(mirrored)
        # if no smudge, the mirrored image must equal the upper image,
        # if smudge, the mirrored image must be off by exactly 1
        if (!smudge && mirrored == upper) || (smudge && count(==(1), abs.(mirrored-upper)) == 1)
            return vm
        end
    end
    return 0
end


function solve(parsed; smudge=false)
    n = 0
    for image in parsed
        h = find_h_mirrors(image, smudge)
        if h == 0
            v = find_v_mirrors(image, smudge)
            # println("vertical at $v")
            n += 100*v
        else
            # println("horizontal at $h")
            n += h
        end
    end
    n
end

function solve1(parsed)
    solve(parsed, smudge=false)
end
export solve1


function solve2(parsed)
    solve(parsed, smudge=true)
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
"""
testanswer_1 = 405
testanswer_2 = 400
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
