@tool
extends CharacterBody3D


const MovementMode = preload("movement_mode.gd")


#export(Array, Resource) var movement_modes:Array = [] setget set_movement_modes
@export var walk_mode: Resource = null: set = set_walk_mode
@export var run_mode: Resource = null: set = set_run_mode
@export var fall_mode: Resource = null: set = set_fall_mode
# TODO add fly mode
#export(Resource) var fly_mode = null setget set_fly_mode

@export var config_path: String = ""
# A config section + key ids
# Dictionary key is the exported controller property, value is array
# array[0] = section, array[1] = key, array[2] = mode (0 = substitute, 1 = multiply)
@export var props_config: Dictionary = {}


@export var gravity:float = 9.8
@export var weight:float = 5.0
@export var jump_acceleration:float = 20.0
@export var mouse_sensitivity:float = 0.2
@export var controller_sensitivity:float = 400.0
@export var allowed_slope:float = 75.0 : set = _set_allowed_slope
@export var bobbing_speed_walk:float = 8.0
@export var bobbing_speed_run:float = 12.0
@export var fall_sfx_trigger_distance:float = 1.0

var current_movement_mode:MovementMode = null
var input_direction:Vector3 = Vector3()
var floor_velocity:Vector3 = Vector3()
var last_floor_state:bool = false
var camera_bob_duration:float = 0.0
var h_oscillator:Oscillator = Oscillator.new(0.1, 1.0)
var v_oscillator:Oscillator = Oscillator.new(0.075, 2.0)
var r_z_oscillator:Oscillator = Oscillator.new(0.05, 1.0)
var distance_fallen:float = 0.0


@onready var camera_axis = $CameraAxis
@onready var camera = $CameraAxis/Camera3D




func set_walk_mode(val):
	walk_mode = val
	if !(walk_mode is MovementMode):
		walk_mode = MovementMode.new(MovementMode.MovementType.WALK)


func set_run_mode(val):
	run_mode = val
	if !(run_mode is MovementMode):
		run_mode = MovementMode.new(MovementMode.MovementType.RUN)


func set_fall_mode(val):
	fall_mode = val
	if !(fall_mode is MovementMode):
		fall_mode = MovementMode.new(MovementMode.MovementType.FALL)


func _set_allowed_slope(val):
	allowed_slope = val
	set_floor_max_angle(deg_to_rad(allowed_slope))




func _ready():
	if Engine.is_editor_hint(): return
	# A bit of a hack to prevent input while scene is loading
	# Since engine accumulates all inputs during that time and them fleshes them all at once
	get_tree().get_root().set_disable_input(true)
	get_tree().get_root().call_deferred("set_disable_input", false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)

	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(false)
	set_max_slides(4)
	set_floor_max_angle(deg_to_rad(allowed_slope))


