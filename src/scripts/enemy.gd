extends CharacterBody2D

var health := 60
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("enemies")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health<=0:
		queue_free()
