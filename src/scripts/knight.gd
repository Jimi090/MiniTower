extends Character

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 300
	damage = 30
	attack_cooldown = 1.1
	speed = 100
	team = Teams.BLUE
	attack_range = $AttackRange
	attack_range.body_entered.connect(on_enemy_in_range_entered)
	attack_range.body_exited.connect(on_enemy_in_range_exited)
