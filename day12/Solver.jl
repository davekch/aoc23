module Solver
using Test
using AoC
using AoC.Utils


function parse_input(raw_data)
    data = Tuple{String, Vector{Int}}[]
    for line in raw_data |> strip |> lines
        record, numbers = split(line, " ")
        damaged = ints(numbers)
        push!(data, (record, damaged))
    end
    data
end
export parse_input


# function n_possibilities(record::AbstractString, damaged::Vector{Int})
#     n = 1
#     chunks = split(record, ".") |> filter(!=(""))
#     lchunks = map(length, chunks)
#     # easy case: there are as many contiguous records (chunks) separated by . as there are numbers
#     if length(lchunks) == length(damaged)
#         for (i, (should, is)) in zip(lchunks, damaged) |> enumerate
#             println((chunks[i], should, is))
#             if should < is
#                 n *= n_possibilities(chunks[i], should)
#             end
#             # elseif should == is -> only one possibility, do nothing
#         end
#     end
#     n
# end

# function n_possibilities(record::AbstractString, should::Int)
# end


function n_possibilities((record, damaged))
    # println(record)
    chunks = split(record, ".") |> filter(!=(""))
    lchunks = map(length, chunks)
    if count('?', record) == 0
        # we are done; check if valid
        if lchunks == damaged
            # println("valid!")
            return 1
        else
            # println("invalid!")
            return 0
        end
    end
    n = 0
    n += n_possibilities((replace(record, "?"=>"#", count=1), damaged))
    n += n_possibilities((replace(record, "?"=>".", count=1), damaged))
    n
end
export n_possibilities


function solve1(parsed)
    map(n_possibilities, parsed) |> sum
end
export solve1


function solve2(parsed)
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
"""
testanswer_1 = 21
testanswer_2 = 525152
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
