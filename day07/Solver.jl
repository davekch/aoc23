module Solver
using Test
using AoC
using AoC.Utils
import DataStructures: counter


function parse_input(raw_data)
    data = []
    for line in lines(raw_data|>strip)
        hand, bid = split(line)
        push!(data, (hand, int(bid)))
    end
    data
end
export parse_input


@enum HandType begin
    Highcard
    Onepair
    Twopair
    Three
    Fullhouse
    Four
    Five
end

function get_handtype(hand)
    uniqueness = unique(hand) |> length
    card_counts = counter(hand) |> values
    if uniqueness == 1
        return Five
    elseif uniqueness == 2
        if any([c == 4 for c in card_counts])
            return Four
        else
            return Fullhouse
        end
    elseif uniqueness == 3
        if any([c == 3 for c in card_counts])
            return Three
        else
            return Twopair
        end
    elseif uniqueness == 4
        return Onepair
    else
        return Highcard
    end
end

const cardrank = Dict([c=>v for (v,c) in enumerate("23456789TJQKA")])

function isless_hand(hand1, hand2)
    # defines total ordering for hands
    type1, type2 = get_handtype.([hand1, hand2])
    if type1 < type2
        return true
    elseif type1 == type2
        for (c1,c2) in zip(hand1, hand2)
            if c1 == c2
                continue
            elseif cardrank[c1] < cardrank[c2]
                return true
            else
                return false
            end
        end
    else
        return false
    end
end
export isless_hand


function solve1(parsed)
    sorted_by_rank = sort(parsed, by=x->x[1], lt=isless_hand)
    result = 0
    for (rank, (hand, bid)) in enumerate(sorted_by_rank)
        result += rank * bid
    end
    result
end
export solve1


# ---------------- do everything again but with a joker

function get_handtype_j(hand)
    # println(hand)
    uniqueness = unique(hand) |> length
    card_counts = counter(hand) |> Dict
    if 'J' in hand
        if card_counts['J'] == 5
            return Five
        end
        uniqueness -= 1
        # add joker to the most appearing card; having more equal cards is always beneficial
        jokers = pop!(card_counts, 'J')
        # println(card_counts)
        most, count = sort(card_counts|>collect, by=p->p[2])[end]
        card_counts[most] = count + jokers
    end
    if uniqueness == 1
        return Five
    elseif uniqueness == 2
        if any([c == 4 for c in card_counts |> values])
            return Four
        else
            return Fullhouse
        end
    elseif uniqueness == 3
        if any([c == 3 for c in card_counts |> values])
            return Three
        else
            return Twopair
        end
    elseif uniqueness == 4
        return Onepair
    else
        return Highcard
    end
end

const cardrank_j = Dict([c=>v for (v,c) in enumerate("J23456789TQKA")])

function isless_hand_j(hand1, hand2)
    # defines total ordering for hands
    type1, type2 = get_handtype_j.([hand1, hand2])
    if type1 < type2
        return true
    elseif type1 == type2
        for (c1,c2) in zip(hand1, hand2)
            if c1 == c2
                continue
            elseif cardrank_j[c1] < cardrank_j[c2]
                return true
            else
                return false
            end
        end
    else
        return false
    end
end

function solve2(parsed)
    sorted_by_rank = sort(parsed, by=x->x[1], lt=isless_hand_j)
    result = 0
    for (rank, (hand, bid)) in enumerate(sorted_by_rank)
        result += rank * bid
    end
    result
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
"""
testanswer_1 = 6440
testanswer_2 = 5905
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
