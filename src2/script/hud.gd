extends Control

class_name HUD
@export var visao:Label
var camera_magica:CameraMagica
@export var container_magico:ContainerMagico

@export var botao_abrir_camera:Button
@export var posicao_da_camera:Marker2D
@export var inventario:HBoxContainer
var usando:ItemDeInventario
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
		
func pegar_esse_objeto(objeto:GameObject):
	var new_object = ItemDeInventario.new()
	new_object.figura = objeto.figura
	new_object.nome = objeto.nome
	new_object.descricao = objeto.descricao
	new_object.usando.connect(_usar_isso)
	new_object.modulate = Color(1,1,1,0.4)
	inventario.add_child(new_object)
	objeto.queue_free()

func _usar_isso(objeto:ItemDeInventario):
	for i in inventario.get_children():
		i.modulate = Color(1,1,1,0.4)
	if usando == objeto:
		usando = null
	else:
		usando = objeto
		objeto.modulate=Color(1,1,1,1)
	print("usando ",objeto.nome)

func resultado_do_scan(resultado:String):
	print(resultado)
	container_magico.criar(resultado)
	_abrir_camera()

func descartar_item_da_mao() -> bool:
	if usando == null:
		print("Nenhum item selecionado para descartar")
		visao.text = "Voce nao esta segurando itens"
		visao.show()
		return false
	
	var item_para_descartar = usando
	
	print("Descartando item: ", item_para_descartar.nome)
	
	usando = null
	
	if is_instance_valid(item_para_descartar):
		item_para_descartar.queue_free()
	
	visao.text = "Item descartado"
	visao.show()
	
	return true
