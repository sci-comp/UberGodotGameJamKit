extends CharacterBody3D

@export var SPEED: float = 5.0
@export var JUMP_VELOCITY: float = 4.5
@export var enable_gravity = true

@onready var _camera: Camera3D = %MainCamera3D
@onready var _player_pcam: PhantomCamera3D = %PlayerPhantomCamera3D

var gravity: float = 9.8

func _ready():
	pass

func _physics_process(delta: float) -> void:
	# Add gravity
	if enable_gravity and not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var cam_dir: Vector3 = -_camera.global_transform.basis.z

	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var move_dir: Vector3 = Vector3.ZERO
		move_dir.x = direction.x
		move_dir.z = direction.z

		move_dir = move_dir.rotated(Vector3.UP, _camera.rotation.y).normalized()
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
