extends Node3D

var size
var blueprint;
var children = null

const ntiles = 32
@export var shader: Shader
var is_rendered = false
const decode_scale = 255
const decode_total = 255 * 255
var mutex

func render():
	mutex = Mutex.new()
	var size2 = Vector2(size, size)
	var area = Rect2(Vector2(position.x, position.z) - size2 / 2, size2)
	var tile_size = Vector2(size / ntiles, size / ntiles)
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
		$TerrainMesh.mesh.subdivide_width = ntiles
		$TerrainMesh.mesh.subdivide_depth = ntiles
		
		if size == ntiles:
			var fs = HeightMapShape3D.new()
			fs.map_width = ntiles+1
			fs.map_depth = ntiles+1
			var p = position - blueprint.aabb.position
			var region = Rect2i(p.x - ntiles / 2, p.z - ntiles / 2, ntiles, ntiles)
			#var im = blueprint.heightmap_image.get_region(region)
			#var rawdata = im.get_data()
			var heightdata = PackedFloat32Array()
			heightdata.resize((ntiles + 1) * (ntiles + 1))
			var i = 0
			for yi in range(0, ntiles+1):
				for xi in range(0, ntiles+1):
					var x = xi * tile_size.x - size / 2 + position.x
					var y = yi * tile_size.y - size / 2 + position.z
					var h = blueprint.height_at(Vector2(x, y))#float(rawdata.decode_u8(i*4) * decode_scale + rawdata.decode_u8(i*4+1)) / decode_total
					# var h = (ch.r + ch.g/255) * blueprint.aabb.size.y + blueprint.aabb.position.y
					heightdata[i] = h
					i += 1
			fs.map_data = heightdata
			$Floor/Height.shape = fs
			$Floor/Height.position = Vector3(0.5, 0, 0.5)
		
		is_rendered = true
	else:
		$GroundMesh.visible = true
		$TerrainMesh.visible = false

		if not area.intersects(blueprint.area):
			return

		var surface_array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		var verts = PackedVector3Array()
		var uvs = PackedVector2Array()
		var normals = PackedVector3Array()
		var indices = PackedInt32Array()

		var width = ntiles + 1
		for xi in range(0, ntiles + 1):
			for yi in range(0, ntiles + 1):
				var x = xi * tile_size.x - size / 2
				var y = yi * tile_size.y - size / 2
				var pos = vert_at(x, y)
				var normal = Plane(pos, vert_at(pos.x+0.01, pos.z), vert_at(pos.x, pos.z+0.01)).normal
				verts.append(pos)
				normals.append(normal)
				uvs.append(Vector2(0, 0))
		for x in range(0, ntiles):
			for y in range(0, ntiles):
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
	return Vector3(x, blueprint.height_at(Vector2(position.x + x, position.z + y)), y)

func distance_to_edge(pos: Vector2):
	var center = Vector2(position.x, position.z)
	var corner_offset = Vector2(size, size) / 2
	var closest_in_chunk = pos.clamp(center - corner_offset, center + corner_offset)
	return (pos - closest_in_chunk).length()


func _on_visibility_changed():
	$GroundMesh.visible = visible and not blueprint.gen_gpu
	$TerrainMesh.visible = visible and blueprint.gen_gpu
	$WaterMesh.visible = visible
