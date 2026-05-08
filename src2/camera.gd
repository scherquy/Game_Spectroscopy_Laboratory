extends Control

class_name CameraMagica

@onready var camera := $NativeCamera
@onready var qr := $QR
@onready var label := $Label
@export var tela:TextureRect

signal scan_feito_com_sucesso

var contagem_frames := 0 # contagem dos frames
var escaneando := false # impede varios scans ao mesmo tempo

func _ready():
	camera.camera_permission_granted.connect(_aceitou_permissao_camera)
	camera.camera_permission_denied.connect(_negou_permissao_camera)
	camera.frame_available.connect(_recebeu_frame)
	
	qr.qr_detected.connect(_detectou_qr)
	qr.qr_scan_failed.connect(_scan_falhou)
	
	_atualizar_label("Aponte para um QR Code", "neutro")
	
	if camera.has_camera_permission():
		_aceitou_permissao_camera() #se a camera ja tem permissao ela eh iniciada
	else:
		camera.request_camera_permission() #se nao tiver permissao ela pede permissao

func _atualizar_label(texto: String, estado: String) -> void:
	label.text = texto
	match estado:
		"valido":
			label.modulate = Color.GREEN
		"invalido":
			label.modulate = Color.RED
		_:
			label.modulate = Color.WHITE

#essa funcao eh usada depois da permissao da camera ser aceita
func _aceitou_permissao_camera() -> void:
	var cameras = camera.get_all_cameras() #reconhce as cameras do celular
	if cameras.is_empty(): #se nao tiver cameras a tela fica cinza
		return
		
	var cam = cameras[0] # 0 = camera traseira
	
	#configuracoes da camera (rotacao, resolucao e cor)
	var configuracao := FeedRequest.new() \
		.set_camera_id(cam.get_camera_id()) \
		.set_width(720) \
		.set_height(1280) \
		.set_rotation(90) \
		.set_frames_to_skip(0) \
		.set_grayscale(false)
		
	camera.start(configuracao)

func _negou_permissao_camera() -> void:
	push_error("Permissão de câmera negada")

#essa funcao eh executada cada vez que um frame eh capturado pela camera
func _recebeu_frame(frame: FrameInfo) -> void:
	tela.material = null
	var imagem := frame.get_image() #converte o frame em imagem do godot
	
	if imagem:
		# exibe o frame no textureReact
		tela.texture = ImageTexture.create_from_image(imagem)
		
		contagem_frames += 1
		
		#a cada 10 frames ele tenta ler um qr code
		if contagem_frames % 10 == 0 and not escaneando:
			escaneando = true
			qr.scan_qr_image(imagem) #envia o frame para o plugin ler um qr code (se o qr estiver na tela)

#executa quando um qr code aparece na tela
func _detectou_qr(dados: String) -> void:
	escaneando = false #libera para outro scan
	
	#tira espacos e deixa tudo minusculo no qr code
	var codigo = dados.strip_edges().to_lower()
	emit_signal("scan_feito_com_sucesso",codigo)
	#verifica se eh um qr code valido ou nao
#	match codigo:
#		"sucesso":
#			_atualizar_label("Você escaneou o SUCESSO", "valido")
#			emit_signal("scan_feito_com_sucesso",codigo)
#		_:
#			_atualizar_label("QR Code Valido, mas é "+codigo, "invalido")

# executa quando nenhum qr code esta na tela
func _scan_falhou(_erro) -> void:
	escaneando = false
	_atualizar_label("Aponte para um QR Code", "neutro")

# quando o app eh fechado a camera desliga
func _exit_tree():
	camera.stop()
