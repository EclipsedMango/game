extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY: float = 0.001
const LOOK_LIMIT: float = PI / 2
const ACCELERATION: float = 1

@onready var head: Camera3D = $Node3D/Head
@onready var debug_info: Label = $DebugInfo

var speed = SPEED

var jump_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	var vel: Vector2 = Vector2(velocity.x, velocity.z)
	
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= jump_gravity * (delta * 1.5)

	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("left_shift"):
		speed = SPEED
		speed *= 2
	else:
		speed = SPEED

	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	debug_info.text = str("Speed: ", vel.length(), "\nVelocity: ", velocity, "\nPos: ", global_position)

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		head.rotation.x = clampf(head.rotation.x - (event.relative.y * MOUSE_SENSITIVITY), -LOOK_LIMIT, LOOK_LIMIT)
		velocity = velocity.rotated(Vector3.UP, -event.relative.x * MOUSE_SENSITIVITY)


func teleportPad() -> void:
	position.y *= 3.0
