extends ActorController
class_name PlayerController

#The idea is that this class with handle the control of the actor itself, and that then in turn
#selects the states and actions, which will _then_ read from this to get input
#export var targetactor := NodePath()
#Input constants
export var DEADZONE = 0.2			#What is our thumbstick deadzone?

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	processplaininputs(delta)	#Handle our directional movement
	

func processplaininputs(delta):
	if !targetactor:
		return
		
	if Input.get_connected_joypads().size() > 0:
		#See about handling thumbsticks
		var xAxis = Input.get_joy_axis(0, JOY_ANALOG_LX)
		if (abs(xAxis) > DEADZONE):	#Of course this entertains the problem of being able to creep slowly. That might involve some animation speed stuff?
			move_dir = xAxis
			facing_dir = sign(move_dir)
		else:
			move_dir=0
		
		var yAxis = Input.get_joy_axis(0, JOY_ANALOG_LY)
		if (abs(yAxis) > DEADZONE):
			vertical_move_dir = yAxis
		else:
			vertical_move_dir = 0
	else: #Without an attached controller default to button inputs
		#horizontal movement input controller
		if Input.is_action_pressed("ui_right"):
			move_dir = 1
			facing_dir = 1
		elif Input.is_action_pressed("ui_left"):
			move_dir = -1
			facing_dir = -1
		else:
			move_dir = 0
		
		if Input.is_action_pressed("ui_up"):
			vertical_move_dir = -1
		elif Input.is_action_pressed("ui_down"):
			vertical_move_dir = 1
		else:
			vertical_move_dir = 0
	#So now we need to get this information through to our Actor...
	targetactor.set_move_dir(move_dir, facing_dir, vertical_move_dir)
	
	#See if we want to drop through a platform, and if we're not holding down it's a normal jump. Try not to let this get too convoluted	
	if Input.is_action_just_pressed("ui_accept"):	#try to jump
		if Input.is_action_pressed("ui_down") || vertical_move_dir > 0.75:
			if targetactor.on_ground: #try to fall through ground
				if targetactor.check_drop_function(): #We can try dropping through this platform
					targetactor.change_action_state("Actor_OnGround", false) #Set us to standing on ground
					targetactor.set_drop_collision(true)
		else:
			targetactor.change_action_state("Actor_Jump", true)
	
	if Input.is_action_just_pressed("ui_shift_left"):
		targetactor.change_action_state("Actor_OnDash", false)
	
	#So our player wants to try and make an attack action...
	if Input.is_action_just_pressed("ui_focus_next"):
		targetactor.make_attack_press()
		
	#Handle our blocking action
	if Input.is_action_just_pressed("ui_shift_right"):
		targetactor.change_action_state("Actor_Block", false)
		
	if Input.is_action_just_pressed("ui_select"):
		targetactor.change_action_state("Actor_Shoot", false)
	
	if Input.is_action_just_pressed("ui_menu"): #Restart our level
		get_tree().reload_current_scene()

