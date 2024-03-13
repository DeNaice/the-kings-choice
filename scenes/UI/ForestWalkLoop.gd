extends AudioStreamPlayer

var menu_audio = preload("res://assets/music/MainMenu-ForestWalk-320bit(chosic.com).mp3")

func _ready():
	# Stelle sicher, dass der AudioStreamPlayer auf Looping eingestellt ist, wenn du möchtest, dass die MP3 automatisch wiederholt wird
	self.stream = menu_audio
	self.play()
