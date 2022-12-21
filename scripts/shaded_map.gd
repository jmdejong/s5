extends MeshInstance3D

var tiles = Vector2(256, 256)
var size = Vector2(256, 256)
var tile_size = size / tiles


func _init():
	return;
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	var width = tiles.x + 1
	for xi in range(0, tiles.x + 1):
		for yi in range(0, tiles.y + 1):
			var x = xi * tile_size.x - size.x / 2
			var y = yi * tile_size.y - size.y / 2
			var normal = Vector3(0, 1, 0)
			verts.append(Vector3(x, 0, y))
			normals.append(Vector3(0, 1, 0))
			uvs.append(Vector2(0, 0))
	for x in range(0, tiles.x):
		for y in range(0, tiles.y):
			var idx = x + width * y
			indices.append(idx)
			indices.append(idx + width)
			indices.append(idx + 1)
			indices.append(idx + 1)
			indices.append(idx + width)
			indices.append(idx + width + 1)
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

