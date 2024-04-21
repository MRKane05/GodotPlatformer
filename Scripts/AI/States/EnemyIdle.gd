extends State
class_name EnemyIdle

var idle_time = 2

func Enter():
	idle_time = rand_range(1,2)
	
func Update(delta: float):
	if idle_time > 0:
		idle_time -= delta
	else:
		#Go to our move state
		pass

#We can handle our physics class stuff here too
