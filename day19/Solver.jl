module Solver
using Test
using AoC
using AoC.Utils


struct Part
    x::Int
    m::Int
    a::Int
    s::Int
end
# export Part


struct Condition
    attr::Symbol
    comp::Function
    value::Int
    send::String
end
# export Condition


function parse_input(raw_data)
    rules_data, parts_data = split(raw_data|>strip, "\n\n")
    rules = Dict{String, Vector{Union{Condition, SubString}}}()
    for line in lines(rules_data)
        name = line[1:findfirst(==('{'), line)-1]
        rule_data = match(r"{.*}", line).match
        rule_data = rule_data[2:end-1]
        rs = Union{Condition, SubString}[]
        for rule in split(rule_data, ",")
            if ':' in rule
                cond, send = split(rule, ":")
                match_comp = match(r"[><]", cond)
                attr = Symbol(cond[1:match_comp.offset-1])
                comp = match_comp.match == "<" ? (<) : (>)
                value = ints(cond)[1]
                push!(rs, Condition(attr, comp, value, send))
            else
                push!(rs, rule)
            end
        end
        rules[name] = rs
    end

    parts = Part[]
    for line in lines(parts_data)
        x,m,a,s = ints(line)
        push!(parts, Part(x,m,a,s))
    end

    rules, parts
end
export parse_input


function accept(part, rules)
    current_rules = rules["in"]
    # println(part)
    while true
        for rule in current_rules
            # println(rule)
            if rule == "A"
                return true
            elseif rule == "R"
                return false
            elseif typeof(rule) <: AbstractString
                current_rules = rules[rule]
                break
            elseif rule.comp(getproperty(part, rule.attr), rule.value)
                if rule.send == "A"
                    return true
                elseif rule.send == "R"
                    return false
                else
                    current_rules = rules[rule.send]
                    break
                end
            end
        end
    end
end


function solve1((rules, parts))
    result = 0
    for p in parts
        if accept(p, rules)
            result += p.x + p.m + p.a + p.s
        end
    end
    result
end
export solve1


function solve2(parsed)
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
"""
testanswer_1 = 19114
testanswer_2 = 167409079868000
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
