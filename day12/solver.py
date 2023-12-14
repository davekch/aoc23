import functools

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


@functools.lru_cache(maxsize=None)
def n_possibilities(record, damaged):
    chunks = [c for c in record.split(".") if c != ""]
    lchunks = tuple(map(len, chunks))
    if "?" not in record:
        if lchunks == damaged:
            return 1
        else:
            return 0
    n = 0
    n += n_possibilities(record.replace("?", ".", 1), damaged)
    n += n_possibilities(record.replace("?", "#", 1), damaged)
    return n


# PART 1
@measure_time
def solve1(data):
    n = 0
    for record, damaged in data:
        n += n_possibilities(record, damaged)
    return n


# PART 2
@measure_time
def solve2(data):
    pass


if __name__ == "__main__":
    data = parse(open("input.txt").read().strip())
    print("Part 1: {}".format(solve1(data)))
    print("Part 2: {}".format(solve2(data)))

    print("\nTime taken:")
    for func, time in measure_time.times:
        print(f"{func:8}{time}s")
    print("----------------")
    print("total   {}s".format(sum(t for _, t in measure_time.times)))

