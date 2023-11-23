#!/bin/bash

export AOC_SESSION=$(cat AOC_SESSION)
source ~/.virtualenvs/aoc/bin/activate

alias init="python aoc/init.py"
alias initjl="init -l jl"

