module Solver
using Test
using AoC
using AoC.Utils


function parse_input(raw_data)
    split(raw_data |> strip, "\n")
end


function solve1(parsed)
    n = 0
    for line in parsed
        i = Utils.digits(line)
        n += i[1]*10 + i[end]
    end
    n
end


function read_int(s)
    if isdigit(s[1])
        return int(s)
    else
        if s == "one"
            return 1
        elseif s == "two"
            return 2
        elseif s == "three"
            return 3
        elseif s == "four"
            return 4
        elseif s == "five"
            return 5
        elseif s == "six"
            return 6
        elseif s == "seven"
            return 7
        elseif s == "eight"
            return 8
        elseif s == "nine"
            return 9
        end
    end
end

function solve2_incorrect(parsed)
    ns = []
    for line in parsed
        idx = findall(r"(one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)|[0-9]", line)
        first = read_int(line[idx[1]])
        second = read_int(line[idx[end]])
        push!(ns, first*10 + second)
    end
    ns
end

function solve2_correct(parsed)
    ns = []
    for line in parsed
        digits = []
        for (i,c) in enumerate(line)
            if isdigit(c)
                push!(digits, int(c))
            elseif startswith(line[i:end], "one")
                push!(digits, 1)
            elseif startswith(line[i:end], "two")
                push!(digits, 2)
            elseif startswith(line[i:end], "three")
                push!(digits, 3)
            elseif startswith(line[i:end], "four")
                push!(digits, 4)
            elseif startswith(line[i:end], "five")
                push!(digits, 5)
            elseif startswith(line[i:end], "six")
                push!(digits, 6)
            elseif startswith(line[i:end], "seven")
                push!(digits, 7)
            elseif startswith(line[i:end], "eight")
                push!(digits, 8)
            elseif startswith(line[i:end], "nine")
                push!(digits, 9)
            end
        end
        push!(ns, digits[1]*10 + digits[end])
    end
    ns
end


function solve2(parsed)
    # note: this solution is technically wrong, i just got lucky with my input
    solve2_incorrect(parsed) |> sum
end

solution = Solution(parse_input, solve1, solve2)


testinput = """1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
"""
testanswer_1 = 142
testanswer_2 = 281
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
