extends Node2D

var textes = {"buttes": preload("res://media/menu/buttes_intro.png")}

func lancer(niveau):
	$CanvasLayer/TextureRect.texture = textes[niveau]
