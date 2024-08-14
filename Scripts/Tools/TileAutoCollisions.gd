tool
extends TileMap

export (int) var counter = 0
export (bool) var generate_autotile_collision = false
export (bool) var make_tile_collisions = false setget _on_make_tile_collisions_changed

var tile_size = 16
var sprite_sheet_size = Vector2(12, 9)

func _ready():
	if Engine.editor_hint:
		#if make_tile_collisions:
		_clear_all_tile_collisions()
		_generate_autotile_collision()


func _clear_tile_collisions(tile_id):
	if not tile_set:
		return

	var shape_count = tile_set.tile_get_shape_count(tile_id)
	for i in range(shape_count):
		tile_set.tile_set_shape(tile_id, i, null)

func _clear_all_tile_collisions():
	if not tile_set:
		return

	for tile_id in tile_set.get_tiles_ids():
		_clear_tile_collisions(tile_id)


func _on_make_tile_collisions_changed(new_value):
	if new_value:
		generate_autotile_collision = false
		_generate_autotile_collision()

func _generate_autotile_collision():
	if not tile_set:
		return

	for x in range(sprite_sheet_size.x):
		for y in range(sprite_sheet_size.y):
			var tile_id = tile_set.find_tile_by_name("Tile_" + str(x) + "_" + str(y))
			if tile_id == -1:
				tile_id = tile_set.get_last_unused_tile_id()
				tile_set.create_tile(tile_id)
			
			# Create new collision shape
			var shape = ConvexPolygonShape2D.new()
			shape.points = [
				Vector2(0, 0), 
				Vector2(0, tile_size), 
				Vector2(tile_size, tile_size), 
				Vector2(tile_size, 0)
			]
			
			var transform = Transform2D(0.0, Vector2(0,0)) #Transform2D(0.0, Vector2(x * tile_size, y * tile_size))
			tile_set.tile_add_shape(tile_id, shape, transform, false, Vector2(x, y))
	
	# Reset the flag after generating collisions
	make_tile_collisions = false
