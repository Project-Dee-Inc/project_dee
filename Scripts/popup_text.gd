extends Label3D

var popup_duration:float = 0.5

func animate_popup(popup_instance:Label3D):
	var tween = Tween.new()
	popup_instance.add_child(tween)
	
	# Animate the popup to move up and fade out
	tween.tween_property(popup_instance, "transform.origin:y", popup_instance.transform.origin.y + 1.0, popup_duration)
	tween.tween_property(popup_instance, "modulate:a", 0, popup_duration)
	tween.tween_callback(Callable(popup_instance, "queue_free"))
	
	tween.start()
