extends Character

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 60
	damage = 10
	attack_cooldown = 1.1
	speed = 50
	team = Teams.RED
	attack_range = $AttackRange
	super()
