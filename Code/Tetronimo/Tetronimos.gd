class_name Tetrominos

# ----- public static functions ------------------------------------------------

# returns a random Tetronimo upon each invocation.
static func next() -> Tetromino:
	if _current_tetrominos.is_empty():
		_current_tetrominos.assign(_create_all())
		_current_tetrominos.shuffle()
		
	return _current_tetrominos.pop_back()
	
# ----- private static functions -----------------------------------------------

# returns a new array containting of of each tetromino type
static func _create_all() -> Array[Tetromino]:
	return [_TShape.new(),
			_IShape.new(),
			_OShape.new(), 
			_LShape.new(), 
			_JShape.new(), 
			_SShape.new(), 
			_ZShape.new()]

# the current tetrominos that will be returned by the next() call
static var _current_tetrominos: Array[Tetromino] = []


# ----- class: Block -----------------------------------------------------------

# Tetrominos are constructed of these ...
class Block:
	# no check necessary
	const CHECK_NONE := 0
	
	# check overlap when attempting to move left
	const CHECK_LEFT := 1 << 0;
	
	# check overlap when attempting to move right
	const CHECK_RIGHT := 1 << 1;
	
	# check overlap when attempting to move down
	const CHECK_DOWN := 1 << 2;
	
	# check overlap when attempting to move left, right, or down
	const CHECK_ALL := CHECK_LEFT | CHECK_RIGHT | CHECK_DOWN
	
	# check overlap when attempting to move left or right
	const CHECK_LEFT_RIGHT := CHECK_LEFT | CHECK_RIGHT
	
	# check overlap when attempting to move left or down
	const CHECK_LEFT_DOWN := CHECK_LEFT | CHECK_DOWN
	
	# check overlap when attempting to move right or down
	const CHECK_RIGHT_DOWN := CHECK_RIGHT | CHECK_DOWN

	# block's relative position
	var position: Vector2i
	
	# bits encode which directions should be checked when attempting to
	# move a block
	var _check_bits: int

	# constructor
	func _init(x: int, y: int, check_bits: int):
		position = Vector2i(x, y)
		_check_bits = check_bits
		
	# returns true if the bit at the given index is set, otherwise
	# returns false
	func check(check_bit: int) -> bool:
		return (_check_bits & check_bit) > 0


# ----- class: Tetronimo -------------------------------------------------------

