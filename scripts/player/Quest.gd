class_name Quest
extends Object

enum questType {
  EXPLORE,
  SLAY,
  FETCH,
}

var type
var questGoal
var objectiveAmount
var questGiver

func _init(qGoal:int, qGiver:int, qAmount:int, qType:int):
	type = qType
	questGoal = qGoal
	objectiveAmount = qAmount
	questGiver = qGiver

func giveRewards():#TODO make functional
	pass
