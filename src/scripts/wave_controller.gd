extends Node

var wave = 1
var knight_scene = preload("res://scenes/knight.tscn")
var torch_goblin_scene = preload("res://scenes/torch_goblin.tscn")

const blue_spawn_point := Vector2(100,300)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_blue()
	spawn_red()

func spawn_blue():
	for i in 2:
		spawn_knight()
		await get_tree().create_timer(0.3).timeout


func spawn_red():
	for i in 8:
		spawn_torch_goblin()
		await get_tree().create_timer(0.3).timeout

func spawn_knight():
	var instance = knight_scene.instantiate()
	add_child(instance)
	instance.global_position = blue_spawn_point

func spawn_torch_goblin():
	var instance = torch_goblin_scene.instantiate()
	add_child(instance)
	var y = randf_range(160,320)
	instance.global_position = Vector2(640,y)
