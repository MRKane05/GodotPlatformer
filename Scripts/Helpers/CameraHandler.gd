extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	#I'd really like a more difinitive way of doing this as I don't like this for a form...
	var tilemap_rect = get_parent().get_parent().get_node("WalkableTilemap").get_used_rect()
	var tilemap_cell_size = get_parent().get_parent().get_node("WalkableTilemap").cell_size
	limit_left = tilemap_rect.position.x * tilemap_cell_size.x
	limit_right = tilemap_rect.end.x * tilemap_cell_size.x
	limit_top = tilemap_rect.position.y * tilemap_cell_size.y
	limit_bottom = tilemap_rect.end.y * tilemap_cell_size.y

