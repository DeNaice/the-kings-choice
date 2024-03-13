class_name QuestList
extends Resource

static var questList: Array[Quest] = []

static func addQuest(qGoal:int, qGiver:int, qAmount:int, qType:int):
	var quest = Quest.new(qGoal, qGiver, qAmount, qType)
	questList.append(quest)
	print(questList)
	pass

static func progressQuests(qGoal):
	var toErase: Array[Quest] = []
	for quest in questList:
		if qGoal == quest.questGoal:
			quest.objectiveAmount -= 1
			if quest.objectiveAmount == 0:
				toErase.append(quest)
	for quest in toErase:
		finishQuest(quest)
	print(questList)

static func finishQuest(quest):
	quest.giveRewards()
	questList.erase(quest)
	pass
