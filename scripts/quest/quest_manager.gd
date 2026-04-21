extends Node

# Quest Manager - gestisce missioni e sfide
signal quest_started(quest_id: String)
signal quest_progress_updated(quest_id: String, progress: int)
signal quest_completed(quest_id: String)
signal quest_reward_claimed(quest_id: String)

enum QuestType {
	DAILY,
	WEEKLY,
	STORY,
	SPECIAL
}

var active_quests: Dictionary = {}  # quest_id → quest data
var completed_quests: Array = []

func _ready():
	print("Quest Manager initialized")
	_generate_daily_quests()

func _generate_daily_quests():
	print("Generating daily quests")
	var daily_quest = {
		"id": "daily_water_creatures",
		"type": QuestType.DAILY,
		"title": "Cattura Creature Acquatiche",
		"description": "Cattura 3 creature di tipo Acqua",
		"objective": 3,
		"progress": 0,
		"reward_xp": 200,
		"reward_items": ["common_trap"]
	}
	active_quests["daily_water_creatures"] = daily_quest

func update_quest_progress(quest_id: String, progress_increment: int):
	if not active_quests.has(quest_id):
		return
	
	var quest = active_quests[quest_id]
	quest.progress += progress_increment
	
	print("Quest ", quest_id, " progress: ", quest.progress, "/", quest.objective)
	quest_progress_updated.emit(quest_id, quest.progress)
	
	if quest.progress >= quest.objective:
		_complete_quest(quest_id)

func _complete_quest(quest_id: String):
	print("Quest completed: ", quest_id)
	completed_quests.append(quest_id)
	active_quests.erase(quest_id)
	quest_completed.emit(quest_id)

func claim_quest_reward(quest_id: String):
	print("Claiming reward for quest: ", quest_id)
	quest_reward_claimed.emit(quest_id)

func get_active_quests() -> Dictionary:
	return active_quests

func get_completed_quests() -> Array:
	return completed_quests

func send_push_notification(message: String):
	print("Sending push notification: ", message)
