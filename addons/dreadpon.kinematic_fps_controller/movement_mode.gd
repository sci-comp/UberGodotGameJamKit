extends Resource


enum MovementType {WALK, RUN, FALL, FLY}


@export var movement_type: MovementType = MovementType.WALK
@export var max_speed:float = 5.0
@export var acceleration:float = 5.0
@export var decceleration:float = 5.0
@export var dampening:float = 5.0


func _init(_movement_type:int = MovementType.WALK, _max_speed:float = 5.0, _acceleration:float = 5.0, _decceleration:float = 5.0, _dampening:float = 5.0):
	movement_type = _movement_type
	max_speed = _max_speed
	acceleration = _acceleration
	decceleration = _decceleration
	dampening = _dampening
