extends Node

@export var seed = 1;


var noise = FastNoiseLite.new()

# Called when the node enters the scene tree for the first time.
func _init():
	noise.seed = seed


func height_at(x, y):
	return noise.get_noise_2d(x, y) * 20
