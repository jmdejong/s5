extends Node

@export var seed = 1;
@export var area = Rect2(-0, -0, 4096, 4096)
@export var shore_offset = 128
@export var base_height = -5

var noise = FastNoiseLite.new()

# Called when the node enters the scene tree for the first time.
func _init():
	noise.seed = seed


func height_at(x, y):
	var n = noise.get_noise_2d(x/5, y/5)
	var h = ((n+0.2)**5+ n/3 + 0.15) * 100
	var shore = shore_factor(Vector2(x, y))
	return h * shore + base_height * (1-shore)



func shore_factor(p):
	var r = 1.0
	for d in [p.x - area.position.x, p.y - area.position.y, area.end.x - p.x, area.end.y - p.y]:
		var distance = clamp(d / shore_offset, 0.0, 1.0)
		var factor = -(distance-1)**2 + 1#sin(distance*PI/2.0)
		r *= factor
	return r
