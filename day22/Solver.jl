module Solver
using Test
using AoC
using AoC.Utils
import DataStructures: DefaultDict


function parse_input(raw_data)
    bricks = []
    for line in raw_data |> strip |> lines
        x1,y1,z1,x2,y2,z2 = ints(line)
        push!(bricks, ((x1,y1,z1), (x2,y2,z2)))
    end
    # println(all([z1 <= z2 for ((_,_,z1),(_,_,z2)) in bricks]))
    sort(bricks, by=b->b[1][3])   # sort bricks by first z coordinate
end
export parse_input


function overlap(brick1, brick2)
    (minx1,miny1,minz1), (maxx1,maxy1,maxz1) = brick1
    (minx2,miny2,minz2), (maxx2,maxy2,maxz2) = brick2
    # overlap if all coordinates overlap
    (
        length(intersect(minx1:maxx1, minx2:maxx2)) > 0
        && length(intersect(miny1:maxy1, miny2:maxy2)) > 0
        && length(intersect(minz1:maxz1, minz2:maxz2)) > 0
    )
end


function fall(bricks)
    changed = true
    newbricks = []
    while changed
        newbricks = []
        changed = false
        for brick in bricks
            ((x1,y1,z1), (x2,y2,z2)) = brick
            newbrick = ((x1,y1,z1-1), (x2,y2,z2-1))
            if z1-1 >= 1 && !any([overlap(newbrick, b) for b in newbricks])
                push!(newbricks, newbrick)
                changed = true
            else
                push!(newbricks, brick)
            end
        end
        bricks = sort(newbricks, by=b->b[1][3])
    end
    bricks
end
export fall


function build_support_tree(fallenbricks)
    fallenbricks = Dict(enumerate(fallenbricks))
    supported_by = DefaultDict{Int, Vector{Int}}([])
    for (i, brick) in fallenbricks
        (minx1,miny1,minz1), (maxx1,maxy1,maxz1) = brick
        # if any other brick at z-1 overlaps in x and y, this brick is supported by it
        for (j, below) in filter(b->b[2][2][3]==minz1-1, fallenbricks)
            (minx2,miny2,minz2), (maxx2,maxy2,maxz2) = below
            if length(intersect(minx1:maxx1, minx2:maxx2)) > 0 && length(intersect(miny1:maxy1, miny2:maxy2)) > 0
                push!(supported_by[i], j)
            end
        end
    end
    supported_by
end


function solve(parsed)
    fallenbricks = fall(parsed)
    supported_by = build_support_tree(fallenbricks)
    cant_disintegrate = Set()
    for support in values(supported_by)
        if length(support) == 1
            # this brick is only supported by 1 other brick, so we can't disintegrate that brick
            push!(cant_disintegrate, support[1])
        end
    end
    part1 = length(fallenbricks) - length(cant_disintegrate)

    part2 = 0
    # blow up the stuff we shouldn't blow up and count how many bricks they will bring to fall
    for brick in cant_disintegrate
        fell = Set(brick)
        changed = true
        while changed
            changed = false
            # stupid
            for (b,support) in supported_by
                # if the entire support has fallen, this one falls too
                if b ∉ fell && intersect(support, fell) == support
                    changed = true
                    push!(fell, b)
                end
            end
        end
        part2 += length(fell) - 1  # the initially disintegrated brick does not count
    end
    part1, part2
end
export solve



solution = Solution(parse_input, solve)

testinput = """1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
"""
testanswer_1 = 5
testanswer_2 = 7
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
