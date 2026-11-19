extends Node2D
class_name Main

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

var start_position: Vector2i = Vector2i(8, 0)
var cur_position: Vector2i
var fall_rate: int = 1
var last_tick: float
var current_data = I
var current = current_data[0]
var down_count = 10
var left_count = 10
var right_count = 10
var rotation_idx = 0;

static var T: Array[Array] = [
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # NORTH
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)], # EAST
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)], # SOUTH
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)], # WEST
	]
	
static var I: Array[Array] = [
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], # NORTH
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)], # EAST
	[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], # SOUTH
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)], # WEST
]

static var O: Array[Array] = [
	
]

static var L: Array[Array] = [
	
]

static var J: Array[Array] = [
	
]

static var S: Array[Array] = [
	
]

static var Z: Array[Array] = [
	
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cur_position = start_position

func _clear_current() -> void:
	for block in current:
		tile_map_layer.erase_cell(cur_position + block)
		
func _handle_input() -> void:
	## ----- DOWN --------------------------------------------------------------

	if Input.is_action_pressed("Down"):
		if down_count < 10:
			down_count += 1;
		else:
			down_count = 0
			_clear_current()
			cur_position += Vector2i.DOWN
		
	elif Input.is_action_just_released("Down"):
		down_count = 10
		
	## ----- LEFT --------------------------------------------------------------
		
	elif Input.is_action_pressed("Left"):
		if left_count < 10:
			left_count += 1;
		else:
			left_count = 0
			_clear_current()
			cur_position += Vector2i.LEFT
			
	elif Input.is_action_just_released("Left"):
		left_count = 10
		
	## ----- RIGHT -------------------------------------------------------------

	elif Input.is_action_pressed("Right"):
		if right_count < 10:
			right_count += 1;
		else:
			right_count = 0
			_clear_current()
			cur_position += Vector2i.RIGHT
			
	elif Input.is_action_just_released("Right"):
		right_count = 10
		
	## ---- CW -----------------------------------------------------------------
	
	elif Input.is_action_just_pressed("CW"):
		rotation_idx = (rotation_idx + 1) % 4
		_clear_current()
		current = current_data[rotation_idx]
		
	## ---- CCW -----------------------------------------------------------------
	
	elif Input.is_action_just_pressed("CCW"):
		rotation_idx = (rotation_idx + 3) % 4
		_clear_current()
		current = current_data[rotation_idx]
		
	## ----- DROP --------------------------------------------------------------

	elif Input.is_action_just_pressed("Drop"):
		print("Drop")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# before anything ...	
	_handle_input()

	last_tick += delta

	if last_tick > fall_rate:
		last_tick = 0
		_clear_current()
		cur_position += Vector2i.DOWN

	for block in current:
		tile_map_layer.set_cell(cur_position + block, 0, Vector2i(0,0))
