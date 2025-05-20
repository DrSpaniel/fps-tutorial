extends CharacterBody3D

var speed
const SPRINT_SPEED = 12.0
const WALK_SPEED = 5.0
const CROUCH_SPEED = 2.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.0054
const crouchH = 15

#head bob stuff
const BOB_FREQ = 3.0  # how fast the bob is
const BOB_AMP = 0.2  #how high the bob is
var t_bob = 0.0

@onready var head = $head
@onready var camera = $head/Camera3D
var initial_camera_pos: Vector3
#used to track mouse. maybe add a pause menu!
var mouseinput := true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	initial_camera_pos = camera.transform.origin

func _unhandled_input(event):
	if mouseinput == true:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(80))
	


func _input(event):
	if event.is_action_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouseinput = false
		
		
	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
		mouseinput = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("sprint"):
		if is_on_floor():
			speed = SPRINT_SPEED
	elif Input.is_action_pressed("ctrl"):
		if Input.is_action_just_pressed("ctrl"):
			head.position.y -= crouchH * delta
		if is_on_floor():
			speed = CROUCH_SPEED
	else:
		if is_on_floor():
			speed = WALK_SPEED
	
	if Input.is_action_just_released("ctrl"):
		head.position.y += crouchH * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		
	#headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	move_and_slide()
	

func _headbob(time) -> Vector3:
	var pos = initial_camera_pos
	pos.y += sin(time*BOB_FREQ) * BOB_AMP
	pos.x += cos(time * BOB_FREQ/2) * BOB_AMP
	return pos
