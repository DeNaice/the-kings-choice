extends Node
class_name Spell

var spell_name: String
var owned: bool
var damage: int
var spell_range: int


func _init(_spell_name: String, _owned: bool, _damage: int, _spell_range: int = 0):	
	self.spell_name = _spell_name
	self.owned = _owned
	self.damage = _damage
	self.spell_range = _spell_range
