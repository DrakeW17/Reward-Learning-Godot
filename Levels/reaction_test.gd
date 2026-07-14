extends Node2D

@onready var betweenTimer = $BetweenTimer
@onready var flash = $Flash

var times = []
var currentTime = 0

const dataAmount = 10

func _ready() -> void:
	betweenTimer.start()
	
func _process(delta: float) -> void:
	if flash.visible:
		currentTime += delta
		if Input.is_action_just_pressed("jump"):
			times.push_back(currentTime)
			if times.size() < dataAmount:
				currentTime = 0
				flash.visible = false
				betweenTimer.wait_time = randf_range(0.5, 3)
				betweenTimer.start()
			else:
				var average = times.reduce(func(accum, number): return accum + number, 0) / times.size()
				var time = (average - times.min()) * 0.33 + times.min()
				print(times)
				print(average)
				print(time)


func _on_between_timer_timeout() -> void:
	flash.visible = true
	
