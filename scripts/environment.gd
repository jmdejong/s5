extends Node3D


const Chunk = preload("res://scenes/chunk.tscn")
var chunks = {}
@export var chunk_size = Vector2(32, 32)
@export var max_render_distance = 512

func _ready():
	#add_chunk(0, 0)
	for x in range(-4, 4):
		for y in range(-4, 4):
			add_chunk(Vector2i(x, y))

func add_chunk(pos):
	var chunk = Chunk.instantiate() 
	chunk.position = Vector3(pos.x * chunk_size.x, 0, pos.y * chunk_size.y)
	chunk.size = chunk_size
	chunk.blueprint = $Blueprint
	add_child(chunk)
	chunks[pos] = chunk

func set_viewpoint(viewpoint):
	var viewpoint2 = Vector2(viewpoint.x, viewpoint.z)
	var viewpos = Vector2i((viewpoint2 / chunk_size).round())
	var to_render = [[], [], [], []]
	for chunk in chunks_within_distance(viewpoint2):
		var chunkpoint2 = Vector2(chunk.position.x, chunk.position.z)
		var dist = viewpoint2.distance_to(chunkpoint2)
		var needed_lod = 0
		if dist < 256:
			needed_lod = 1
			if dist < 128:
				needed_lod = 2
				if dist < 64:
					needed_lod = 3
		if chunk.lod < needed_lod:
			to_render[needed_lod].append(chunk)
	for lod in range(len(to_render)):
		var level = to_render[lod]
		if not level.is_empty():
			level.front().render(lod)

func chunks_within_distance(viewpoint2):
	var selected_chunks = []
	var mdist2 = Vector2(max_render_distance, max_render_distance)
	var pmin = Vector2i(((viewpoint2 - mdist2) / chunk_size).floor())
	var pmax = Vector2i(((viewpoint2 + mdist2) / chunk_size).ceil())
	for x in range(pmin.x, pmax.x):
		for y in range(pmin.y, pmax.y):
			var pos = Vector2i(x, y)
			if not chunks.has(pos):
				add_chunk(pos)
			selected_chunks.append(chunks[pos])
	return selected_chunks
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera_pos = get_node("%Eyes").global_position
	set_viewpoint(camera_pos)
