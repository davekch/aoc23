import sys
from pyvis.network import Network
import networkx as nx

with open("input.txt") as f:
    raw = f.read()

graph = {}
for line in raw.splitlines():
    k, v = line.split(" -> ")
    graph[k.strip()[1:]] = [c.strip() for c in v.split(",")]

G = nx.DiGraph()

for mod, outgoing in graph.items():
    for dep in outgoing:
        G.add_edge(mod, dep)

net = Network(height="2000px", directed=True)
net.toggle_physics(True)
net.from_nx(G)
# net.show_buttons(filter_=["physics"])
net.save_graph("network.html")
