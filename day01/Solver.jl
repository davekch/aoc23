module Solver
using Test
using AoC
using AoC.Utils


function AoC.parse_input(raw_data)
    split(raw_data |> strip, "\n")
end


function AoC.solve1(parsed)
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


function AoC.solve2(parsed)
    n = 0
    for line in parsed
        idx = findall(r"(one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)|[0-9]", line)
        first = read_int(line[idx[1]])
        second = read_int(line[idx[end]])
        n += first * 10 + second
    end
    n
end


testinput = """1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
"""
testanswer_1 = 142
testanswer_2 = 281
export testinput, testanswer_1, testanswer_2

test(part=missing) = AoC.test_solution(testinput, testanswer_1, testanswer_2, part)
export test


end # module Solver