func _unhandled_input(event):
	if Engine.is_editor_hint(): return
	
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mouse_sensitivity_actual = 0.07
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity_actual))
		camera_axis.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity_actual))
		camera_axis.rotation.x = clamp(camera_axis.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if event is InputEventScreenTouch:
		if event.pressed:
			Input.action_press("jump")
		else:
			Input.action_release("jump")


func _process(delta):
	if Engine.is_editor_hint(): return
	rotate_controller_camera(delta)


func _physics_process(delta):
	if Engine.is_editor_hint(): return
	update_input_direction()
	update_movement_mode()
	update_velocity(delta)
	move_controller()
	apply_camera_bob(delta)
	input_direction = Vector3()


func rotate_controller_camera(delta):
	var controller_sensitivity_actual = 220
	if Input.is_action_pressed("camera_left"):
		rotate_y(deg_to_rad(controller_sensitivity_actual * Input.get_action_strength("camera_left") * delta))
	if Input.is_action_pressed("camera_right"):
		rotate_y(deg_to_rad(controller_sensitivity_actual * Input.get_action_strength("camera_right") * delta * -1.0))
	if Input.is_action_pressed("camera_up"):
		camera_axis.rotate_x(deg_to_rad(controller_sensitivity_actual * Input.get_action_strength("camera_up") * delta))
	if Input.is_action_pressed("camera_down"):
		camera_axis.rotate_x(deg_to_rad(controller_sensitivity_actual * Input.get_action_strength("camera_down") * delta * -1.0))
	
	camera_axis.rotation.x = clamp(camera_axis.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func update_input_direction():
	if !is_processing_input(): return
	
	if current_movement_mode && current_movement_mode.movement_type == MovementMode.MovementType.FLY:
		input_direction = Vector3(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_up") - Input.get_action_strength("move_down"),
			Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		).normalized()
	else:
		input_direction = Vector3(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			0.0,
			Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		).normalized()


func update_movement_mode():
	var floor_state = is_on_floor()
	if floor_state:
		floor_velocity = get_platform_velocity()
		if Input.is_action_pressed("run"):
			current_movement_mode = run_mode
		else:
			current_movement_mode = walk_mode
	else:
		current_movement_mode = fall_mode
	
	if floor_state && !last_floor_state:
		velocity -= floor_velocity
		if distance_fallen >= fall_sfx_trigger_distance:
			play_sfx("land")
		distance_fallen = 0.0
	
	last_floor_state = is_on_floor()


func update_velocity(delta):
	if !current_movement_mode: return
	
	match current_movement_mode.movement_type:
		
		MovementMode.MovementType.WALK, MovementMode.MovementType.RUN:
			velocity.y = 0.0
		
		MovementMode.MovementType.FALL:
			velocity += Vector3.DOWN * gravity * weight * delta
	
	if is_processing_input():
		if Input.is_action_just_pressed("jump") && is_on_floor():
			velocity += Vector3.UP * jump_acceleration
			play_sfx("jump")
	
	if input_direction.length_squared() > 0:
		var input_direction_rotated = input_direction.rotated(global_transform.basis.y, deg_to_rad(rotation_degrees.y))
		var input_velocity = input_direction_rotated * current_movement_mode.acceleration * delta
		
		if velocity.length() < current_movement_mode.max_speed || (velocity + input_velocity).length() < velocity.length():
			velocity += input_velocity
	else:
		velocity = velocity.normalized() * clamp(velocity.length() - current_movement_mode.decceleration * delta, 0.0, INF)
	
	if velocity.length() > current_movement_mode.max_speed:
		velocity = velocity.normalized() * clamp(velocity.length() - current_movement_mode.dampening * delta, 0.0, INF)


func move_controller():
	var last_pos = global_transform.origin
	move_and_slide()
	var delta_move = last_pos.y - global_transform.origin.y
	
	if current_movement_mode.movement_type == MovementMode.MovementType.FALL:
		distance_fallen += clamp(delta_move, 0, INF)


func apply_camera_bob(delta):
	if !is_on_floor(): return
	var speed = Vector3(velocity.x, 0.0, velocity.z).length()
	if speed <= 0.0001: return
	
	var speed_based = speed
	if current_movement_mode == run_mode:
		speed_based /= bobbing_speed_run
	else:
		speed_based /= bobbing_speed_walk
	
	camera.transform.origin.x = h_oscillator.get_oscillation(delta, speed_based)
	camera.transform.origin.y = v_oscillator.get_oscillation(delta, speed_based)
	camera.rotation_degrees.y = r_z_oscillator.get_oscillation(delta, speed_based)
	
	if h_oscillator.reached_extremis:
		play_ground_sfx()


func play_ground_sfx():
	var ray_start = $Feet.global_transform.origin
	var ray_end = ray_start - Vector3(0, 1, 0)
	var ray_collision_mask = pow(2, 25 - 1) + pow(2, 31 - 1) + pow(2, 32 - 1)
	var params := PhysicsRayQueryParameters3D.create(ray_start, ray_end, ray_collision_mask, [self])
	var result:Dictionary = get_world_3d().direct_space_state.intersect_ray(params)
	if !result.is_empty():
		var sound_name = ""
		if result.collider.collision_layer & int(pow(2, 31 - 1 )):
			sound_name = "step_rock"
		elif result.collider.collision_layer & int(pow(2, 32 - 1)):
			sound_name = "step_wood"
		elif result.collider.collision_layer & int(pow(2, 25 - 1)):
			sound_name = "step_dirt"
		play_sfx(sound_name)

func play_sfx(sfx_name:String):
	var audio_player = $ActionAudio
	audio_player.stream = load("res://Audio/%s.ogg" % [sfx_name])
	audio_player.pitch_scale = randf_range(0.8, 1.5)
	audio_player.play(0.0)


class Oscillator extends RefCounted:
	var duration:float = 0.0
	var amplitude:float = 0.0
	var frequency:float = 1.0
	var reached_extremis:bool = false
	
	func _init(_amplitude:float = 0.0, _frequency:float = 1.0):
		amplitude = _amplitude
		frequency = _frequency
	
	
	func get_oscillation(delta:float, speed:float):
		var last_duration = duration
		duration += delta * speed
		
		if reached_extremis:
			reached_extremis = false
		if floor(last_duration / (1.0 / frequency * 0.5)) < floor(duration / (1.0 / frequency * 0.5)):
			reached_extremis = true
		
		return sin(duration * 2 * PI * frequency) * amplitude
