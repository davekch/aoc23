import functools
import itertools
from collections import Counter

from aoc import utils

measure_time = utils.stopwatch()


@measure_time
def parse(raw_data):
    data = []
    for line in raw_data.strip().splitlines():
        record, damaged = line.split()
        damaged = tuple([int(x) for x in damaged.split(",")])
        data.append((record, damaged))
    return data


def build_transition_tree(ns: tuple[int]) -> dict:
    """
    convert a spring specification into a dict of transitions of a fsm
    """
    transitions = {}
    curr = 0
    for n in ns:
        # before a sequence of #s we can have either dots or a #
        transitions[curr] = {".": [curr], "#": [curr + 1], "?": [curr, curr + 1]}
        curr += 1
        # for n-1 times, we can only go to a next #
        for i in range(n-1):
            transitions[curr] = {"#": [curr + 1], "?": [curr + 1]}
            curr += 1
        # now we must go to a ., ending the sequence of #s
        transitions[curr] = {".": [curr + 1], "?": [curr + 1]}
        curr += 1
    # at the very end we can have arbitrarily many dots
    transitions[curr] = {".": [curr], "?": [curr]}
    return transitions


def count_valid(transitions, string):
    # keep track of states we're in and how often
    states = Counter({0: 1})
    for char in string:
        newstates = Counter()
        for state, count in states.items():
            # only if there is a transition for this char, the string is valid and we move to all next states
            if char in transitions[state]:
                for next_state in transitions[state][char]:
                    newstates[next_state] += count
        states = newstates
    # the last two are both valid states; the very last one represents repeated dots
    return states[max(transitions.keys())] + states[max(transitions.keys()) - 1]


# PART 1
@measure_time
def solve1(data):
    n = 0
    for record, damaged in data:
        transitions = build_transition_tree(damaged)
        valid = count_valid(transitions, record)
        # print(f"{record} {damaged}: {valid=}")
        n += valid
    return n


# PART 2
@measure_time
def solve2(data):
    n = 0
    for record, damaged in data:
        record = "?".join(itertools.repeat(record, 5))
        damaged = ",".join(itertools.repeat(",".join(map(str, damaged)), 5))
        damaged = map(int, damaged.split(","))
        transitions = build_transition_tree(damaged)
        n += count_valid(transitions, record)
    return n


if __name__ == "__main__":
    data = parse(open("input.txt").read().strip())
    print("Part 1: {}".format(solve1(data)))
    print("Part 2: {}".format(solve2(data)))

    print("\nTime taken:")
    for func, time in measure_time.times:
        print(f"{func:8}{time}s")
    print("----------------")
    print("total   {}s".format(sum(t for _, t in measure_time.times)))

