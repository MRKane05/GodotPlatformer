extends Collectable_Base
class_name collectable_ability

export(String) var ability = "wallgrab"
export(float) var state = 1.0	#This will be cased accordingly by the function

var time = 0
var oscel_range = 5
var oscel_speed = 0.5
var pickedup = false
var label_display_time = 1.5

var start_pos = Vector2.ZERO

func _ready():
	start_pos = self.position

func do_collect():
	#We want to send information through to our player about what we've collected
	#and we need to play some sort of effect
	#plus we should destroy this object
	Global.Player.set_ability(ability, state)
	pickedup = true
	$Sprite.visible = false; #hide our sprite

func _process(delta):
	if pickedup:
		label_display_time -= delta
		$UnlockLabel.visible = label_display_time > 0
		if label_display_time < 0:
			queue_free()


func _physics_process(delta):
	if !pickedup:
		time += delta
		if time > oscel_speed * 4 * 3.1415: #Good programming to have overflow checks
			time = 0
		self.position = Vector2(start_pos.x, start_pos.y + sin(time/oscel_speed) * oscel_range)
