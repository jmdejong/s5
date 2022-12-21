#!/usr/bin/env python3

sub = 128

last_index = 1
vertices = []
known_vertices = {}
quads = []
width = sub * 2 + 1

def get_vert(scale, x, y):
	pos = (x*scale, y*scale)
	global known_vertices
	global vertices
	if pos not in known_vertices:
		global last_index
		known_vertices[pos] = last_index
		vertices.append(pos)
		last_index += 1
	return known_vertices[pos]


start = 5
for i in range(start, 14):
	scale = (2**i) / sub
	for x in range(-sub, sub):
		for y in range(-sub, sub):
			if i == start or not (x >= -sub/2 and x < sub/2 and y >= -sub/2 and y < sub/2):
				quads.append((get_vert(scale, x, y), get_vert(scale, x, y + 1), get_vert(scale, x+1, y), get_vert(scale, x+1, y+1)))


for (x, z) in vertices:
	print("v", x, "0.0", z)

for (x0y0, x1y0, x0y1, x1y1) in quads:
	print("f", x0y0, x1y0, x0y1)
	print("f", x0y1, x1y0, x1y1)