# abstract base class for all tetromino types.
@abstract class Tetromino:
	
	# default orientation index - corresponds to the north orientation
	# of the tetromino implemetation
	const _DEFAULT_ORIENTATION_INDEX := 0;

	# initial position within the game
	var _position := Vector2i(8,0)
	
	# the rotation index tracks the current
	# orientation coordinates of the tetromino
	var _current_orientation_index := _DEFAULT_ORIENTATION_INDEX
	
	# the current orientation
	var _current_orientation: Array[Block] = []
	
	var _locked: bool = false
	
	
	# ----- constructors -------------------------------------------------------

	func _init():
		_current_orientation.assign(_get_orientation())


	# ----- abstract functions -------------------------------------------------

	@abstract func id() -> int

	@abstract func _get_orientations() -> Array[Array]
	
	
	# ----- public functions ---------------------------------------------------
	
	func drop(tile_map: TileMapLayer) -> void:
		while !_locked:
			move(Vector2i.DOWN, tile_map)
		

	func move(direction: Vector2i, tile_map: TileMapLayer) -> Tetromino:
		if direction != Vector2i.UP && _can_move(direction, _current_orientation, tile_map):
			_clear(tile_map)
			_position += direction
			_render(tile_map)

		return self
	
	func rotate_cw(tile_map: TileMapLayer):
		_rotate(func(): return (_current_orientation_index + 1) % 4, tile_map)

	func rotate_ccw(tile_map: TileMapLayer):
		_rotate(func(): return (_current_orientation_index + 3) % 4, tile_map)


	# ----- internal helpers ---------------------------------------------------

	func _get_orientation(orientation_index: int = _current_orientation_index) -> Array[Block]:
		return _get_orientations()[orientation_index]

	func _rotate(new_index_func: Callable, tile_map: TileMapLayer) -> void:
		var new_orientation_index = new_index_func.call()

		if _can_move(Vector2i.ZERO, _get_orientation(new_orientation_index), tile_map):
			# clear before rotate to ensure the correct grid-cells
			# are reset.
			_clear(tile_map)
			_current_orientation_index = new_orientation_index
			_current_orientation.assign(_get_orientation())
			_render(tile_map)

	func _render(tile_map: TileMapLayer) -> Tetromino:
		for block in _current_orientation:
			tile_map.set_cell(_position + block.position, 0, Vector2i(id(), 0))
		return self

	func _clear(tile_map: TileMapLayer) -> void:
		for block in _current_orientation:
			tile_map.erase_cell(_position + block.position)
		
	func _can_move(direction: Vector2i, layout: Array, tile_map: TileMapLayer) -> bool:
		
		var new_position = _position + direction

		for node in layout:
			var block: Block = node as Block
			var new_block_position = new_position + block.position

			## check game min/max X boundary conditions
			#if new_block_position.x < Main.GAME_X_MIN || \
			   #new_block_position.x > Main.GAME_X_MAX:
				#return false
				#
			## check game max Y boundary conditions
			#if new_block_position.y > Main.GAME_Y_MAX:
				#_lock(tile_map)
				#return false
				
			if direction == Vector2i.RIGHT:
				if block.check(Block.CHECK_RIGHT):
					if tile_map.get_cell_source_id(new_block_position) != -1:
						return false
			
			if direction == Vector2i.LEFT:
				if block.check(Block.CHECK_LEFT):
					if tile_map.get_cell_source_id(new_block_position) != -1:
						return false
						
			if direction == Vector2i.DOWN:
				if block.check(Block.CHECK_DOWN):
					if tile_map.get_cell_source_id(new_block_position) != -1:
						_lock(tile_map)
						return false

		return true
		
	func _lock(tile_map: TileMapLayer) -> void:
		_locked = true
		
		# check for completed rows
		_process_rows(_get_used_cells(tile_map), tile_map)

		Signals.locked.emit();
		
	func _process_rows(used_cells: Array[Vector2i], tile_map: TileMapLayer):
		for i in range(Main.GAME_Y_MAX, -1, -1):
			var row := used_cells.filter(func(cell: Vector2i) -> bool:
				if cell.y == i:
					return true
				return false
				)
			if row.is_empty():
				break
			elif row.size() == 20:
				print("ROW ", i, " COMPLETED")
				for ii in row:
					tile_map.erase_cell(ii)
				for iii in _get_used_cells(tile_map):
					var iii_d = iii + Vector2i.DOWN
					tile_map.set_cell(iii_d, 0, tile_map.get_cell_atlas_coords(iii))
					tile_map.erase_cell(iii)
			else:
				print("Row: ", i, " has ", row.size(), " cells")
		
	func _get_used_cells(tile_map: TileMapLayer) -> Array[Vector2i]:
		return tile_map.get_used_cells().filter(func(cell: Vector2i) -> bool:
			if cell.x == 0 || cell.x == Main.GRID_X_MAX || cell.y == Main.GRID_Y_MAX:
				return false
			return true
			)
		

# ----- private class: TShape --------------------------------------------------

class _TShape extends Tetromino:

	static var _id = 0

	var _orientations: Array[Array] = [
		# NORTH
		[
			Block.new(1, 0, Block.CHECK_LEFT_RIGHT),
			Block.new(0, 1, Block.CHECK_LEFT_DOWN),
			Block.new(1, 1, Block.CHECK_DOWN),
			Block.new(2, 1, Block.CHECK_RIGHT_DOWN),
		],
		# EAST
		[
			Block.new(0, 0, Block.CHECK_LEFT_RIGHT),
			Block.new(0, 1, Block.CHECK_LEFT),
			Block.new(1, 1, Block.CHECK_RIGHT_DOWN),
			Block.new(0, 2, Block.CHECK_ALL),
		], 
		# SOUTH
		[
			Block.new(0, 0, Block.CHECK_LEFT_DOWN),
			Block.new(1, 0, Block.CHECK_NONE),
			Block.new(2, 0, Block.CHECK_RIGHT_DOWN),
			Block.new(1, 1, Block.CHECK_ALL),
		],
		# WEST
		[
			Block.new(1, 0, Block.CHECK_LEFT_RIGHT),
			Block.new(0, 1, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 1, Block.CHECK_RIGHT), 
			Block.new(1, 2, Block.CHECK_ALL),
		],
	]

	func id() -> int:
		return _id

	func _get_orientations() -> Array[Array]:
		return _orientations

