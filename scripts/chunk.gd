extends Node3D

var size

var blueprint
var viewpoint

var lod = -1

const lod_tiles = [Vector2i(4, 4), Vector2i(8, 8), Vector2i(16, 16), Vector2i(32, 32)];


	
func render(new_lod):
	$WaterMesh.mesh.size = size
	
	lod = new_lod
	var area = Rect2(Vector2(position.x, position.z) - size / 2, size)
	if not area.intersects(blueprint.area):
		return
	var tiles = lod_tiles[new_lod]
	var tile_size = Vector2(size.x / tiles.x, size.y / tiles.y)
	
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
			var pos = vert_at(x, y)
			var normal = Plane(pos, vert_at(pos.x+0.01, pos.z), vert_at(pos.x, pos.z+0.01)).normal
			verts.append(pos)
			normals.append(normal)
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
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	$GroundMesh.mesh = mesh

func add_vertex(st, pos):
	var normal = Plane(pos, vert_at(pos.x+0.01, pos.z), vert_at(pos.x, pos.z+0.01)).normal
	st.set_normal(normal)
	st.add_vertex(pos)

func vert_at(x, y):
	return Vector3(x, blueprint.height_at(position.x + x, position.z + y), y)


