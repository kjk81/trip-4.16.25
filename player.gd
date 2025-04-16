extends CharacterBody3D

@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D

@export var sensitivity := 0.01
@export var SPEED := 5.0
@export var JUMP_VELOCITY := 2.5

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		neck.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y*sensitivity)
		camera.set_rotation(Vector3(clamp(camera.get_rotation().x, -PI/2.2, PI/2.2), 0, 0))
		
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	if velocity:
		print(velocity)
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back") # gets global input directions
	var direction := (neck.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() # input direction with respect to current rotation
	if direction:
		# moving with acceleration effect
		velocity.x = move_toward(velocity.x, direction.x * SPEED, SPEED/7)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, SPEED/7)
	else:
		# friction / slowing down
		velocity.x = move_toward(velocity.x, 0, SPEED/7)
		velocity.z = move_toward(velocity.z, 0, SPEED/7)

	move_and_slide()