# ----- private class: IShape --------------------------------------------------

class _IShape extends Tetromino:

	static var _id = 1

	var _orientations: Array[Array] = [
		 # NORTH
		[ 
			Block.new(0, 1, Block.CHECK_LEFT_DOWN),
			Block.new(1, 1, Block.CHECK_DOWN),
			Block.new(2, 1, Block.CHECK_DOWN),
			Block.new(3, 1, Block.CHECK_RIGHT_DOWN),
		],
		 # EAST
		[ 
			Block.new(1, 0, Block.CHECK_LEFT_RIGHT),
			Block.new(1, 1, Block.CHECK_LEFT_RIGHT),
			Block.new(1, 2, Block.CHECK_LEFT_RIGHT),
			Block.new(1, 3, Block.CHECK_ALL),
		],
		 # SOUTH
		[ 
			Block.new(0, 1, Block.CHECK_LEFT_DOWN),
			Block.new(1, 1, Block.CHECK_DOWN),
			Block.new(2, 1, Block.CHECK_DOWN),
			Block.new(3, 1, Block.CHECK_RIGHT_DOWN),
		],
		 # WEST
		[
			Block.new(1, 0, Block.CHECK_LEFT_RIGHT),
			Block.new(1, 1, Block.CHECK_LEFT_RIGHT),
			Block.new(1, 2, Block.CHECK_LEFT_RIGHT),
			Block.new(1, 3, Block.CHECK_ALL),
		],
	]

	func id() -> int:
		return _id

	func _get_orientations() -> Array[Array]:
		return _orientations

# ----- private class: OShape --------------------------------------------------
		
class _OShape extends Tetromino:

	static var _id = 2

	var _orientations: Array[Array] = [
		# NORTH
		[
			Block.new(0, 0, Block.CHECK_LEFT), 
			Block.new(1, 0, Block.CHECK_RIGHT), 
			Block.new(0, 1, Block.CHECK_LEFT_DOWN),
			Block.new(1, 1, Block.CHECK_RIGHT_DOWN),
		], 
		# EAST
		[
			Block.new(0, 0, Block.CHECK_LEFT), 
			Block.new(1, 0, Block.CHECK_RIGHT), 
			Block.new(0, 1, Block.CHECK_LEFT_DOWN),
			Block.new(1, 1, Block.CHECK_RIGHT_DOWN),
		], 
		# SOUTH
		[
			Block.new(0, 0, Block.CHECK_LEFT), 
			Block.new(1, 0, Block.CHECK_RIGHT), 
			Block.new(0, 1, Block.CHECK_LEFT_DOWN),
			Block.new(1, 1, Block.CHECK_RIGHT_DOWN),
		],
		# WEST
		[
			Block.new(0, 0, Block.CHECK_LEFT), 
			Block.new(1, 0, Block.CHECK_RIGHT), 
			Block.new(0, 1, Block.CHECK_LEFT_DOWN),
			Block.new(1, 1, Block.CHECK_RIGHT_DOWN),
		],
	]

	func id() -> int:
		return _id

	func _get_orientations() -> Array[Array]:
		return _orientations

# ----- private class: LShape --------------------------------------------------

class _LShape extends Tetromino:
	
	static var _id = 3
	
	var _orientations: Array[Array] = [
		# NORTH
		[
			Block.new(2, 0, Block.CHECK_LEFT_RIGHT),
			Block.new(0, 1, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 1, Block.CHECK_DOWN), 
			Block.new(2, 1, Block.CHECK_RIGHT_DOWN),
		], 
		# EAST
		[
			Block.new(0, 0, Block.CHECK_LEFT_RIGHT), 
			Block.new(0, 1, Block.CHECK_LEFT_RIGHT), 
			Block.new(0, 2, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 2, Block.CHECK_RIGHT_DOWN),
		],
		# SOUTH
		[
			Block.new(0, 0, Block.CHECK_LEFT), 
			Block.new(1, 0, Block.CHECK_DOWN), 
			Block.new(2, 0, Block.CHECK_RIGHT_DOWN), 
			Block.new(0, 1, Block.CHECK_ALL),
		],
		# WEST
		[
			Block.new(0, 0, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 0, Block.CHECK_RIGHT), 
			Block.new(1, 1, Block.CHECK_LEFT_RIGHT), 
			Block.new(1, 2, Block.CHECK_ALL),
		],
	]
	
	func id() -> int:
		return _id
		
	func _get_orientations() -> Array[Array]:
		return _orientations
		
