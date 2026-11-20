# ----- enum RotationDirection -------------------------------------------------

enum RotatationDirection {
	CW,
	CCW
}

class Tetronimos:
	func get_all():
		return [
			TShape.new(),
			IShape.new(),
			OShape.new(),
			LShape.new(),
			JShape.new(),
			SShape.new(),
			ZShape.new(),
		]

# ----- ABC BaseTetronimo ------------------------------------------------------

@abstract class BaseTetronimo:
	
	var position: Vector2i = Vector2i(8,0)
	var rotation_index = 0
	var current_layout: Array[Vector2i] = _get_rotation(0)
	
	@abstract func id() -> int
	
	@abstract func _get_rotations() -> Array[Array]
	
	func _get_rotation(index: int) -> Array[Vector2i]:
		return _get_rotations()[index]
	
	func rotate(direction: RotatationDirection) -> void:
		pass
	
	func render(tile_map: TileMapLayer) -> BaseTetronimo:
		pass

	func move(direction: Vector2i) -> BaseTetronimo:
		pass
		
	func drop() -> void:
		pass
		
	func _can_move(direction: Vector2i) -> void:
		pass
		
	func lock() -> void:
		pass

# ----- TShape -----------------------------------------------------------------

class TShape extends BaseTetronimo:
	
	static var _id = 0
	
	var rotations: Array[Array] = [
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # NORTH
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)], # EAST
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)], # SOUTH
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)], # WEST
	]
	
	func id() -> int:
		return self._id
		
	func _get_rotations() -> Array[Array]:
		return rotations
		
# ----- IShape -----------------------------------------------------------------
		
class IShape extends BaseTetronimo:
	
	static var _id = 1
	
	var rotations: Array[Array] = [
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], # NORTH
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)], # EAST
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], # SOUTH
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)], # WEST
	]
	
	func id() -> int:
		return self._id
		
	func _get_rotations() -> Array[Array]:
		return rotations

# ----- OShape -----------------------------------------------------------------
		
class OShape extends BaseTetronimo:
	
	static var _id = 2
	
	var rotations: Array[Array] = [
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # NORTH
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # EAST
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # SOUTH
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], # WEST
	]
	
	func id() -> int:
		return self._id
		
	func _get_rotations() -> Array[Array]:
		return rotations
		
# ----- LShape -----------------------------------------------------------------
		
class LShape extends BaseTetronimo:
	
	static var _id = 3
	
	var rotations: Array[Array] = [
		[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # NORTH
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)], # EAST
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1)], # SOUTH
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)], # WEST
	]
	
	func id() -> int:
		return self._id
		
	func _get_rotations() -> Array[Array]:
		return rotations
		
# ----- JShape -----------------------------------------------------------------
		
class JShape extends BaseTetronimo:
	
	static var _id = 4
	
	var rotations: Array[Array] = [
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # NORTH
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, 2)], # EAST
		[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)], # SOUTH
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)], # WEST
	]
	
	func id() -> int:
		return self._id
		
	func _get_rotations() -> Array[Array]:
		return rotations
		
# ----- SShape -----------------------------------------------------------------
		
class SShape extends BaseTetronimo:
	
	static var _id = 5
	
	var rotations: Array[Array] = [
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)], # NORTH
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)], # EAST
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)], # SOUTH
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)], # WEST
	]
	
	func id() -> int:
		return self._id
		
	func _get_rotations() -> Array[Array]:
		return rotations
		
# ----- ZShape -----------------------------------------------------------------
		
class ZShape extends BaseTetronimo:
	
	static var _id = 6
	
	var rotations: Array[Array] = [
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)], # NORTH
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)], # EAST
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)], # SOUTH
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)], # WEST
	]

	func id() -> int:
		return self._id
		
	func _get_rotations() -> Array[Array]:
		return rotations
