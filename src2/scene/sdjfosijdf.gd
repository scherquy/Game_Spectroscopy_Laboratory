extends Node3D

@onready var qr = $QR

func _ready():
	#$Control.on_webcam_texture_created.connect(_scan_this_shit)
	qr.qr_detected.connect(_on_qr_qr_detected)
	qr.qr_scan_failed.connect(_on_qr_qr_scan_failed)
	#$Control/Button.pressed.connect(teste)

func _physics_process(delta: float) -> void:
	var novo = Sprite2D.new()
#	novo.position = Vector2(100,100)
#	novo.centered =false
#	novo.texture = $Control/SubViewportContainer/SubViewport.get_texture()
	qr.scan_qr_image($Control/SubViewportContainer/SubViewport.get_texture().get_image())
#	add_child(novo)

func _scan_this_shit(shit):
	qr.scan_qr_image(shit)

func _on_qr_qr_detected(data: String) -> void:
	print("QR detected: %s" % data)
	var mostrar = Label.new()
	mostrar.text = str(data)
	add_child(mostrar)

func _on_qr_qr_scan_failed(error: ScanError) -> void:
	print("QR scan failed due to '%s'" % error.get_description())
