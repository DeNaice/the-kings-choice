extends CharacterBody3D

const DEBUG: bool = true
var debug_last_movement_animation: Anim
var debug_last_combat_animation: Anim

################################_NODES_################################
@onready var map = load("res://scenes/ui/Map.tscn")
@onready var fireball = preload("res://scenes/spells/Fireball.tscn")
@onready var icestorm = preload("res://scenes/spells/Icestorm.tscn")
@onready var earthspikes = preload("res://scenes/spells/Earthspikes.tscn")

@onready var camera: Node3D = $"ViewCenter"
@onready var cameraAngle: Camera3D = $"ViewCenter/View"
@onready var player_model: CharacterBody3D = $Hans
@onready var animation_tree: AnimationTree = $Hans/AnimationTree
@onready var sword_in_hand: Node3D = $Hans/Armature/Skeleton3D/HandAttachment/Sword
@onready var sword_on_belt: Node3D = $Hans/Armature/Skeleton3D/PelvisAttachment/Sword
@onready var animation_player: AnimationPlayer = $Hans/AnimationPlayer
@onready var actionable_finder: Area3D = $Hans/Direction/ActionableFinder
 

@onready var sound: Dictionary = { # Key = name / [0] = AudioPlayer / [1] = playing
	"steps_grass" 	: [$MovementSounds/Steps_Grass, 	false],
	"jump" 			: [$MovementSounds/Jump, 			false],
	"land" 			: [$MovementSounds/Land, 			false],
	"land_hard" 	: [$MovementSounds/Land_Hard, 		false],
	"get_up" 		: [$MovementSounds/Get_Up, 			false],
	"roll" 			: [$MovementSounds/Roll, 			false],

	"sword_draw" 	: [$CombatSounds/Sword_Draw, 		false],
	"sword_put_back": [$CombatSounds/Sword_Put_Back, 	false],
	"sword_slash" 	: [$CombatSounds/Sword_Slash, 		false],
	"hit" 			: [$CombatSounds/Hit, 				false],
	
	"talk" 			: [$OtherSounds/Talk, 				false],
	"drink" 		: [$OtherSounds/Drink, 				false],
	"death"			: [$OtherSounds/Death, 				false]
}


################################_OBJECTS_################################

enum Anim {DEFAULT, WALK, SPRINT, JUMP, FALL, LAND, ROLL, IDLE, DRAW_WEAPON, PUT_WEAPON_BACK, MEELE_ATTACK, MAGIC_ATTACK, BLOCK, DAMAGED, DRINK, HIT, DEATH}

enum Spell_Index {FIREBALL, LIGHTNING, ICESTORM_2H, EARTHSPIKES_2H, WATERBURST}
enum Weapon_Index {SWORD}


################################_EXPORT_VARIABLES_################################

@export var x_sensitivity: float = 0.001
@export var y_sensitivity: float = 0.001

@export var initial_jump_velocity: float = 15

@export var initial_speed: float = 7.5
@export var sprint_speed: float = 10
@export var roll_speed_factor: float = 7.5

################################_ATTRIBUTES_################################

const SWORD_DAMAGE = 2
const FALLING_DAMAGE = 4

var lifepoints_max: int = 10 # 5 Hearts
var lifepoints: int = 10

var mana_max: int = 10
var mana: int = 10

var right_hand: Weapon_Index = Weapon_Index.SWORD
var left_hand: Spell_Index = Spell_Index.ICESTORM_2H

var spells: Dictionary = {
	Spell_Index.FIREBALL: 			true,
	Spell_Index.LIGHTNING:			false,
	Spell_Index.ICESTORM_2H: 		true,
	Spell_Index.EARTHSPIKES_2H: 	true,
	Spell_Index.WATERBURST:			false,
}


################################_PHYSICAL_VARIABLES_################################

const HARD_LANDING_TRESHHOLD = -35
const LANDING_SOUND_TRESHHOLD = -20
var gravity: float = 20

var current_movement_speed: float
var current_jump_velocity: float
var last_falling_speed: float

