extends Area3D

const FILE_BEGIN = "res://Scenes/Levels/level_test"

func _on_body_entered(body):
	if body.is_in_group("player"):
		
		LevelManager.get_level()
		LevelManager.level_progress()
		print(LevelManager._level_progress_count)
		
		if LevelManager._level_progress_count == 5:
			var next_level_path = FILE_BEGIN + "boss.tscn"
			get_tree().change_scene_to_file(next_level_path)
			print(next_level_path)
			LevelManager._level_progress_count = 0
			
		else:
			var random_level = LevelManager._levels.pop_front()
			var next_level_number = random_level
			
			var next_level_path = FILE_BEGIN + str(next_level_number) + ".tscn"
			get_tree().change_scene_to_file(next_level_path)
			print(next_level_path)
			
