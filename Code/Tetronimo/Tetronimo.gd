static func get_all() -> Array[Tetromino]:
	return [TShape.new(), IShape.new(), OShape.new(), LShape.new(), JShape.new(),SShape.new(),ZShape.new()]

# ----- ABC BaseTetronimo ------------------------------------------------------

@abstract class Tetromino:

	var position: Vector2i = Vector2i(8,0)
	var rotation_index = 0
	var current_layout: Array[Vector2i] = []

	func _init():
		current_layout.assign(_get_rotation(0))

	@abstract func id() -> int

	@abstract func _get_rotations() -> Array[Array]

	func _get_rotation(index: int) -> Array[Vector2i]:
		var ret: Array = _get_rotations()[index]
		return ret

	func _rotate(tile_map: TileMapLayer, index: int) -> void:
		_clear(tile_map)
		current_layout.assign(_get_rotation(index))
		render(tile_map)

	func rotate_cw(tile_map: TileMapLayer):
		rotation_index = (rotation_index + 1) % 4
		_rotate(tile_map, rotation_index)

	func rotate_ccw(tile_map: TileMapLayer):
		rotation_index = (rotation_index + 3) % 4
		_rotate(tile_map, rotation_index)

	func render(tile_map: TileMapLayer) -> Tetromino:
		for block in current_layout:
			tile_map.set_cell(position + block, 0, Vector2i(id(), 0))
		return self

	func _clear(tile_map: TileMapLayer) -> void:
		for block in current_layout:
			tile_map.erase_cell(position + block)

	func move(direction: Vector2i, tile_map: TileMapLayer) -> Tetromino:
		_clear(tile_map)
		position += direction
		render(tile_map)
		return self
		
	func drop() -> void:
		pass
		
	func _can_move(_direction: Vector2i) -> void:
		pass
		
	func lock() -> void:
		pass

# ----- TShape -----------------------------------------------------------------

class TShape extends Tetromino:

	static var _id = 0

	var rotations: Array[Array] = [
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # NORTH
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)], # EAST
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)], # SOUTH
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)], # WEST
	]

	func id() -> int:
		return _id

	func _get_rotations() -> Array[Array]:
		return rotations

# ----- IShape -----------------------------------------------------------------

class IShape extends Tetromino:

	static var _id = 1

	var rotations: Array[Array] = [
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], # NORTH
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)], # EAST
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], # SOUTH
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)], # WEST
	]

	func id() -> int:
		return _id

	func _get_rotations() -> Array[Array]:
		return rotations

# ----- OShape -----------------------------------------------------------------
		
class OShape extends Tetromino:

	static var _id = 2

	var rotations: Array[Array] = [
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # NORTH
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # EAST
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # SOUTH
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # WEST
	]

	func id() -> int:
		return _id

	func _get_rotations() -> Array[Array]:
		return rotations

# ----- LShape -----------------------------------------------------------------

class LShape extends Tetromino:
	
	static var _id = 3
	
	var rotations: Array[Array] = [
		[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # NORTH
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)], # EAST
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1)], # SOUTH
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)], # WEST
	]
	
	func id() -> int:
		return _id
		
	func _get_rotations() -> Array[Array]:
		return rotations
		
# ----- JShape -----------------------------------------------------------------

class JShape extends Tetromino:

	static var _id = 4

	var rotations: Array[Array] = [
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # NORTH
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, 2)], # EAST
		[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # SOUTH
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)], # WEST
	]

	func id() -> int:
		return _id

	func _get_rotations() -> Array[Array]:
		return rotations

# ----- SShape -----------------------------------------------------------------

class SShape extends Tetromino:

	static var _id = 5

	var rotations: Array[Array] = [
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)], # NORTH
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)], # EAST
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)], # SOUTH
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)], # WEST
	]

	func id() -> int:
		return _id

	func _get_rotations() -> Array[Array]:
		return rotations

# ----- ZShape -----------------------------------------------------------------

class ZShape extends Tetromino:

	static var _id = 6

	var rotations: Array[Array] = [
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)], # NORTH
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)], # EAST
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)], # SOUTH
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)], # WEST
	]

	func id() -> int:
		return _id

	func _get_rotations() -> Array[Array]:
		return rotations
