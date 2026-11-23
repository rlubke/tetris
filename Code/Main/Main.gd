extends Node2D
class_name Main

# ----- constants --------------------------------------------------------------

# absolute grid boundaries
const GRID_X_MAX := 21
const GRID_Y_MAX := 33

# inner X boundaries
const GAME_X_MIN := 1
const GAME_X_MAX := 20

# inner Y boundaries
const GAME_Y_MIN := 0
const GAME_Y_MAX := 32

# amount of time that must pass before block falls one line
const INITIAL_FALL_RATE := 1.0

# default number of ticks before processing movement when
# user holds down a movement key
const REPEAT_DELAY := 10

# constants for defined user inputs
const DOWN  := "Down"
const LEFT  := "Left"
const RIGHT := "Right"
const DROP  := "Drop"
const CW    := "CW"
const CCW   := "CCW"

# ----- instance variables -----------------------------------------------------

@onready 
var tile_map_layer: TileMapLayer = $TileMapLayer

# initial block fall rate
var fall_rate    := INITIAL_FALL_RATE

# accumulation variable.  Compared against fall_rate.
var last_tick    := 0.0

# how many ticks before a movement action is rendered when the
# user is holding a movement key down.
var repeat_delay := REPEAT_DELAY

# current 
var current_tetromino := Tetrominos.next()


# ---- helper functions --------------------------------------------------------

# returns true when downward movement of the block should occur,
# otherwise returns false.
func _process_gravity(delta: float) -> bool:
	# accumulate the delta.
	last_tick += delta

	# if the accumulation is greater than the current fall-rate,
	# return true, otherwise returns false.
	if last_tick > fall_rate:
		last_tick = 0
		return true

	return false

# resets the delay processing to its original state
func _delay_reset() -> void:
	repeat_delay = REPEAT_DELAY
	
# if the movement delay has been exceeded, return true
# otherwise return false.
func _check_delay() -> bool:
	if repeat_delay < 10:
			repeat_delay += 1
			return false
	else:
		repeat_delay = 0
		return true

# user input handling logic.
func _handle_input() -> void:
	## ----- DOWN --------------------------------------------------------------

	if Input.is_action_pressed(DOWN):
		if _check_delay():
			current_tetromino.move(Vector2i.DOWN, tile_map_layer)

	elif Input.is_action_just_released(DOWN):
		_delay_reset()

	## ----- LEFT --------------------------------------------------------------

	elif Input.is_action_pressed(LEFT):
		if _check_delay():
			current_tetromino.move(Vector2i.LEFT, tile_map_layer)

	elif Input.is_action_just_released(LEFT):
		_delay_reset()

	## ----- RIGHT -------------------------------------------------------------

	elif Input.is_action_pressed(RIGHT):
		if _check_delay():
			current_tetromino.move(Vector2i.RIGHT, tile_map_layer)

	elif Input.is_action_just_released(RIGHT):
		_delay_reset()

	## ---- CW -----------------------------------------------------------------
	
	elif Input.is_action_just_pressed(CW):
		current_tetromino.rotate_cw(tile_map_layer)

	## ---- CCW -----------------------------------------------------------------
	
	elif Input.is_action_just_pressed(CCW):
		current_tetromino.rotate_ccw(tile_map_layer)

	## ----- DROP --------------------------------------------------------------

	elif Input.is_action_just_pressed(DROP):
		current_tetromino.drop(tile_map_layer)


# ----- event handlers ---------------------------------------------------------

func _on_locked():
	current_tetromino = Tetrominos.next();


# ----- system function overrides ----------------------------------------------

func _ready() -> void:
	Signals.locked.connect(_on_locked)

# called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# before anything ...	
	_handle_input()

	if _process_gravity(delta):
		current_tetromino.move(Vector2i.DOWN, tile_map_layer)
