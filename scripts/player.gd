extends CharacterBody3D


const MOUSE_SENSITIVITY = 0.003
const speed = 10
const sprint_speed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var input_movement = Input.get_vector("left", "right", "forwards", "backwards")
	var s = speed if not Input.is_action_pressed("sprint") else sprint_speed
	var movement = (Vector3(input_movement.y, 0, -input_movement.x) * s).rotated(Vector3(0, 1, 0), self.rotation.y)
	movement.y = s * (float(Input.is_action_pressed("up")) - float(Input.is_action_pressed("down")))
	velocity = movement
	
	move_and_slide()
	
func _input(event):
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$Head.rotate_z(event.relative.y * MOUSE_SENSITIVITY)
		self.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
