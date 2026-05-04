extends Control

class_name HUD
@export var visao:Label
var camera_magica:CameraMagica
@export var container_magico:ContainerMagico

@export var botao_abrir_camera:Button
@export var posicao_da_camera:Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	botao_abrir_camera.pressed.connect(_abrir_camera)

func _abrir_camera():
	if camera_magica is CameraMagica:
		camera_magica.queue_free()
		camera_magica = null
	else:
		var new_camera = load("res://camera.tscn").instantiate()
		camera_magica = new_camera
		camera_magica.scan_feito_com_sucesso.connect(resultado_do_scan)
		posicao_da_camera.add_child(new_camera)

func mostre_esse_objeto(objeto:GameObject):
	visao.text = objeto.nome
	visao.show()
	
func nao_vejo_nada():
	visao.hide()
	
func executar_acao(objeto:GameObject):
	if objeto.acao is Action:
		objeto.acao.executar_acao()

func resultado_do_scan(resultado:String):
	print(resultado)
	executar_acao(container_magico)
