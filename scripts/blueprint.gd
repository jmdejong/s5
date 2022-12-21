extends Node

@export var seed = 1;
@export var aabb = AABB(Vector3(-1024, -128, -1024), Vector3(4096, 512, 4096))
@export var resolution = 4
@export var shore_offset = 512
@export var base_height = -5

var noise = FastNoiseLite.new()
var heightmap = null;

# Called when the node enters the scene tree for the first time.
func _init():
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

func _ready():
	var area = Rect2(aabb.position.x, aabb.position.z, aabb.size.x, aabb.size.z)
	$HeightView.size = area.size * resolution
	$HeightView/HeightMap.size = area.size * resolution
	$HeightView/HeightMap.material.set_shader_parameter("area_min", aabb.position)
	$HeightView/HeightMap.material.set_shader_parameter("area_size", aabb.size)
	$HeightView/HeightMap.material.set_shader_parameter("shore_offset", shore_offset)
	await RenderingServer.frame_post_draw
	heightmap = $HeightView.get_texture()


func height_at(x, y):
	var n = noise.get_noise_2d(x/5, y/5)
	var h = ((n+0.2)**5+ n/3 + 0.15) * 100
	var shore = shore_factor(Vector2(x, y))
	return h * shore + base_height * (1-shore)



func shore_factor(p):
	var r = 1.0
	for d in [p.x - aabb.position.x, p.y - aabb.position.z, aabb.end.x - p.x, aabb.end.z - p.y]:
		var distance = clamp(d / shore_offset, 0.0, 1.0)
		var factor = -(distance-1)**2 + 1#sin(distance*PI/2.0)
		r *= factor
	return r