################################_STATES_################################
var map_toggle: bool = true
var map_ui: Control
var sound_playing = false

var dead: bool = false

var movement_enabled: bool = true # diabled while hard landing, rolling and heavy attack
var rolling: bool = false
var falling: bool = false
var jumping: bool = false


var in_combat: bool = false
var drawing: bool = false
var swinging: bool = false
var casting: bool = false

var current_movement_animation: Anim
var current_combat_animation: Anim

################################_SETUP_################################

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	current_movement_speed = initial_speed
	current_jump_velocity = initial_jump_velocity
	

func _physics_process(delta):
	if dead: return
	################################_COMBAT_################################	
	current_combat_animation = Anim.DEFAULT										# DEFAULT
	if in_combat and not rolling:
		player_model.rotation_degrees.y = camera.rotation_degrees.y + 180   						# adjust camera to camera direction
		if not swinging:
			if Input.is_action_just_pressed("draw_weapon"):
				current_combat_animation = Anim.PUT_WEAPON_BACK					# PUT_BACK
			if Input.is_action_just_pressed("attack_left"):
				current_combat_animation = Anim.MAGIC_ATTACK					# MAGIC_ATTACK
			elif Input.is_action_just_pressed("attack_right"):
				current_combat_animation = Anim.MEELE_ATTACK					# MELEE_ATTACK
			elif Input.is_action_just_pressed("heal_potion"):
				current_combat_animation = Anim.DRINK							#DRINK
			elif Input.is_action_just_pressed("next_weapon"):
				change_spell(true)
			elif Input.is_action_just_pressed("previous_weapon"):
				change_spell(false)
	else: 
		if (Input.is_action_just_pressed("draw_weapon") 
		or Input.is_action_just_pressed("attack_right") 
		or Input.is_action_just_pressed("attack_left")):
			current_combat_animation = Anim.DRAW_WEAPON							# DRAW	
	
	
	################################_MOVEMENT_################################	
	current_movement_animation = Anim.DEFAULT									# DEFAULT
	var input_dir: Vector3 = Vector3.ZERO
	if movement_enabled:	
		current_movement_animation = Anim.WALK									# WALK
		input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		input_dir.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		var direction: Vector3 = (camera.transform.basis * input_dir).normalized()
		if direction:	# MOVE
			current_movement_speed = initial_speed
			if not in_combat:			# OUT OF COMBAT
				var intended_direction: float = camera.rotation.y + atan2(input_dir.x, input_dir.z)		# adjust player model to pressed direction
				player_model.rotation.y = lerp_angle(player_model.rotation.y, intended_direction, 0.2)	# in condition to the camera direction
			if Input.is_action_pressed("sprint"):													# also enables to SPRINT
				current_movement_speed = sprint_speed
				current_movement_animation = Anim.SPRINT						# SPRINT
					
			velocity.x = direction.x * current_movement_speed
			velocity.z = direction.z * current_movement_speed
			
			if Input.is_action_pressed("roll"):									# ROLL
				if not jumping and not falling:
					player_model.rotation.y = camera.rotation.y + atan2(input_dir.x, input_dir.z)
					velocity = velocity.normalized() * roll_speed_factor
					rolling = true
		else:			# SLIDE
			velocity.x = move_toward(velocity.x, 0, current_movement_speed)
			velocity.z = move_toward(velocity.z, 0, current_movement_speed)
			current_movement_speed = initial_speed

	################################_GRAVITY_################################
	if falling and is_on_floor():												# LAND
		current_movement_animation = Anim.LAND
	elif Input.is_action_just_pressed("jump") and is_on_floor() and not rolling:# JUMP
		current_movement_animation = Anim.JUMP
		velocity.y = current_jump_velocity
	elif not is_on_floor():														# FALL
		velocity.y -= gravity * delta * 2
		if not rolling:
			current_movement_animation = Anim.FALL
	elif velocity == Vector3(0, 0, 0):											# IDLE
		current_movement_animation = Anim.IDLE
	
	################################_ANIMATE_################################
	if rolling and movement_enabled: current_movement_animation = Anim.ROLL
	
	if jumping: current_movement_animation = Anim.JUMP
	else: animate_movement(input_dir)
	
	if lifepoints <= 0: current_combat_animation = Anim.DEATH
	animate_combat()

	
	##################################_UI_##################################
	if (Input.is_action_just_pressed("open_map") 
	or (!map_toggle and Input.is_action_just_pressed("exit"))):
		if map_toggle:
			map_ui = map.instantiate()
			add_child(map_ui)
			map_toggle = false
		else:
			map_ui.queue_free()
			map_toggle = true
	
	if Input.is_action_just_pressed("interact"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			return
	move_and_slide()


################################_PROCESS_FUNCTIONS_################################

func take_damage(amount: int):
	current_combat_animation = Anim.HIT											# HIT
	animate_combat()															# TODO could cause problems
	lifepoints -= amount
	if DEBUG: print("Lifepoints: ", lifepoints+amount, " -> ", lifepoints)


func change_spell(next: bool): # next is for choosing previous or next weapon
	if next:
		if left_hand == Spell_Index.size() - 1:
			left_hand = (0 as Spell_Index)
		else:
			left_hand = ((left_hand + 1) as Spell_Index)
	else: # previous
		if left_hand == 0:
			left_hand = ((Spell_Index.size() - 1) as Spell_Index)
		else:
			left_hand = ((left_hand - 1) as Spell_Index)
	if DEBUG: 
		print("\nRight: \t", Weapon_Index.keys()[right_hand], " ", right_hand)
		print("Left: \t", Spell_Index.keys()[left_hand], " ", left_hand)
	if not spells[left_hand]: change_spell(next)


################################_SOUNDS_################################

func play_sound(sound_name: String, delay: float = 0):
	if sound[sound_name][1]: return
	sound[sound_name][1] = true
	await get_tree().create_timer(delay).timeout
	sound[sound_name][0].play()
	await sound[sound_name][0].finished
	sound[sound_name][1] = false	
			
################################_ANIMATE_MOVEMENT_################################

func animate_movement(move_input: Vector3):
	if DEBUG and debug_last_movement_animation != current_movement_animation:
		debug_last_movement_animation = current_movement_animation
		print("Animation (Movement): \t", Anim.keys()[current_movement_animation])
	match current_movement_animation:
		Anim.WALK:
			await play_sound("steps_grass", 0.1)
			var adjusted_velocity: Vector2 = Vector2(0, 1)
			if in_combat:
				adjusted_velocity = Vector2(move_input.x, -move_input.z)
			animation_tree.set("parameters/Movement/blend_position", adjusted_velocity)
			animation_tree.set("parameters/SprintBlend/blend_amount", 0)
		Anim.SPRINT:
			await play_sound("steps_grass")
			animation_tree.set("parameters/SprintBlend/blend_amount", 1)
		Anim.JUMP:
			play_sound("jump")
			animation_tree.set("parameters/JumpOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			jumping = true
			await get_tree().create_timer(animation_player.get_animation("MovementLib/Jump").length/2).timeout 
			jumping = false
		Anim.FALL: 
			falling = true;
			var blend_amount: float = animation_tree.get("parameters/FallBlend/blend_amount")
			if blend_amount < 1:
				animation_tree.set("parameters/FallBlend/blend_amount", blend_amount + 0.07)
			last_falling_speed = velocity.y
		Anim.LAND:
			falling = false
			if not rolling:
				if DEBUG: print("Falling Speed: ", -int(last_falling_speed))
				await one_shot_land()
			animation_tree.set("parameters/FallBlend/blend_amount", 0)
		Anim.ROLL:
			play_sound("roll", 0.1)
			animation_tree.set("parameters/RollOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			movement_enabled = false
			await get_tree().create_timer(animation_player.get_animation("MovementLib/Roll").length).timeout 
			rolling = false
			movement_enabled = true
			current_movement_speed = initial_speed
		Anim.IDLE: 
			animation_tree.set("parameters/Movement/blend_position", Vector2(0, 0))
			animation_tree.set("parameters/SprintBlend/blend_amount", 0)

func one_shot_land():
	if last_falling_speed > HARD_LANDING_TRESHHOLD: 							# SOFT LANDING
		if last_falling_speed < LANDING_SOUND_TRESHHOLD: play_sound("land")
		animation_tree.set("parameters/FallBlend/blend_amount", 1)
		for x in 10:
			const land_time: float = 0.001
			await get_tree().create_timer(land_time).timeout
			var blend_amount: float = animation_tree.get("parameters/FallBlend/blend_amount")
			animation_tree.set("parameters/FallBlend/blend_amount", blend_amount - 0.1)
	else:																		# HARD LANDING
		play_sound("land_hard")
		if FALLING_DAMAGE < lifepoints:  play_sound("get_up", 1.2)
		take_damage(FALLING_DAMAGE)
		velocity = Vector3.ZERO # NOTE causes problems if rolling while landing
		animation_tree.set("parameters/HardLandOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		movement_enabled = false
		if get_tree() != null:
			await get_tree().create_timer(animation_player.get_animation("MovementLib/Hard Land").length).timeout
		movement_enabled = true

func enable_combat_mode(enable: bool): # false to disable
	if drawing: return
	drawing = true
	animation_tree.set("parameters/CombatBlend/blend_amount", 1)
	in_combat = enable
	play_sound("sword_draw" if enable else "sword_put_back", 0.6)
	var one_shot = "Draw" if enable else "PutBack"
	animation_tree.set("parameters/"+one_shot+"OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await get_tree().create_timer(animation_tree.get_animation(animation_tree.tree_root.get_node(one_shot).animation).length/2).timeout
	sword_in_hand.show() if enable else sword_on_belt.show()
	sword_on_belt.hide() if enable else sword_in_hand.hide()
	await get_tree().create_timer(animation_tree.get_animation(animation_tree.tree_root.get_node(one_shot).animation).length/2).timeout
	animation_tree.set("parameters/CombatBlend/blend_amount", 0)
	drawing = false

################################_ANIMATE_COMBAT_################################

func animate_combat():
	if DEBUG and debug_last_combat_animation != current_combat_animation:
		debug_last_combat_animation = current_combat_animation
		print("Animation (Combat): \t", Anim.keys()[current_combat_animation])
	match current_combat_animation:
		Anim.DRAW_WEAPON:
			enable_combat_mode(true)
		Anim.PUT_WEAPON_BACK:
			enable_combat_mode(false)
		Anim.MEELE_ATTACK:
			if swinging or drawing: return
			swinging = true
			animation_tree.set("parameters/CombatBlend/blend_amount", 1)
			holding_attack_meele()
		Anim.MAGIC_ATTACK:
			animate_cast()
		Anim.HIT:
			play_sound("hit")
			animation_tree.set("parameters/CombatBlend/blend_amount", 1)
			animation_tree.set("parameters/HitOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			await get_tree().create_timer(animation_tree.get_animation(animation_tree.tree_root.get_node("Hit").animation).length).timeout
			animation_tree.set("parameters/CombatBlend/blend_amount", 0)
		Anim.DEATH:
			play_sound("death", 1.3)
			animation_tree.set("parameters/DeathOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			dead = true
			await get_tree().create_timer(animation_player.get_animation(animation_tree.tree_root.get_node("Death").animation).length).timeout
			get_tree().reload_current_scene()
		Anim.DRINK:
			play_sound("drink")
			one_shot_combat("Drink")

func animate_cast():
	if casting: return
	casting = true
	match left_hand:
		Spell_Index.FIREBALL:
			one_shot_combat("CastSpell1H")
			await get_tree().create_timer(animation_tree.get_animation(animation_tree.tree_root.get_node("CastSpell1H").animation).length/2).timeout
			var fb = fireball.instantiate()
			get_tree().root.add_child(fb)
			fb.caster = self
			fb.rotation = player_model.rotation
			fb.position = player_model.global_position
			fb.direction = -camera.global_transform.basis.z
			await get_tree().create_timer(animation_tree.get_animation(animation_tree.tree_root.get_node("CastSpell1H").animation).length/2).timeout
		Spell_Index.LIGHTNING:
			await one_shot_combat("2HSpellP1")
			animation_tree.set("parameters/CombatBlend/blend_amount", 1)
			animation_tree.set("parameters/2HSpellP2Blend/blend_amount", 1)
			await holding_spell_2h()
			animation_tree.set("parameters/CombatBlend/blend_amount", 0)
			animation_tree.set("parameters/2HSpellP2Blend/blend_amount", 0)
		Spell_Index.ICESTORM_2H:
			var ice = icestorm.instantiate()
			get_tree().root.add_child(ice)
			ice.caster = self
			ice.position = player_model.global_position
			await one_shot_combat("SpellAround")
		Spell_Index.EARTHSPIKES_2H:
			var es = earthspikes.instantiate()
			get_tree().root.add_child(es)
			es.caster = self
			es.rotation = player_model.rotation
			es.position = player_model.global_position
			await one_shot_combat("SpellAround")
		Spell_Index.WATERBURST:
			await one_shot_combat("CastSpell1H")
	casting = false

func one_shot_combat(animation_node: String): # CombatBlend to 1 -> OneShot -> timer -> CombatBlend to 0 -> end swinging
	animation_tree.set("parameters/CombatBlend/blend_amount", 1)
	animation_tree.set("parameters/"+ animation_node +"OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await get_tree().create_timer(animation_tree.get_animation(animation_tree.tree_root.get_node(animation_node).animation).length).timeout
	animation_tree.set("parameters/CombatBlend/blend_amount", 0)


func holding_attack_meele():
	const swing_period: Array[float] = [1.4, 0.8, 1.4, 0.3]
	const swing_hit_offset: Array[float] = [0.9, 0.6, 0.7]
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	play_sound("sword_slash", swing_hit_offset[0])
	await get_tree().create_timer(swing_period[0]).timeout
	if Input.is_action_pressed("attack_right"):
		play_sound("sword_slash", swing_hit_offset[1])
		await get_tree().create_timer(swing_period[1]).timeout
		if Input.is_action_pressed("attack_right"):
			sound["sword_slash"][1] = false
			play_sound("sword_slash", swing_hit_offset[2])
			await get_tree().create_timer(swing_period[2]).timeout
			if Input.is_action_pressed("attack_right"):
				await get_tree().create_timer(swing_period[3]).timeout
				if Input.is_action_pressed("attack_right"):
					holding_attack_meele()
					return
	for x in 10:
		await get_tree().create_timer(0.005).timeout
		var blend_amount: float = animation_tree.get("parameters/CombatBlend/blend_amount")
		animation_tree.set("parameters/CombatBlend/blend_amount", blend_amount - 0.1)
	animation_tree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	animation_tree.set("parameters/CombatBlend/blend_amount", 0)
	swinging = false
	

func holding_spell_2h():
	const burst_period = 0.5
	await get_tree().create_timer(burst_period).timeout
	if Input.is_action_pressed("attack_left"):
		await holding_spell_2h()

################################_MOUSE_EVENT_LISTENER_################################

func _input(event):				
	if event is InputEventMouseMotion: # CAMERA
		var mouse_motion_y = event.relative.y # positive = down / nagative = up
		var mouse_motion_x = event.relative.x # positive = down / nagative = up
		var camera_position_y = cameraAngle.rotation_degrees.x # bottom = -70 / top = 0
		
		camera.rotate(Vector3.DOWN, mouse_motion_x * x_sensitivity)	

		if !(mouse_motion_y < 0 and camera_position_y >= 20) and !(mouse_motion_y > 0 and camera_position_y <= -50):
			cameraAngle.rotate(Vector3.LEFT, mouse_motion_y * y_sensitivity)
			camera.position.y += mouse_motion_y * y_sensitivity * 3
			cameraAngle.position.z = -(camera.position.y * camera.position.y / 5 - 3)
	





func _on_sword_body_entered(body):
	if body == self: return
	if body.has_method("take_damage") and swinging:
		body.take_damage(SWORD_DAMAGE)
