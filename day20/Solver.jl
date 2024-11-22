module Solver
using Test
using AoC
using AoC.Utils
using DataStructures


@enum PULSE begin
    HI
    LO
end

abstract type AbstractModule end

const Network = Dict{String, AbstractModule}
const Message = Union{PULSE, Nothing}

# get an incoming message and return a vector of (from, to, message)
process!(m::AbstractModule, from, msg) = nothing


# ----------- module implementations

mutable struct FlipFlop <: AbstractModule
    name::AbstractString
    out_connections::Vector{<:AbstractString}
    state::Bool
end

function process!(flipflop::FlipFlop, from, msg)
    if msg == LO
        flipflop.state = !flipflop.state
        out = flipflop.state ? HI : LO
        return [(flipflop.name, to, out) for to in flipflop.out_connections]
    end
end

mutable struct Conjunction <: AbstractModule
    name::AbstractString
    out_connections::Vector{<:AbstractString}
    incoming::Dict{AbstractString, Message}
end

function process!(conjunction::Conjunction, from, msg)
    conjunction.incoming[from] = msg
    out = missing
    if all([i == HI for i in values(conjunction.incoming)])
        out = LO
    else
        out = HI
    end
    [(conjunction.name, to, out) for to in conjunction.out_connections]
end

@kwdef mutable struct Broadcast <: AbstractModule
    out_connections::Vector{<:AbstractString}
    name::AbstractString = "broadcaster"
end

function process!(broadcast::Broadcast, from, msg)
    [(broadcast.name, to, msg) for to in broadcast.out_connections]
end

@kwdef struct Dummy <: AbstractModule
    name::AbstractString
    out_connections::Vector{AbstractString} = []
end

# ---------------------------------------


function parse_input(raw_data)
    network = Network()
    for line in raw_data |> strip |> lines
        label, connections = split(line, " -> ")
        connections = split(connections, ", ")
        if label[1] == '%'
            network[label[2:end]] = FlipFlop(label[2:end], connections, false)
        elseif label[1] == '&'
            network[label[2:end]] = Conjunction(label[2:end], connections, Dict())
        elseif label == "broadcaster"
            network[label] = Broadcast(out_connections=connections)
        else
            network[label] = Dummy(name=label)
        end
    end
    # fill all the incoming connections for conjunctions and create dummies
    for mod in values(network)
        for c in mod.out_connections
            if c ∉ keys(network)
                network[c] = Dummy(name=c)
            elseif typeof(network[c]) <: Conjunction
                network[c].incoming[mod.name] = LO
            end
        end
    end
    network
end
export parse_input


function button!(network)
    hi_pulses = 0
    lo_pulses = 1
    to_process = Queue{Tuple{String, String, Message}}()
    for pulse in process!(network["broadcaster"], "button", LO)
        lo_pulses += 1
        enqueue!(to_process, pulse)
    end
    while !isempty(to_process)
        from, to, msg = dequeue!(to_process)
        # println("$from $msg -> $to")
        outs = process!(network[to], from, msg)
        if outs !== nothing
            for out in outs
                if out[3] == LO
                    lo_pulses += 1
                elseif out[3] == HI
                    hi_pulses += 1
                end
                enqueue!(to_process, out)
            end
        end
    end
    hi_pulses, lo_pulses
end
export button!


function solve1(network)
    network = deepcopy(network)  # let original network intact for p2
    hi_pulses = 0
    lo_pulses = 0
    for i = 1:1000
        his, los = button!(network)
        # println(network)
        hi_pulses += his
        lo_pulses += los
    end
    println((hi_pulses, lo_pulses))
    hi_pulses * lo_pulses
end
export solve1


function solve2(network)
    # basically button! again but with cycle detection
    # hard coded: cl, bm, dr, tn are the nodes that must send HI at the same time,
    # they send to the conjunction vr which alone sends to rx
    cl_cycle = 0
    bm_cycle = 0
    dr_cycle = 0
    tn_cycle = 0
    btn_presses = 0
    while any([x==0 for x in [cl_cycle, bm_cycle, dr_cycle, tn_cycle]])
        to_process = Queue{Tuple{String, String, Message}}()
        btn_presses += 1
        for pulse in process!(network["broadcaster"], "button", LO)
            enqueue!(to_process, pulse)
        end
        while !isempty(to_process)
            from, to, msg = dequeue!(to_process)
            if to == "vr" && from == "cl" && msg == HI
                cl_cycle = btn_presses
            elseif to == "vr" && from == "bm" && msg == HI
                bm_cycle = btn_presses
            elseif to == "vr" && from == "dr" && msg == HI
                dr_cycle = btn_presses
            elseif to == "vr" && from == "tn" && msg == HI
                tn_cycle = btn_presses
            end
            outs = process!(network[to], from, msg)
            if outs !== nothing
                for out in outs
                    enqueue!(to_process, out)
                end
            end
        end
    end
    return cl_cycle * bm_cycle * dr_cycle * tn_cycle
end
export solve2


solution = Solution(parse_input, solve1, solve2)

testinput = """broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
"""
testanswer_1 = 11687500
testanswer_2 = nothing
export testinput, testanswer_1, testanswer_2

test() = AoC.test_solution(solution, testinput, testanswer_1, testanswer_2)
export test

testinput2 = """broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a
"""
testanser_1_2 = 32000000
test2() = AoC.test_solution(solution, testinput2, testanser_1_2, nothing)
export test2

main(part=missing) = AoC.main(solution, part)
export main


end # module Solver
