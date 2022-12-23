extends Node3D

var size;
var depth;
var blueprint;
var children = null
const tiles = Vector2(64, 64)
@export var shader: Shader
var is_rendered = false

func render():
	var size2 = Vector2(size, size)
	$WaterMesh.scale = Vector3(size, 1, size)
	$TerrainMesh.scale = Vector3(size, 1, size)


	if blueprint.gen_gpu:
		$GroundMesh.visible = false
		$TerrainMesh.visible = true

		$TerrainMesh.mesh.material = blueprint.heightmaterial

		$TerrainMesh.custom_aabb = AABB(
				Vector3(-0.5, blueprint.aabb.position.y, -0.5),
				Vector3(1, blueprint.aabb.size.y, 1)
		)
		is_rendered = true
	else:
		$GroundMesh.visible = true
		$TerrainMesh.visible = false

		var area = Rect2(Vector2(position.x, position.z) - size2 / 2, size2)
		if not area.intersects(blueprint.area):
			return
		var tile_size = Vector2(size / tiles.x, size / tiles.y)

		var surface_array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		var verts = PackedVector3Array()
		var uvs = PackedVector2Array()
		var normals = PackedVector3Array()
		var indices = PackedInt32Array()

		var width = tiles.x + 1
		for xi in range(0, tiles.x + 1):
			for yi in range(0, tiles.y + 1):
				var x = xi * tile_size.x - size / 2
				var y = yi * tile_size.y - size / 2
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
		is_rendered = true

func prune():
	if children != null:
		for child in children:
			child.prune()
			child.queue_free()
	children = null


func vert_at(x, y):
	# return Vector3(x, 0, y)
	return Vector3(x, blueprint.height_at(position.x + x, position.z + y), y)

func distance_to_edge(pos: Vector2):
	var center = Vector2(position.x, position.z)
	var corner_offset = Vector2(size, size) / 2
	var closest_in_chunk = pos.clamp(center - corner_offset, center + corner_offset)
	return (pos - closest_in_chunk).length()


func _on_visibility_changed():
	$GroundMesh.visible = visible and not blueprint.gen_gpu
	$TerrainMesh.visible = visible and blueprint.gen_gpu
	$WaterMesh.visible = visible
