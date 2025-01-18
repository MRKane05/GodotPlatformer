extends Area2D
var point
export(float) var target_camera_zoom = 0.75
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if $RayCast2D.enabled:
		if $RayCast2D.is_colliding():
			point = $RayCast2D.get_collision_point()
			#print ("respawn point: " + point)
			$RayCast2D.enabled = false #turn off our raycast as we've got our information
		else:
			print("respawn point not colliding")
		
func _on_Area2D_body_entered(body):
	if body.has_method("setTargetCameraZoom"):
		print("player enetered camera control point")
		body.setTargetCameraZoom(target_camera_zoom)
