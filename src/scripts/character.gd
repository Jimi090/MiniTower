class_name Character
extends CharacterBody2D

@export var health := 100:
	set(new_value):
		health = max(0,new_value)
		check_if_dead()
@export var damage := 20
@export var attack_cooldown := 1.1
@export var first_attack_cooldown := 1.1
@export var speed := 100

enum States {IDLE, RUNNING, ATTACKING}
var state := States.RUNNING:
	set(new_value):
		state = new_value
		change_animation()

var can_attack := true
var is_attacking := false
var targets:Array[Node2D] = []

enum Teams {BLUE, RED}
@export var team : Teams:
	set(new_value):
		team = new_value
		if team == Teams.BLUE:
			enemy = Teams.RED
			direction = 1
		elif team == Teams.RED:
			enemy = Teams.BLUE
			direction = -1
var enemy : Teams
var direction : int

@export var attack_range: Area2D

func take_damage(damage_taken: int):
	health -= damage_taken

func check_if_dead():
	if health<=0:
		queue_free()

func attack(body):
	if body == null or body.health <= 0:
		is_attacking = false
		return

	is_attacking = true
	can_attack = false
	body.take_damage(damage)
	state = States.ATTACKING

	if body.health<=0:
		is_attacking = false
		return

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

	if body != null:
		print(body)
		attack(body)
	else:
		is_attacking = false

func change_animation():
	if state == States.IDLE:
		$AnimatedSprite2D.play("idle")
	elif state == States.RUNNING:
		$AnimatedSprite2D.play("running")
	elif state == States.ATTACKING:
		$AnimatedSprite2D.play("attacking")

func on_enemy_in_range_entered(body):
	if body.team == enemy:
		targets.append(body)
		if not is_attacking:
			is_attacking = true
			await get_tree().create_timer(first_attack_cooldown).timeout
			attack(body)

func on_enemy_in_range_exited(body):
	targets.erase(body)
	if len(targets)>0:
		is_attacking = true
		await get_tree().create_timer(first_attack_cooldown).timeout
		attack(targets[0])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_range.body_entered.connect(on_enemy_in_range_entered)
	attack_range.body_exited.connect(on_enemy_in_range_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position.x <= 600 and position.x >= 40 and not is_attacking:
		position.x += direction * speed * delta
		state = States.RUNNING
