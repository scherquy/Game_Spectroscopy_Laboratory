extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var visao = Vector3(0,0,-1)
var passo_lateral = Vector3(0,0,0)
@export var mouse_sensitivity : float = 0.5
@export var camera:Camera3D

@export var hud:HUD
@export var olho:RayCast3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var ladinho = Input.get_axis("esquerda","direita")
	var acelera = Input.get_axis("tras","frente")
	visao=Vector3(cos(rotation.y),0,-sin(rotation.y))
	if ladinho:
		passo_lateral = -Vector3(-sin(rotation.y),0,-cos(rotation.y))*ladinho
	else:
		passo_lateral = Vector3.ZERO
	if acelera:
		velocity = acelera*(visao)+passo_lateral
	else:
		velocity = 0*visao+passo_lateral
	if olho.is_colliding():
		if olho.get_collider() is GameObject:
			hud.mostre_esse_objeto(olho.get_collider())
			if Input.is_action_just_pressed("acao"):
				hud.executar_acao(olho.get_collider())
		else:
			hud.nao_vejo_nada()
	else:
		hud.nao_vejo_nada()
	move_and_slide()

func _input(event:InputEvent):
	if event is InputEventMouseMotion:# and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		if camera.rotation_degrees.x > -65 && event.relative.y>0 || camera.rotation_degrees.x < 45 && event.relative.y<0:
			camera.rotation_degrees.x -= event.relative.y * mouse_sensitivity