# ----- private class: JShape --------------------------------------------------

class _JShape extends Tetromino:

	static var _id = 4

	var _orientations: Array[Array] = [
		 # NORTH
		[
			Block.new(0, 0, Block.CHECK_LEFT_RIGHT), 
			Block.new(0, 1, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 1, Block.CHECK_DOWN), 
			Block.new(2, 1, Block.CHECK_RIGHT_DOWN),
		],
		# EAST
		[
			Block.new(0, 0, Block.CHECK_LEFT), 
			Block.new(1, 0, Block.CHECK_RIGHT_DOWN), 
			Block.new(0, 1, Block.CHECK_LEFT_RIGHT), 
			Block.new(0, 2, Block.CHECK_ALL),
		], 
		# SOUTH
		[
			Block.new(0, 0, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 0, Block.CHECK_DOWN), 
			Block.new(2, 0, Block.CHECK_RIGHT), 
			Block.new(2, 1, Block.CHECK_ALL),
		], 
		 # WEST
		[
			Block.new(1, 0, Block.CHECK_LEFT_RIGHT), 
			Block.new(1, 1, Block.CHECK_LEFT_RIGHT), 
			Block.new(0, 2, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 2, Block.CHECK_RIGHT_DOWN),
		],
	]

	func id() -> int:
		return _id

	func _get_orientations() -> Array[Array]:
		return _orientations

# ----- private class: SShape --------------------------------------------------

class _SShape extends Tetromino:

	static var _id = 5

	var _orientations: Array[Array] = [
		# NORTH
		[
			Block.new(1, 0, Block.CHECK_LEFT), 
			Block.new(2, 0, Block.CHECK_RIGHT_DOWN), 
			Block.new(0, 1, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 1, Block.CHECK_RIGHT_DOWN),
		], 
		# EAST
		[
			Block.new(0, 0, Block.CHECK_LEFT_RIGHT), 
			Block.new(0, 1, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 1, Block.CHECK_RIGHT), 
			Block.new(1, 2, Block.CHECK_ALL),
		],
		# SOUTH 
		[
			Block.new(1, 0, Block.CHECK_LEFT), 
			Block.new(2, 0, Block.CHECK_RIGHT_DOWN), 
			Block.new(0, 1, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 1, Block.CHECK_RIGHT_DOWN),
		],
		# WEST
		[
			Block.new(0, 0, Block.CHECK_LEFT_RIGHT), 
			Block.new(0, 1, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 1, Block.CHECK_RIGHT), 
			Block.new(1, 2, Block.CHECK_ALL),
		],
	]

	func id() -> int:
		return _id

	func _get_orientations() -> Array[Array]:
		return _orientations

# ----- private class: ZShape --------------------------------------------------

class _ZShape extends Tetromino:

	static var _id = 6

	var _orientations: Array[Array] = [
		# NORTH
		[
			Block.new(0, 0, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 0, Block.CHECK_RIGHT), 
			Block.new(1, 1, Block.CHECK_LEFT_DOWN), 
			Block.new(2, 1, Block.CHECK_RIGHT_DOWN),
		],
		# EAST
		[
			Block.new(1, 0, Block.CHECK_LEFT_RIGHT), 
			Block.new(0, 1, Block.CHECK_LEFT), 
			Block.new(1, 1, Block.CHECK_RIGHT_DOWN), 
			Block.new(0, 2, Block.CHECK_ALL),
		], 
		# SOUTH
		[
			Block.new(0, 0, Block.CHECK_LEFT_DOWN), 
			Block.new(1, 0, Block.CHECK_RIGHT), 
			Block.new(1, 1, Block.CHECK_LEFT_DOWN), 
			Block.new(2, 1, Block.CHECK_RIGHT_DOWN),
		],
		# WEST
		[
			Block.new(1, 0, Block.CHECK_LEFT_RIGHT), 
			Block.new(0, 1, Block.CHECK_LEFT), 
			Block.new(1, 1, Block.CHECK_RIGHT_DOWN), 
			Block.new(0, 2, Block.CHECK_ALL),
		], 
	]

	func id() -> int:
		return _id

	func _get_orientations() -> Array[Array]:
		return _orientations
