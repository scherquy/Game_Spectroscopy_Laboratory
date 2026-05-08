extends TextureButton

class_name ItemDeInventario

var nome:String
var descricao:String
var figura:Texture2D
signal usando

func _ready():
	pressed.connect(_usar)
	texture_normal = figura
	
func _usar():
	emit_signal("usando",self)
