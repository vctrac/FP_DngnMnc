extends KinematicBody

var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
const ACCEL_DASH = 30
const DASH_MAX = 0.05
onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 5
var dash = true
var dash_force = DASH_MAX
var dash_able = false
var last_pressed = ''
var melee_damage = 5
var cam_accel = 40
var mouse_sense = 0.1
var snap
export var attacking = false
var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()	
var atk_type = { 1:"chop", 2:"slash_r2l", 3:"slash_l2r", 4:"thrust"}
onready var head = $Head
onready var camera = $Head/Camera
onready var reach = $Head/Camera/Reach
onready var sword = $Head/Camera/weapon
onready var anim = $anim

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
	
	var mr = event.is_action_pressed("move_right")
	var ml = event.is_action_pressed("move_left")
	var mf = event.is_action_pressed("move_forward")
	var mb = event.is_action_pressed("move_backward")
	
	if mr or ml or mf or mb:
		if dash_able and last_pressed == event.as_text():
			dash = true
			dash_able = false
			var h_rot = global_transform.basis.get_euler().y
			var f_input = event.get_action_strength("move_backward") - event.get_action_strength("move_forward")
			var h_input = event.get_action_strength("move_right") - event.get_action_strength("move_left")
			direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
		else:
			dash_able = true
			last_pressed = event.as_text()
			yield(get_tree().create_timer(0.3),"timeout")
			dash_able = false

func _process(delta):
	set_label("")
	melee()
	if reach.is_colliding():
		var obj = reach.get_collider()
		if obj.is_in_group("Interact"):
			set_label(obj.get_action_name())
			if Input.is_action_just_pressed("interact"):
				obj.action(self)
	
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform
	
func _physics_process(delta):
	if dash:
		dash_force -= delta
		if dash_force <=0:
			dash_force = DASH_MAX
			dash = false
	else:
		#get keyboard input
		direction = Vector3.ZERO
		var h_rot = global_transform.basis.get_euler().y
		var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
		var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	#jumping and gravity
	
	if is_on_floor():
		snap = -get_floor_normal()
		gravity_vec = Vector3.ZERO
		if dash:
			accel = ACCEL_DASH
			speed = 40
		else:
			speed = 7
			accel = ACCEL_DEFAULT
	else:
		if gravity_vec.y<0 and velocity.length()>7:
			velocity -= velocity*10*delta
		accel = ACCEL_AIR
		snap = Vector3.DOWN
		gravity_vec += Vector3.DOWN * gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)

func melee():
	if Input.is_action_just_pressed("atk1"):
		var at = 1
		if Input.is_action_pressed("move_right"):
			at = 3
		elif Input.is_action_pressed("move_left"):
			at = 2
		elif Input.is_action_pressed("move_backward"): #Input.is_action_pressed("move_forward") or 
			at = 4
		if not anim.is_playing():
			anim.play("attack_%s" %atk_type[at])
	if attacking:
			for body in sword.get_overlapping_bodies():
				if body.is_in_group("Enemy"):
					body.get_hit(melee_damage)

func climb_to( target):
	var get_to = target + Vector3(0,1.5,0)
	global_transform.origin = get_to

func set_label(txt):
	if typeof(txt) == TYPE_STRING:
		camera.get_node("Viewport/Label").text = txt
