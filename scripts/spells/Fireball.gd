extends Node3D
	
const COOLDOWN_TIME: float = 5
const DAMAGE: int = 1

var caster: CharacterBody3D
var direction: Vector3

var speed: float = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += direction * speed * delta


func cooldown():
	await get_tree().create_timer(COOLDOWN_TIME).timeout
	queue_free()




func _on_body_entered(body):
	if body.has_method("take_damage") and body != caster:
		body.take_damage(DAMAGE)
