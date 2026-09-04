extends StaticBody2D

enum Teams {BLUE, RED}
var team = Teams.BLUE
var health := 1000:
	set(new_value):
		health = max(0,new_value)
		check_if_dead()

func take_damage(damage_taken: int):
	health -= damage_taken

func check_if_dead():
	if health<=0:
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
