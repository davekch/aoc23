module Solver
using Test
using AoC
using AoC.Utils

@enum PULSE begin
    HI
    LO
end

abstract type AbstractModule end

const Network = Dict{String, AbstractModule}
const Message = Union{PULSE, Nothing}

function send!(modules::Network, m::AbstractModule)
    hi_pulses = 0
    lo_pulses = 0
    if m.msg_buf !== nothing
        for r in m.out_connections
            receiver = modules[r]
            receive!(receiver, m.name, m.msg_buf)
            if m.msg_buf == HI
                println("$(m.name) hi -> $(receiver.name)")
                hi_pulses += 1
            elseif m.msg_buf == LO
                println("$(m.name) lo -> $(receiver.name)")
                lo_pulses += 1
            end
        end
        println("-----------")
        m.msg_buf = nothing  # empty message buffer after sending
    end
    hi_pulses, lo_pulses
end

process!(m::AbstractModule) = nothing
receive!(receiver::AbstractModule, from, msg) = nothing


# ----------- module implementations

@kwdef mutable struct FlipFlop <: AbstractModule
    name::AbstractString
    out_connections::Vector{<:AbstractString}
    msg_buf::Message = nothing
    incoming::Message = nothing
    state::Bool = false
end

function receive!(flipflop::FlipFlop, from, msg)
    flipflop.incoming = msg
end

function process!(flipflop::FlipFlop)
    if flipflop.incoming == LO
        flipflop.state = !flipflop.state
        flipflop.msg_buf = flipflop.state ? HI : LO
    end
    flipflop.incoming = nothing
end


@kwdef mutable struct Conjunction <: AbstractModule
    name::AbstractString
    out_connections::Vector{<:AbstractString}
    msg_buf::Message = nothing
    incoming::Dict{AbstractString, Message} = Dict()
    should_send::Bool = false
end

function receive!(conjunction::Conjunction, from, msg)
    conjunction.incoming[from] = msg
    # should send only if we received something (apparently)
    conjunction.should_send = true
end

function process!(conjunction::Conjunction)
    if conjunction.should_send
        if all([i == HI for i in values(conjunction.incoming)])
            conjunction.msg_buf = LO
        else
            conjunction.msg_buf = HI
        end
        conjunction.should_send = false
    end
end


@kwdef mutable struct Broadcast <: AbstractModule
    out_connections::Vector{<:AbstractString}
    name::AbstractString = "broadcaster"
    msg_buf::Message = nothing
    incoming::Message = nothing
end

function receive!(broadcaster::Broadcast, from, msg)
    broadcaster.incoming = msg
end

function process!(broadcaster::Broadcast)
    broadcaster.msg_buf = broadcaster.incoming
    broadcaster.incoming = nothing
end


@kwdef struct Dummy <: AbstractModule
    name::AbstractString
    out_connections::Vector{AbstractString} = []
    msg_buf::Message = nothing
end

# ---------------------------------------


function parse_input(raw_data)
    network = Network()
    for line in raw_data |> strip |> lines
        label, connections = split(line, " -> ")
        connections = split(connections, ", ")
        if label[1] == '%'
            network[label[2:end]] = FlipFlop(name=label[2:end], out_connections=connections)
        elseif label[1] == '&'
            network[label[2:end]] = Conjunction(name=label[2:end], out_connections=connections)
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
    receive!(network["broadcaster"], "button", LO)
    newpulses = 1
    println("button lo -> broadcaster -------------")
    while newpulses > 0
        for m in values(network)
            process!(m)
        end
        newpulses = 0
        for m in values(network)
            his, los = send!(network, m)
            hi_pulses += his
            lo_pulses += los
            newpulses += his + los
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


function solve2(parsed)
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
