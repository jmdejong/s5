extends Node

@export var seed = 1;
@export var aabb = AABB(Vector3(-1024, -256, -1024), Vector3(4096, 1024, 4096))
@export var resolution = 1
@export var shore_offset = 512
@export var groundshader: Shader
@export var gen_gpu = true
@export var heightmaterial: Material

var base_height = -15
var noise = FastNoiseLite.new()
var heightmap = null
var heightmap_image
var area;

# Called when the node enters the scene tree for the first time.
func _init():
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	area = Rect2(aabb.position.x, aabb.position.z, aabb.size.x, aabb.size.z)

func _ready():
	if not gen_gpu:
		return
	$HeightView.size = area.size * resolution
	$HeightView/HeightMap.size = area.size * resolution
	$HeightView/HeightMap.material.set_shader_parameter("area_min", aabb.position)
	$HeightView/HeightMap.material.set_shader_parameter("area_size", aabb.size)
	$HeightView/HeightMap.material.set_shader_parameter("shore_offset", shore_offset)
	await RenderingServer.frame_post_draw
	heightmap = $HeightView.get_texture()
	heightmap_image = heightmap.get_image()
	# heightmaterial = ShaderMaterial.new()
	# heightmaterial.shader = groundshader
	heightmaterial.set_shader_parameter("noise", heightmap)
	heightmaterial.set_shader_parameter("area_min", aabb.position)
	heightmaterial.set_shader_parameter("area_size", aabb.size)


func height_at(p):
	if gen_gpu:
		if not area.has_point(p):
			return base_height
		var cc = (p - area.position) * resolution
		var ch = heightmap_image.get_pixel(int(cc.x), int(cc.y))
		return (ch.r + ch.g/255) * aabb.size.y + aabb.position.y
	else:
		var n = noise.get_noise_2d(p.x/5, p.y/5)
		var h = ((n+0.2)**5+ n/3 + 0.15) * 100
		var shore = shore_factor(p)
		return h * shore + base_height * (1-shore)
	

func shore_factor(p):
	var r = 1.0
	for d in [p.x - aabb.position.x, p.y - aabb.position.z, aabb.end.x - p.x, aabb.end.z - p.y]:
		var dd = clamp(d / shore_offset, 0.0, 1.0) - 1
		var factor = 1 - dd * dd #sin(distance*PI/2.0)
		r *= factor
	return r

func calc_shore(dist):
	var d = clamp(dist / shore_offset, 0.0, 1.0) - 1.0
	return 1.0 - d * d

func shore_factor2(pos):
	var startdist = pos - area.position;
	var enddist = area.end - pos;
	return calc_shore(startdist.x) * calc_shore(startdist.y) * calc_shore(enddist.x) * calc_shore(enddist.y)


