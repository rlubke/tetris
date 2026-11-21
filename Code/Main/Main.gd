extends Node2D
class_name Main

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

const Tetrominos = preload("res://Tetronimo/Tetronimo.gd")

const GRID_X_MAX := 22
const GRID_Y_MAX := 34

const GAME_X_MIN := 1
const GAME_X_MAX := 20

const GAME_Y_MIN := 0
const GAME_Y_MAX := 32

var fall_rate: int = 1
var last_tick: float
var down_count = 10
var left_count = 10
var right_count = 10
var rotation_idx = 0
var current

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current = Tetrominos.get_all()[6]

func _handle_input() -> void:
	## ----- DOWN --------------------------------------------------------------

	if Input.is_action_pressed("Down"):
		if down_count < 10:
			down_count += 1;
		else:
			down_count = 0
			current.move(Vector2i.DOWN, tile_map_layer)

	elif Input.is_action_just_released("Down"):
		down_count = 10

	## ----- LEFT --------------------------------------------------------------

	elif Input.is_action_pressed("Left"):
		if left_count < 10:
			left_count += 1;
		else:
			left_count = 0
			current.move(Vector2i.LEFT, tile_map_layer)

	elif Input.is_action_just_released("Left"):
		left_count = 10

	## ----- RIGHT -------------------------------------------------------------

	elif Input.is_action_pressed("Right"):
		if right_count < 10:
			right_count += 1;
		else:
			right_count = 0
			current.move(Vector2i.RIGHT, tile_map_layer)

	elif Input.is_action_just_released("Right"):
		right_count = 10
		
	## ---- CW -----------------------------------------------------------------
	
	elif Input.is_action_just_pressed("CW"):
		current.rotate_cw(tile_map_layer)
		
	## ---- CCW -----------------------------------------------------------------
	
	elif Input.is_action_just_pressed("CCW"):
		current.rotate_cw(tile_map_layer)
		
	## ----- DROP --------------------------------------------------------------

	elif Input.is_action_just_pressed("Drop"):
		current.drop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# before anything ...	
	_handle_input()

	last_tick += delta

	if last_tick > fall_rate:
		last_tick = 0
		current.move(Vector2i.DOWN, tile_map_layer)
