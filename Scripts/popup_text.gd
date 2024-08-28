extends Label3D

var tween:Tween

func _ready():
	tween = create_tween()

func _animate_popup_text(popup_instance:Label3D, popup_duration:float):
	tween.tween_property(popup_instance, "global_position:y", popup_instance.global_position.y + 1.0, popup_duration * 0.3)
	tween.tween_property(popup_instance, "modulate:a", 0.0, popup_duration)
	tween.tween_callback(Callable(popup_instance, "queue_free"))
