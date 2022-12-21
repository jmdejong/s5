#!/usr/bin/env python3

sub = 128

vertices = []
quads = []
width = sub * 2 + 1

for i in range(-3, 10):
	scale = (2**i) / sub
	for x in range(-sub, sub + 1):
		for y in range(-sub, sub + 1):
			vertices.append((x * scale, y * scale))
			if x != sub and y != sub and not (x >= -sub/2 and x < sub/2 and y >= -sub/2 and y < sub/2):
				ind = len(vertices)
				quads.append((ind, ind + 1, ind + width, ind + width + 1))


for (x, z) in vertices:
	print("v", x, "0.0", z)

for (x0y0, x1y0, x0y1, x1y1) in quads:
	print("f", x0y0, x1y0, x0y1)
	print("f", x0y1, x1y0, x1y1)

