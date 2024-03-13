extends CharacterBody3D
const DEBUG = true

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var patrol: Node3D = $"../"
@onready var player: CharacterBody3D = $"../../../PlayerController"
@onready var sword_in_hand: Node3D = $Armature/Skeleton3D/HandAttachment/Sword
@onready var sword_on_belt: Node3D = $Armature/Skeleton3D/PelvisAttachment/Sword
@onready var nav_mesh: NavigationRegion3D = $"../../"

@onready var sound: Dictionary = { # Key = name / [0] = AudioPlayer / [1] = playing
	"steps_grass" 	: [$Sounds/Steps_Grass, 	false],
	"sword_draw" 	: [$Sounds/Sword_Draw, 		false],
	"sword_put_back": [$Sounds/Sword_Put_Back, 	false],
	"sword_slash" 	: [$Sounds/Sword_Slash, 	false],
	"hit" 			: [$Sounds/Hit, 			false],
	"death"			: [$Sounds/Death,			false]
}

##################################_BEHAVIOUR_##################################
enum Behaviour {TRAVEL, GUARD, PATROL, ALERTED, ATTACK, DEAD}

var job: Behaviour # TRAVEL, GUARD or PATROL
var behaviour: Behaviour

var patrol_points: Array[Node]
var target_index: int
var target_count: int
var target_location: Vector3

var alerted: bool = false
var aggro: bool = false
var swinging: bool = false
var one_shot_running: bool = false
var dead: bool = false
##################################_CONSTANTS_##################################
const GRAVITY: float = 20
const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

const ATTACK_RANGE: float = 2.5
const SWORD_DAMAGE: int = 1

const PROVOKE_RANGE: float = 3
const OUT_OF_RANGE: float = 50

const DESPAWN_TIME: float = 10

##################################_ATTRIBUTES_##################################
var lifepoints: int = 10

func _ready():	
	set_physics_process(false)
	if DEBUG: print("Guards: ", patrol.name)
	patrol_points = patrol.get_children().filter(func(c): return c.is_in_group("Patrol"))
	target_count = patrol_points.size()
	job = Behaviour.PATROL if target_count > 1 else Behaviour.GUARD 
	await nav_mesh.get_tree().physics_frame
	await get_tree().create_timer(1).timeout
	set_physics_process(true)
	

func _physics_process(delta):
	if dead: return
	velocity = Vector3(0, velocity.y, 0)
	#print(global_position.distance_to(player.global_position))
	################################_BEAHVIOUR_################################
	if not one_shot_running:	
		if lifepoints <= 0: 													# DEAD
			animation_player.play("Death")
			dead = true
			await get_tree().create_timer(animation_player.get_animation("Death").length + DESPAWN_TIME).timeout
			patrol.queue_free()
		elif aggro:																# ATTACK
			if not is_target_in_range(player.global_position, OUT_OF_RANGE):
				alerted = false
				aggro = false
			elif is_target_in_range(player.global_position, ATTACK_RANGE):
				look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
				rotation_degrees.y -= 180
				attack()
			else:
				walk_to(player.global_transform.origin)
		elif not alerted and is_target_in_range(player.global_position, PROVOKE_RANGE):				# ALERTED
			alert_mode(true)
			warn_player()
		elif alerted:
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
			rotation_degrees.y -= 180
		else:																						# JOB
			behaviour = job	
			match job:
				Behaviour.TRAVEL:												# TRAVEL
					if is_target_in_range(target_location, 1):
						patrol.queue_free()
					else:
						walk_to(target_location)
				Behaviour.GUARD:												# GUARD
					target_location = patrol_points[0].global_position
					if is_target_in_range(target_location, 1):
						rotation.y = lerp_angle(rotation.y, patrol_points[0].rotation.y, 0.2)
						animation_player.play("Idle")
					else:
						walk_to(target_location)
				Behaviour.PATROL:												# PATROL
					target_location = patrol_points[target_index].global_position
					if is_target_in_range(target_location, 1):
						target_index = 0 if target_index >= target_count - 1 else target_index + 1
					else:
						walk_to(target_location)
		
	################################_GRAVITY_################################
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	move_and_slide()


func attack(): # TODO do no damage on Backslash
	one_shot_running = true
	swinging = true
	play_sound("sword_slash", 0.6)
	animation_player.play("Sword_Attack")
	await get_tree().create_timer(animation_player.get_animation("Sword_Attack").length * 2/3).timeout
	swinging = false	
	await get_tree().create_timer(animation_player.get_animation("Sword_Attack").length * 1/3 + 0.1).timeout
	one_shot_running = false

	
func alert_mode(enable: bool): # false to disable
	look_at(player.global_position)
	rotation_degrees.y -= 180
	one_shot_running = true
	alerted = enable
	play_sound("sword_draw" if enable else "sword_put_back", 0.6)
	var animation = "Sword_Draw" if enable else "Sword_Put_Back"
	animation_player.play(animation)
	await get_tree().create_timer(animation_player.get_animation(animation).length/2).timeout
	sword_in_hand.show() if enable else sword_on_belt.show()
	sword_on_belt.hide() if enable else sword_in_hand.hide()
	await get_tree().create_timer(animation_player.get_animation(animation).length/2).timeout
	one_shot_running = false

func warn_player():
	for x in 7:
		print(7 - x)
		await get_tree().create_timer(0.5).timeout
		if not is_target_in_range(player.global_position, PROVOKE_RANGE + 5) and not aggro:
			alert_mode(false)
			return
	aggro = true

func walk_to(target: Vector3):
	nav_agent.set_target_position(target)										# TARGET
	velocity = (nav_agent.get_next_path_position() - global_transform.origin).normalized() * SPEED
	var intended_direction: float = atan2(velocity.x, velocity.z)				# ROTATION
	rotation.y = lerp_angle(rotation.y, intended_direction, 0.2)
	play_sound("steps_grass")
	animation_player.play("Forward")
	


func is_target_in_range(target: Vector3, _range: float):
	return global_position.distance_to(target) <= _range

func take_damage_over_time():
	pass


func take_damage(amount: int):
	if dead: return
	if not aggro:
		await alert_mode(true)
		aggro = true
	#position = position - global_transform.basis.z TODO for ultra fireball damage
	play_sound("hit" if lifepoints > amount else "death") # TODO change Death sound
	animation_player.play("Hit")
	lifepoints -= amount
	pass

func play_sound(sound_name: String, delay: float = 0): # TODO check why footsteps are not delayed like intended
	if sound[sound_name][1]: return
	sound[sound_name][1] = true
	await get_tree().create_timer(delay).timeout
	sound[sound_name][0].play()
	await sound[sound_name][0].finished
	sound[sound_name][1] = false




func _on_sword_body_entered(body):
	if body == self or body.is_in_group("Guard"): return
	#if DEBUG: print(patrol.name, ": hit ", body) # TODO somtimes hits somthing for no reason
	if body.has_method("take_damage") and swinging:
		body.take_damage(SWORD_DAMAGE)

