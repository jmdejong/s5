extends Node3D

var size

var blueprint
var viewpoint

var lod = -1

const lod_tiles = [Vector2i(4, 4), Vector2i(8, 8), Vector2i(16, 16), Vector2i(32, 32)];

func _ready():
	print("initializing chunk")
	#render(Vector2i(32, 32))


func render(new_lod):
	
	var tiles = lod_tiles[new_lod]
	var st = SurfaceTool.new()
	st.clear()
	var tile_size = Vector2(size.x / tiles.x, size.y / tiles.y)
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for xi in range(-tiles.x / 2, tiles.x / 2):
		for yi in range(-tiles.y / 2, tiles.y / 2):
			var x = xi * tile_size.x
			var y = yi * tile_size.y
			var x0y0 = vert_at(x, y)
			var x1y0 = vert_at(x+tile_size.x, y)
			var x0y1 = vert_at(x, y+tile_size.y)
			var x1y1 = vert_at(x+tile_size.x, y+tile_size.y)
			add_vertex(st, x0y0)
			add_vertex(st, x1y0)
			add_vertex(st, x0y1)
			add_vertex(st, x0y1)
			add_vertex(st, x1y0)
			add_vertex(st, x1y1)
	st.generate_tangents()
	$GroundMesh.mesh = st.commit()
	
	$WaterMesh.mesh.size = size
	lod = new_lod

func add_vertex(st, pos):
	var normal = Plane(pos, vert_at(pos.x+0.01, pos.z), vert_at(pos.x, pos.z+0.01)).normal
	st.set_normal(normal)
	st.add_vertex(pos)

func vert_at(x, y):
	return Vector3(x, blueprint.height_at(position.x + x, position.z + y), y)


