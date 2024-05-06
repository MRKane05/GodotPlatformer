extends KinematicBody2D

const GRAVITY = 600			#assumed 60fps
const FLOOR = Vector2(0, -1) #our floor normal

export(int) var speed = 30	#movement speed. Exported variables can be edited in the scene
export(int) var health = 15 #Enemy hit points

var velocity = Vector2()
var direction = 1 #Sign directio handling stuff - positive is right

var is_dead = false
export(bool) var is_attacking = false

var current_knockback = 0
var stuntime = 0
var parrytime = 0

#AI systems
var panelLimits = Vector2()	#At what point while moving do we detect an edge?
var viewlimit = Vector2(150, 50) #if the player is within this space the AI will do raycasts to see if the AI can spot the player
var hasspottedplayer=false #Has our AI seen the player
var playercurrentlyvisible = false #is our player currently visible?
var currentspeed = speed	#our current movement speed. Used to stop enemies from walking off the edge of things
var last_player_seen = 0

#Grab our global
onready var Global = get_node("/root/Global")

#Combat stuff...of some description
#So basically we want the enemy to do things before simply striking the player, a delay, a step back, step forward etc.
var combatstep :int = 0
var combatstep_timer = 0
#var current_state: State
#var states : Dictionary = {}
#export var initial_state: String = "EnemyIdle"

#Animation stuff
var state_machine

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")
		

func dead():
	is_dead = true
	velocity = Vector2(0,0)
	#$AnimatedSprite.play("die")
	$CollisionShape2D.disabled = true #Disabled our collisions
	$DieTimer.start() #Start our timer to clear our sprite after the death animation is complete

func checklimits():
	if panelLimits.x < self.position.x:
		panelLimits.x = self.position.x
	if panelLimits.y > self.position.x:
		panelLimits.y = self.position.x

#Dirt basic function to see if we can see our player (exclusion based)
func seeplayer():
	if sign(Global.playerpos.x - self.position.x) * direction > 0: #our player is in "front" of this actor
		if playerwithinlimit():	#See if we're within our box of "caring about"
			$PlayerRayCheck.enabled = true #Turn our our raycast
			$PlayerRayCheck.cast_to = Global.playerpos - self.position
			if $PlayerRayCheck.is_colliding():
				return ($PlayerRayCheck.get_collider() == Global.Player)
		else:
			$PlayerRayCheck.enabled = false
	return false
	
#Check and see if the player is within our "attention zone" (this is to save on raycasts)
func playerwithinlimit():
	if abs(self.position.x - Global.playerpos.x) < viewlimit.x && abs(self.position.y - Global.playerpos.y) < viewlimit.y:
		return true
	return false

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_menu"):	#Quick reload on start
		get_tree().reload_current_scene()
	
	stuntime -= delta
	last_player_seen -= delta
	combatstep_timer -= delta
	
	if last_player_seen <= 0:	#Create a timeout so we'll stop trying to persue the player
		hasspottedplayer = false
	

	#Go into our stun state
	if stuntime > 0: # && state_machine.get_current_node() != "stunned":
		state_machine.travel("stunned")
		velocity = move_and_slide(Vector2(current_knockback, 0), FLOOR)
	elif !is_dead && !is_attacking:		#enemy can only move if they're still alive
		velocity.x = currentspeed * direction
		#$AnimatedSprite.play('walk') #is there a problem caling this continuious?
		state_machine.travel("walk")
		velocity.y += GRAVITY*delta #apply gravity
		velocity = move_and_slide(velocity, FLOOR)
		
		#Check and see if we're contacting our player, and if so kill player
		
		#if get_slide_count() > 0: #This counds the collisions that can occur
		#	for i in range(get_slide_count()):	#Iterate through all collisions
		#		if "Player" in get_slide_collision(i).collider.name: #See if one of the collisions is an enemy, and if so kill the player
		#			get_slide_collision(i).collider.dead()
		
		if !hasspottedplayer:
			currentspeed = speed
			#Just do our usal wander
			#handle hitting a wall and turning around
			if is_on_wall():
				direction *=-1	#flip our movement direction
				checklimits()
			#Handle searching for the edge of a ledge (according to Godot manual, this is the best way)
			if !$RayRight.is_colliding():
				direction = -1
				checklimits()
			if !$RayLeft.is_colliding():
				direction = 1
				checklimits()
		else: #Lets walk towards our player
			direction = sign(Global.playerpos.x - self.position.x)
			#We need to check and see if we should stop trying to move
			if !$RayRight.is_colliding() && direction == 1:
				currentspeed = 0
				state_machine.travel("idle")
			elif !$RayLeft.is_colliding() && direction == -1:
				currentspeed = 0
				state_machine.travel("idle")
			else:
				if abs(Global.playerpos.x - self.position.x) > 10:	#stop if we're "on" our player
					currentspeed = speed
				else:
					currentspeed = speed
		
		#This is broken logic
		$Sprite.flip_h = (direction < 0) #lazy shorthand direction sprite check
		$CombatArea2D.scale.x = direction
	
		#$AnimatedSprite.play("stun")
		#velocity = move_and_slide(Vector2(current_knockback,0), FLOOR)
	
	#AI tickers
	if (stuntime < 0):
		if seeplayer():
			last_player_seen = 3	#three seconds until our AI loses interest
			if !hasspottedplayer:
				#Perhaps do something?
				hasspottedplayer = true
				playercurrentlyvisible = true
			else:
				playercurrentlyvisible = false
			
			if abs(self.position.x - Global.playerpos.x) < 25:
				#Lets start by simply handling pauses
				if !is_attacking && combatstep_timer < 0:
					combatstep_timer = rand_range(0.5, 1.5)	#How long we might pause for before doing what's next
					combatstep = rand_range(0, 2)	#So in theory block etc.
					#I'd like the AI to have a backoff state, but we don't have it so, who cares
					#So can we put in a little bit of combat logic here?
					if abs(self.position.x - Global.playerpos.x) < 12 && !is_attacking && combatstep==0:
						state_machine.travel("attack")
						is_attacking = true	#We'll unset this in the animation

func _on_DieTimer_timeout():
	if is_dead:
		queue_free()
		
#Basic hurt function
func take_damage(damageAmount, knockback, instigator):
	print("Enemy Damaged")
	current_knockback = knockback
	health -= damageAmount
	stuntime = 0.25	#Stun our enemy with the hit
	if health < 0:
		dead()

func do_hurt():
	state

func do_stun(knockback : float, stunamount : float, instigator):
	stuntime = stunamount
	#this needs to be an interrupt...
	is_attacking = false

func _on_AnimatedSprite_animation_finished():
	pass # Replace with function body.


func _on_CombatArea2D_body_entered(body):
	#In theory we're trying to strike our player here
	if body.has_method("take_damage"):	#ducktyping to see if we're hitting something that's generically hittable
		body.take_damage(5, 20 * sign(direction), self)
