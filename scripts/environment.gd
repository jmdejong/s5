extends Node3D


const Chunk = preload("res://scenes/chunk.tscn")
const TreeChunk = preload("res://scenes/tree_chunk.tscn")
const max_lod = 10
const min_lod = 0
var chunks = {}
var root_chunk
var min_size = 16
var used_chunks = []
@export var chunk_size = Vector2(32, 32)
@export var max_render_distance = 1024

#func _init():
#	for i in range(min_lod, max_lod):
#		chunks[i] = {}
		

#func _ready():
	#add_chunk(0, 0)
	#root_chunk = add_tree_chunk(Vector2(0, 0), 4096, 0)
	#for x in range(-4, 4):
	#	for y in range(-4, 4):
	#		add_chunk(Vector2i(x, y))

func add_chunk(pos):
	var chunk = Chunk.instantiate() 
	chunk.position = Vector3(pos.x * chunk_size.x, 0, pos.y * chunk_size.y)
	chunk.size = chunk_size
	chunk.blueprint = $Blueprint
	add_child(chunk)
	chunks[pos] = chunk

func set_viewpoint(viewpoint2):
	# render_chunks(viewpoint2)
	render_tree_cunks(viewpoint2)

func render_chunks(viewpoint2):
	var viewpos = Vector2i((viewpoint2 / chunk_size).round())
	var to_render = [null, null, null, null, null, null, null]
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
			var closest_lod = to_render[needed_lod]
			if closest_lod == null or dist < viewpoint2.distance_to(Vector2(closest_lod.position.x, closest_lod.position.z)):
				to_render[needed_lod] = chunk
	for lod in range(len(to_render)):
		var level = to_render[lod]
		if level != null:
			level.render(lod)

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

func render_shaded(viewpoint2):
	$ShadedMap.position = Vector3(viewpoint2.x, 0, viewpoint2.y)

func _process(delta):
	var camera_pos = get_node("%Eyes").global_position
	var viewpoint2 = Vector2(camera_pos.x, camera_pos.z)
	set_viewpoint(viewpoint2)
	$ShadedMap.position.x = camera_pos.x
	$ShadedMap.position.z = camera_pos.z
	

func render_grid(area, subdivisions):
	pass

func render_tree_cunks(viewpoint2):
	if $Blueprint.heightmap == null:
		return
	if root_chunk == null:
		root_chunk = add_tree_chunk(Vector2(0, 0), 8192, 0)
	if used_chunks.is_empty():
		used_chunks.append(root_chunk)
	var branch_chunks = [root_chunk]
	var to_render = []
	var splits = 0
	while not branch_chunks.is_empty():
		var chunk = branch_chunks.pop_front() # todo: more efficient FIFO queue
		if should_split(chunk, viewpoint2) and chunk.children == null and splits < 1:
			splits += 1
			var new_size = chunk.size / 2;
			chunk.children = []
			for o in [Vector2(1, 1), Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1)]:
				chunk.children.append(
					add_tree_chunk(Vector2(chunk.position.x, chunk.position.z) - o * new_size / 2, new_size, chunk.depth + 1)
				)
		if chunk.children == null:
			chunk.visible = true
		else:
			chunk.visible = false
			branch_chunks.append_array(chunk.children)
	# var i = 0
	# for chunk in to_render:
	# 	if i == 1:
	# 		break
	# 	i+=1
	# 	chunk.render_self()

func add_tree_chunk(pos, size, depth):
	var chunk = TreeChunk.instantiate()
	chunk.position.x = pos.x
	chunk.position.z = pos.y
	chunk.size = size
	chunk.blueprint = $Blueprint
	chunk.depth = depth
	chunk.render()
	add_child(chunk)
	return chunk


func should_split(chunk, viewpoint2):
	return chunk.distance_to_edge(viewpoint2) < chunk.size and chunk.size > min_size


