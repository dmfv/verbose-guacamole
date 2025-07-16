extends Node

@onready var translation_lable = %WordLable
@onready var user_input = %UserInput
@onready var infinitive_lable = %WordInfinitiveForm
@onready var tense = %AskedTense
@export var correct_color := Color(0.0, 1.0, 0.082)
@export var mistake_color := Color(1.0, 0.21, 0.223)
@export var correct_text := "you are correct"
@export var mistake_text := "not correct"

@export var timers_shots := 50
@export var current_shot := 0
@export var animation_duration_sec : float = 1.0

var current_verb := Verb.new() # TODO: rewrite it
var db := MyDatabase.new()

func _ready() -> void:
	db._ready()
	update_texts()

func update_texts() -> void:
	var verb = db.get_new_verb()
	current_verb = verb
	translation_lable.set_text(current_verb.translation)
	infinitive_lable.set_text(current_verb.infinitive)
	tense.set_text("%s, %s" % [current_verb.tense, current_verb.pronoun])
	user_input.text = ""

func get_user_text() -> String:
	return user_input.text	

func on_correct_guess() -> void:
	user_input.text = current_verb.correct_form
	%CorrectAnswerSign.set_modulate(correct_color)
	%CorrectAnswerSign.set_text(correct_text)
	print(correct_text)
	
func on_incorrect_guess() -> void:
	%CorrectAnswerSign.set_modulate(mistake_color)
	%CorrectAnswerSign.set_text(mistake_text)
	print(mistake_text)


func _input(event: InputEvent) -> void:  # TODO: we can connect signals from nested nodes
	if event.is_action_pressed("ui_accept_after_entering_text"):
		if get_user_text() == current_verb.correct_form:
			on_correct_guess()
		else:
			on_incorrect_guess()
		%ModulationTimer.start(float(animation_duration_sec) / timers_shots)


func _on_show_answer_pressed() -> void:
	user_input.text = current_verb.correct_form

func _on_next_word_pressed() -> void:
	update_texts()

func _on_modulation_timer_timeout() -> void:
	if current_shot > timers_shots:
		current_shot = 0
		%ModulationTimer.stop()
		%CorrectAnswerSign.set_self_modulate(Color(1, 1, 1, 0))
		# if correct guess then after animation update texts
		if current_verb.correct_form == get_user_text():
			update_texts()
		return
	var transparency = 0.0
	if current_shot < timers_shots / 2:
		transparency = float(current_shot) / float(timers_shots / 2)
	else:
		transparency = 1.0 - float(current_shot) / float(timers_shots)
	print(transparency)
	%CorrectAnswerSign.set_self_modulate(Color(1, 1, 1, transparency))
	current_shot += 1
