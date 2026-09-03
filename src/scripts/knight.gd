extends CharacterBody2D

var health := 100
var damage := 20
var attack_cooldown := 1.1
var speed  := 100

var state := States.RUNNING
enum States {IDLE, RUNNING, ATTACKING}
var can_attack := true
var is_attacking := false
var targets:Array[Node2D] = []

@onready var attack_range: Area2D = $AttackRange


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_range.body_entered.connect(on_enemy_in_range_entered)
	attack_range.body_exited.connect(on_enemy_in_range_exited)

func on_enemy_in_range_entered(body):
	if body.is_in_group("enemies"):
		targets.append(body)
		if not is_attacking:
			attack(body)
	

func on_enemy_in_range_exited(body):
	targets.erase(body)
	if len(targets)>0:
		attack(targets[0])

func attack(body):
	if body == null:
		return
	
	is_attacking = true
	can_attack = false
	body.health -= damage
	state = States.ATTACKING
	print(body.health)
	
	if body.health<=0:
		is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
	if body != null:
		attack(body)
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position.x <= 560 and not is_attacking:
		position.x += speed * delta
		state = States.RUNNING
	
	if state == States.IDLE:
		$AnimatedSprite2D.play("idle")
	elif state == States.RUNNING:
		$AnimatedSprite2D.play("running")
	elif state == States.ATTACKING:
		$AnimatedSprite2D.play("attacking")
	

	
