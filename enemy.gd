extends KinematicBody

var speed = 3
const ACCEL_DEFAULT = 5
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 5
var melee_damage = 5
var snap
var h_rot = 0
var dir_rate = 1
var dir_change = 0
var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()
var health = 100
var bubble_res = load("res://bubble_text.tscn")
var bubble_text
var invincibility = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
func _physics_process(delta):
	#get keyboard input
	dir_change += delta
	direction = Vector3.ZERO
	if dir_change>dir_rate:
		h_rot = rand_range(0,360)
		dir_change = 0
	direction = Vector3(0, 0, 1).rotated(Vector3.UP, h_rot).normalized()
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
#	if Input.is_action_just_pressed("jump") and is_on_floor():
#		snap = Vector3.ZERO
#		gravity_vec = Vector3.UP * jump
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)
	
func get_hit(dmg):
	if invincibility:
		return
	if !is_instance_valid(bubble_text):
		bubble_text = bubble_res.instance()
		add_child(bubble_text)
	else:
		bubble_text.reset()
	$anim.play("got_hit")
	health-=dmg
	if health<=0:
#		$anim.play("death")
		queue_free()
		return
	invincibility = true
	yield(get_tree().create_timer(0.5),"timeout")
	invincibility = false
	
