extends Node3D

@onready var fog = $Offset/FogVolume

const COOLDOWN_TIME: float = 3
const DAMAGE: int = 1

var bodies: Array[CharacterBody3D]

var caster: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	cooldown()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = caster.global_position


func cooldown():
	for i in 19:
		print(i)
		await get_tree().create_timer(COOLDOWN_TIME/20).timeout
		fog.scale *= 1.05
		if i % 7 == 0:
			for b in bodies:
				b.take_damage(DAMAGE)
	queue_free()


func _on_body_entered(body):
	if body.has_method("take_damage") and body != caster:
		bodies.append(body)


func _on_offset_body_exited(body):
	if body.has_method("take_damage") and body != caster:
		bodies.erase(body)
