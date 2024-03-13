extends Node3D

@onready var animation_player = $Offset/AnimationPlayer	
	
const COOLDOWN_TIME: float = 2
const DAMAGE: int = 2

var caster: CharacterBody3D


func _ready():
	cooldown()
	animation_player.play("Spikes")

func _process(_delta):
	pass

func cooldown():
	await get_tree().create_timer(COOLDOWN_TIME).timeout
	queue_free()


func _on_body_exited(body):
	if body.has_method("take_damage") and body != caster:
		body.take_damage(DAMAGE)
