extends Node3D

const TreeChunk = preload("res://scenes/tree_chunk.tscn")
var root_chunk
@export var max_render_distance = 1024

func set_viewpoint(viewpoint2):
	render_tree_cunks(viewpoint2)

func _process(delta):
	var camera_pos = get_node("%Eyes").global_position
	var viewpoint2 = Vector2(camera_pos.x, camera_pos.z)
	set_viewpoint(viewpoint2)


func render_tree_cunks(viewpoint2):
	if $Blueprint.heightmap == null and $Blueprint.gen_gpu:
		return
	if root_chunk == null:
		root_chunk = add_tree_chunk(Vector2(0, 0), 8192)
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
					add_tree_chunk(Vector2(chunk.position.x, chunk.position.z) - o * new_size / 2, new_size)
				)
		elif should_unsplit(chunk, viewpoint2):
			chunk.prune()
		if chunk.children == null:
			chunk.visible = true
		else:
			chunk.visible = false
			branch_chunks.append_array(chunk.children)

func add_tree_chunk(pos, size):
	var chunk = TreeChunk.instantiate()
	chunk.position.x = pos.x
	chunk.position.z = pos.y
	chunk.size = size
	chunk.blueprint = $Blueprint
	chunk.render()
	add_child(chunk)
	return chunk


func should_split(chunk, viewpoint2):
	return chunk.distance_to_edge(viewpoint2) < chunk.size * 2 and chunk.size > chunk.ntiles / $Blueprint.resolution

func should_unsplit(chunk, viewpoint2):
	return chunk.distance_to_edge(viewpoint2) > chunk.size * 4


