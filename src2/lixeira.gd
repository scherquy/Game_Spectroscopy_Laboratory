extends StaticBody3D

class_name Lixeira

func interagir(jogador: Node) -> void:
	if jogador == null:
		return
	
	if jogador.has_method("descartar_item_da_mao"):
		var descartou = jogador.descartar_item_da_mao()
		
		if descartou:
			print("Item jogado na lixeira")
		else:
			print("Você não está segurando nenhum item")
