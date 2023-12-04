module Solver
using Test
using AoC
using AoC.Utils
using DataStructures


function parse_input(raw_data)
    cards = OrderedDict{Int, Int}()  # maps card ID to number of winning numbers
    for line in lines(raw_data|>strip)
        (c, nums) = split(line, ": ")
        ID = split(c, " ")[end] |> strip |> int
        (winning, yours) = map(ints, split(nums, "|"))
        common = intersect(Set(winning), Set(yours)) |> length
        cards[ID] = common
    end
    cards
end
export parse_input


function solve1(parsed)
    map(x->2^(x-1), parsed |> values |> collect |> filter(>(0))) |> sum
end
export solve1


function solve2(parsed)
    cards = DefaultDict{Int, Int}(0)
    for (ID, wins) in parsed
        cards[ID] += 1   # this card
        for copyID in 1:wins
            cards[ID+copyID] += cards[ID]
        end
    end
    sum(values(cards))
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
"""
testanswer_1 = 13
testanswer_2 = 30
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
