extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var MOUSE_SENSITIVTY: float = 0.5
@export var TILT_LOWER_LIMIT:= deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT:= deg_to_rad(90.0)
@export var CAMERA_CONTROLLER: Camera3D

var _mouse_rotation: Vector3
var _mouse_input: bool = false # move or not
var _rotation_input: float # pan left right
var _tilt_input: float # pan up down

var _camera_rotation: Vector3
var _player_rotation: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVTY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVTY
		# print(Vector2(_rotation_input, _tilt_input))

func _update_camera(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0) # left right
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0) # up down
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Rotation Camera & Player with mouse.
	_update_camera(delta)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
