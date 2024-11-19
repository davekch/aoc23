module Solver
using Test
using AoC
using AoC.Utils
import AoC.Utils.Geometry: nd_union_volume
using DataStructures
import Combinatorics: combinations


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


const Range = NamedTuple{(:minx,:maxx,:minm,:maxm,:mina,:maxa,:mins,:maxs), Tuple{Int,Int,Int,Int,Int,Int,Int,Int}}


# i apologize for this "function"
function rules_to_ranges(rules)
    # turn rules into a list of ranges of x,m,a,s to be accepted
    ranges = Range[]
    # queue ranges, the name of the rule and index of the rule to check
    to_check = Queue{Tuple{Range, String, Int}}()
    start = Range((1,4000,1,4000,1,4000,1,4000))
    enqueue!(to_check, (start, "in", 1))
    while !isempty(to_check)
        range, rulekey, index = dequeue!(to_check)
        if rulekey == "A"
            push!(ranges, range)
            continue
        elseif rulekey == "R"
            continue
        end

        condition = rules[rulekey][index]
        @debug "checking $condition ($rulekey[$index]) on $range"
        if condition == "A"
            @debug "  it's a match!"
            push!(ranges, range)
        elseif condition == "R"
            @debug "  reject"
            continue
        elseif typeof(condition) <: AbstractString
            @debug "  pass on to $condition"
            enqueue!(to_check, (range, condition, 1))
        else
            minx,maxx,minm,maxm,mina,maxa,mins,maxs = range
            # pass the range that satisfies the condition on to the rule where it is 
            # sent to, and the range that doesnt to the next index of this rule
            # i dont know a less verbose way to do this; monstrosity ahead
            if condition.attr == :x
                if condition.comp == (<)
                    if condition.value <= minx
                        # none of the x-values make it; move the entire range to the next rule
                        enqueue!(to_check, (range, rulekey, index+1))
                        @debug "  range outside condition, queue $(last(to_check))"
                    elseif minx < condition.value <= maxx
                        @debug "  range partially in condition, queue"
                        # some x-values make it, others don't
                        range1 = Range((minx, condition.value-1, minm,maxm,mina,maxa,mins,maxs))
                        # this range fulfils the condition, move it to the next rule
                        enqueue!(to_check, (range1, condition.send, 1))
                        @debug "    $(last(to_check))"
                        range2 = Range((condition.value, maxx, minm,maxm,mina,maxa,mins,maxs))
                        # this range doesn't fulfil the condition, send it one index further
                        enqueue!(to_check, (range2, rulekey, index+1))
                        @debug "    $(last(to_check))"
                    else
                        # the entire range fulfils the condition
                        enqueue!(to_check, (range, condition.send, 1))
                        @debug "  range inside condition, queue $(last(to_check))"
                    end
                else  # condition.comp = >
                    if condition.value >= maxx
                        # none of the x-values make it; move the entire range to the next rule
                        enqueue!(range, rulekey, index+1)
                        @debug "  range outside condition, queue $(last(to_check))"
                    elseif minx <= condition.value < maxx
                        @debug "  range partially in condition, queue"
                        # some x-values make it, others don't
                        range1 = Range((minx, condition.value, minm,maxm,mina,maxa,mins,maxs))
                        # this range doesnt fulfil the condition, move it to the next index
                        enqueue!(to_check, (range1, rulekey, index+1))
                        @debug "    $(last(to_check))"
                        range2 = Range((condition.value+1, maxx, minm,maxm,mina,maxa,mins,maxs))
                        # this range fulfils the condition, send it to the next rule
                        enqueue!(to_check, (range2, condition.send, 1))
                        @debug "    $(last(to_check))"
                    else
                        # the entire range fulfils the condition
                        enqueue!(to_check, (range, condition.send, 1))
                        @debug "  range inside condition, queue $(last(to_check))"
                    end
                end
            elseif condition.attr == :m
                if condition.comp == (<)
                    if condition.value <= minm
                        enqueue!(to_check, (range, rulekey, index+1))
                        @debug "  range outside condition, queue $(last(to_check))"
                    elseif minm < condition.value <= maxm
                        @debug "  range partially in condition, queue"
                        range1 = Range((minx,maxx,minm,condition.value-1,mina,maxa,mins,maxs))
                        enqueue!(to_check, (range1, condition.send, 1))
                        @debug "    $(last(to_check))"
                        range2 = Range((minx,maxx,condition.value,maxm,mina,maxa,mins,maxs))
                        enqueue!(to_check, (range2, rulekey, index+1))
                        @debug "    $(last(to_check))"
                    else
                        enqueue!(to_check, (range, condition.send, 1))
                        @debug "  range inside condition, queue $(last(to_check))"
                    end
                else  # condition.comp = >
                    if condition.value >= maxm
                        enqueue!(range, rulekey, index+1)
                        @debug "  range outside condition, queue $(last(to_check))"
                    elseif minm <= condition.value < maxm
                        @debug "  range partially in condition, queue"
                        range1 = Range((minx,maxx,minm,condition.value,mina,maxa,mins,maxs))
                        enqueue!(to_check, (range1, rulekey, index+1))
                        @debug "    $(last(to_check))"
                        range2 = Range((minx,maxx,condition.value+1,maxm,mina,maxa,mins,maxs))
                        enqueue!(to_check, (range2, condition.send, 1))
                        @debug "    $(last(to_check))"
                    else
                        enqueue!(to_check, (range, condition.send, 1))
                        @debug "  range inside condition, queue $(last(to_check))"
                    end
                end
            elseif condition.attr == :a
                if condition.comp == (<)
                    if condition.value <= mina
                        enqueue!(range, rulekey, index+1)
                        @debug "  range inside condition, queue $(last(to_check))"
                    elseif mina < condition.value <= maxa
                        @debug "  range partially in condition, queue"
                        range1 = Range((minx,maxx,minm,maxm,mina,condition.value-1,mins,maxs))
                        enqueue!(to_check, (range1, condition.send, 1))
                        @debug "    $(last(to_check))"
                        range2 = Range((minx,maxx,minm,maxm,condition.value,maxa,mins,maxs))
                        enqueue!(to_check, (range2, rulekey, index+1))
                        @debug "    $(last(to_check))"
                    else
                        enqueue!(to_check, (range, condition.send, 1))
                        @debug "  range inside condition, queue $(last(to_check))"
                    end
                else  # condition.comp = >
                    if condition.value >= maxa
                        enqueue!(range, rulekey, index+1)
                        @debug "  range outside condition, queue $(last(to_check))"
                    elseif mina <= condition.value < maxa
                        @debug "  range partially in condition, queue"
                        range1 = Range((minx,maxx,minm,maxm,mina,condition.value,mins,maxs))
                        enqueue!(to_check, (range1, rulekey, index+1))
                        @debug "    $(last(to_check))"
                        range2 = Range((minx,maxx,minm,maxm,condition.value+1,maxa,mins,maxs))
                        enqueue!(to_check, (range2, condition.send, 1))
                        @debug "    $(last(to_check))"
                    else
                        enqueue!(to_check, (range, condition.send, 1))
                        @debug "  range inside condition, queue $(last(to_check))"
                    end
                end
            elseif condition.attr == :s
                if condition.comp == (<)
                    if condition.value <= mins
                        enqueue!(range, rulekey, index+1)
                        @debug "  range inside condition, queue $(last(to_check))"
                    elseif mins < condition.value <= maxs
                        @debug "  range partially in condition, queue"
                        range1 = Range((minx,maxx,minm,maxm,mina,maxa,mins,condition.value-1))
                        enqueue!(to_check, (range1, condition.send, 1))
                        @debug "    $(last(to_check))"
                        range2 = Range((minx,maxx,minm,maxm,mina,maxa,condition.value,maxs))
                        enqueue!(to_check, (range2, rulekey, index+1))
                        @debug "    $(last(to_check))"
                    else
                        enqueue!(to_check, (range, condition.send, 1))
                        @debug "  range inside condition, queue $(last(to_check))"
                    end
                else  # condition.comp = >
                    if condition.value >= maxs
                        enqueue!(range, rulekey, index+1)
                        @debug "  range outside condition, queue $(last(to_check))"
                    elseif mins <= condition.value < maxs
                        @debug "  range partially in condition, queue"
                        range1 = Range((minx,maxx,minm,maxm,mina,maxa,mins,condition.value))
                        enqueue!(to_check, (range1, rulekey, index+1))
                        @debug "    $(last(to_check))"
                        range2 = Range((minx,maxx,minm,maxm,mina,maxa,condition.value+1,maxs))
                        enqueue!(to_check, (range2, condition.send, 1))
                        @debug "    $(last(to_check))"
                    else
                        enqueue!(to_check, (range, condition.send, 1))
                        @debug "  range inside condition, queue $(last(to_check))"
                    end
                end
            end
        end
    end
    ranges
end


function intersections_area(ranges)
    A = 0
    # calculate pairwise intersection areas and add them up
    for (r1,r2) in combinations(ranges, 2)
        A += (
            length(intersect(r1.minx:r1.maxx, r2.minx:r2.maxx))
            * length(intersect(r1.minm:r1.maxm, r2.minm:r2.maxm))
            * length(intersect(r1.mina:r1.maxa, r2.mina:r2.maxa))
            * length(intersect(r1.mins:r1.maxs, r2.mins:r2.maxs))
        )
    end
    A
end


function solve2(parsed)
    rules, _ = parsed
    _ranges = rules_to_ranges(rules)
    # stupid
    ranges = map(_ranges) do r
        (r.minx:r.maxx, r.minm:r.maxm, r.mina:r.maxa, r.mins:r.maxs)
    end
    nd_union_volume(ranges)
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
