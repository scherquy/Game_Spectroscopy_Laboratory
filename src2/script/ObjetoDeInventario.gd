extends Resource
class_name Objeto_de_inventario

@export var nome:String
@export var figura:Texture2D
@export var consumivel:bool = false
@export_multiline var mensagem_ao_usar:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
