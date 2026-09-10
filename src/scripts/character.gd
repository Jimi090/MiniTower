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

var BodiesInDetectionRange: Array[Node2D] = []

enum Teams {BLUE, RED}
@export var team : Teams:
	set(new_value):
		team = new_value
		if team == Teams.BLUE:
			enemy = Teams.RED
			default_direction = Vector2.RIGHT
			barrier_x = 600
		elif team == Teams.RED:
			enemy = Teams.BLUE
			default_direction = Vector2.LEFT
			barrier_x = 1000
var enemy : Teams
var default_direction:Vector2
var barrier_x:int

@export var attack_range: Area2D
@export var detection_range: Area2D

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

func on_enemy_in_attack_range_entered(body):
	if body.team == enemy:
		targets.append(body)
		if not is_attacking:
			is_attacking = true
			state = States.ATTACKING
			await get_tree().create_timer(first_attack_cooldown).timeout
			attack(body)

func on_enemy_in_attack_range_exited(body):
	targets.erase(body)
	if len(targets)>0:
		is_attacking = true
		await get_tree().create_timer(first_attack_cooldown).timeout
		if len(targets)>0:
			attack(targets[0])

func get_nearest_enemy():
	var nearest = null
	var nearest_distance = INF

	for body:CharacterBody2D in get_tree().get_nodes_in_group(str(enemy)):
		var distance = global_position.distance_to(body.global_position)

		if distance<nearest_distance:
			nearest_distance=distance
			nearest=body
	return nearest

func get_nearest_enemy_in_array(bodies:Array[Node2D]):
	var nearest = null
	var nearest_distance = INF

	for body:Node2D in bodies:
		if not body.is_in_group(str(enemy)):
			continue
		var distance = global_position.distance_to(body.global_position)

		if distance<nearest_distance:
			nearest_distance=distance
			nearest=body
	return nearest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_range.body_entered.connect(on_enemy_in_attack_range_entered)
	attack_range.body_exited.connect(on_enemy_in_attack_range_exited)
	add_to_group(str(team))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	BodiesInDetectionRange = detection_range.get_overlapping_bodies()
	if is_attacking:
		pass
	elif not is_attacking and len(BodiesInDetectionRange)==0 and position.x<=barrier_x:
		state = States.RUNNING
		position += default_direction*speed*delta
	elif not is_attacking and len(BodiesInDetectionRange)==0 and position.x>barrier_x:
		state = States.IDLE
	elif not is_attacking and len(BodiesInDetectionRange)!=0:
		state = States.RUNNING
		var nearest_enemy = get_nearest_enemy_in_array(BodiesInDetectionRange)
		if nearest_enemy:
			var direction = global_position.direction_to(nearest_enemy.global_position)
			position += direction * speed * delta
	else:
		print('xd')
