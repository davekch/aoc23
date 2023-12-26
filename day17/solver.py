import sys

from aoc import utils

measure_time = utils.stopwatch()


@measure_time
def parse(raw_data):
    grid = {}
    for y, line in enumerate(raw_data.splitlines()):
        for x, c in enumerate(line):
            grid[(x, y)] = int(c)
    return grid


def distance_func(node1, node2, graph):
    return graph[node2[0]]


def neighbors_func(graph, node):
    p, d, c = node
    d1 = (d[1], -d[0])  # rotated
    d2 = (-d[1], d[0])
    ns = [((p[0]+d1[0], p[1]+d1[1]), d1, 1),
          ((p[0]+d2[0], p[1]+d2[1]), d2, 1)
          ]
    if c <= 2:
        ns.append(((p[0]+d[0], p[1]+d[1]), d, c+1))
    return filter(lambda n: n[0] in graph, ns)


def visualize(graph, path, start, current):
    shortest = utils.shortestpath(path, start, current)
    grid = graph | {p[0]: "x" for p in shortest}
    grid[current[0]] = "X"
    print(utils.dictgrid_to_str(grid))

# PART 1
@measure_time
def solve1(data):
    _, maxx, _, maxy = utils.corners(data)
    start = ((0,0), (1,0), 1)
    finish = lambda node: node[0] == (maxx, maxy)
    # finish = lambda node: node[0] == (5, 0)
    finished, distances, paths = utils.dijkstra(
        data,
        start,
        neighbors_func,
        distance_func,
        finish,
        # visualize
    )
    return distances[finished]


def neighbors_func_p2(graph, node):
    p, d, c = node
    d1 = (d[1], -d[0])  # rotated
    d2 = (-d[1], d[0])
    if c < 4:
        ns = [((p[0]+d[0], p[1]+d[1]), d, c+1)]
    elif c == 10:
        ns = [
            ((p[0]+d1[0], p[1]+d1[1]), d1, 1),
            ((p[0]+d2[0], p[1]+d2[1]), d2, 1)
        ]
    else:
        ns = [
            ((p[0]+d[0], p[1]+d[1]), d, c+1),
            ((p[0]+d1[0], p[1]+d1[1]), d1, 1),
            ((p[0]+d2[0], p[1]+d2[1]), d2, 1)
        ]
    return filter(lambda n: n[0] in graph, ns)


# PART 2
@measure_time
def solve2(data):
    _, maxx, _, maxy = utils.corners(data)
    start = ((0,0), (1,0), 1)
    finish = lambda node: node[0] == (maxx, maxy)
    # finish = lambda node: node[0] == (5, 0)
    finished, distances, paths = utils.dijkstra(
        data,
        start,
        neighbors_func_p2,
        distance_func,
        finish,
        # visualize
    )
    return distances[finished]


if __name__ == "__main__":
    data = parse(open("input.txt").read().strip())
    print("Part 1: {}".format(solve1(data)))
    print("Part 2: {}".format(solve2(data)))

    print("\nTime taken:")
    for func, time in measure_time.times:
        print(f"{func:8}{time}s")
    print("----------------")
    print("total   {}s".format(sum(t for _, t in measure_time.times)))

