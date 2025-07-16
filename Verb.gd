extends Node
class_name Verb

var infinitive: String = "infinitive_test"
var translation: String = "translation_test"

var tense: String = "tense_test"
var pronoun: String = "pronoun_test"

var correct_form: String = "correct_form_test"

func init(inf_: String, trans_: String, tense_: String, pronoun_: String, correct_form_: String) -> Verb:
	self.infinitive = inf_
	self.translation = trans_
	self.tense = tense_
	self.pronoun = pronoun_
	self.correct_form = correct_form_
	return self

func _to_string() -> String:
	var str = ""
	str += "infinitive %s" % infinitive
	str += "translation %s" % translation
	str += "tense %s" % tense
	str += "pronoun %s" % pronoun
	str += "correct_form %s" % correct_form
	str += "\n"
	return str

static func create_verb(
		inf_: String, 
		trans_: String,
		tense_: String,
		pronoun_: String,
		correct_form_: String) -> Verb:
	return Verb.new().init(inf_, trans_, tense_, pronoun_, correct_form_)
