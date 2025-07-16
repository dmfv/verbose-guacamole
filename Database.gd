extends Node
class_name MyDatabase

var db: SQLite = create_new_db("user://cards.db")

static func create_new_db(path: String) -> SQLite:
	var local_db = SQLite.new()
	local_db.set_path(path)
	return local_db

var infinitives_table_name: String = "infinitives"
var word_forms_table_name: String = "word_forms"

# tables:
# ####################
# infinitives:
# id - unique id (UINT)
# word infinitive (VARCHAR)
# translation to english (VARCHAR)
var infinitives_table_schema: Dictionary = {
	"id": { "data_type": "int", "primary_key": true, "auto_increment": true	},
	"infinitive": { "data_type": "text", "not_null": true },  # "unique": true
	"translation": { "data_type": "text" },
}

# ####################
# word forms:
# id - (UINT)
# infinitive - foreigh key (infinitives.id) UINT
# tense (ex. Futuro simple) - (VARCHAR) maybe enum in future
# pronoun (ex.  - (VARCHAR) maybe enum in future or foreigh key
# verb - (VARCHAR)
var word_forms_table_schema: Dictionary = {
	"id": { "data_type": "int", "primary_key": true, "auto_increment": true	},
	"infinitive_id": { "data_type": "int", "foreign_key": infinitives_table_name + ".id", "not_null": true },
	"tense": { "data_type": "text" },
	"pronoun": { "data_type": "text" },
	"verb": { "data_type": "text" },
}

#extends Node



func table_exists(db_: SQLite, table_name: String) -> bool:
	var result = db_.query("SELECT * FROM %s LIMIT 1" % table_name)
	if result == false: # and db.get_last_error_message().find("no such table") != -1:
		#print("Table %s not found, should be created." % table_name)
		return false
	return true

func remove_prefix_if_exists(word: String) -> String:
	var prefixes = ["ellos ", "él ", "yo ", "tú ", "nosotros ", "vosotros ", "usted ", "ustedes "]
	for prefix in prefixes:
		if word.begins_with(prefix):
			return word.substr(prefix.length(), word.length() - prefix.length())
	return word  # if no prefix then return initial string

func add_some_words_for_test() -> void:
	var src = "res://word_scrapper_parser/verbecc_verb_forms.json"

	var file = FileAccess.open(src, FileAccess.READ)
	var data = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(data)
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", data, " at line ", json.get_error_line())
		return

	var data_received = json.data
	if typeof(data_received) != TYPE_ARRAY:
		print("Unexpected json data type")
		print(data_received)  # Prints the array.
	for verb_forms in data_received:
		var verb = Verb.create_verb(
			verb_forms["infinitive"],
			verb_forms["translation"],
			verb_forms["tense"],
			verb_forms["pronoun"],
			remove_prefix_if_exists(verb_forms["form"])
		)
		add_new_verb_to_db(verb)
	
	# dummy data:
	#add_new_verb_to_db(Verb.create_verb("ir", "to go", "Presente", "yo", "voy"))
	#add_new_verb_to_db(Verb.create_verb("ir", "to go", "Presente", "tú", "vas"))
	#add_new_verb_to_db(Verb.create_verb("ir", "to go", "Presente", "el, ella", "va"))
	#add_new_verb_to_db(Verb.create_verb("ir", "to go", "Presente", "nosotros", "vamos"))
	#add_new_verb_to_db(Verb.create_verb("ir", "to go", "Presente", "vosotros", "vais"))
	#add_new_verb_to_db(Verb.create_verb("ir", "to go", "Presente", "ellos, ellas", "van")) 

func init_tables() -> void:
	if not FileAccess.file_exists("user://cards.db"):
		print("No database. first run? Anyway will be automatically created")
	db.open_db()
	if not table_exists(db, infinitives_table_name):
		if not db.create_table(infinitives_table_name, infinitives_table_schema):
			print('table %s was not created', infinitives_table_name)
			print(db.get_error_message())
	if not table_exists(db, word_forms_table_name):
		if not db.create_table(word_forms_table_name, word_forms_table_schema):
			print('table %s was not created', word_forms_table_name)
			print(db.get_error_message())
	
	add_some_words_for_test()
	
func _ready() -> void:
	init_tables()
	
func create_dummy_verb() -> Verb:
	var infinitive: String = "infinitive_test"
	var translation: String = "translation_test"
	var tense: String = "tense_test"
	var pronoun: String = "pronoun_test"
	var correct_form: String = "correct_form_test"
	return Verb.create_verb(infinitive, translation, tense, pronoun, correct_form)

func get_new_verb() -> Verb:
	var infinitives_rows = db.select_rows(infinitives_table_name, "", infinitives_table_schema.keys())
	if infinitives_rows.is_empty():
		print('no rows in the table %s some error occured' % infinitives_table_name)
		return create_dummy_verb()
	
	randomize()
	var selected_verb: Dictionary = infinitives_rows[randi_range(0, infinitives_rows.size() - 1)]
	var word_forms_rows = db.select_rows(
		word_forms_table_name, 
		"infinitive_id = %s" % selected_verb['id'],
		word_forms_table_schema.keys())
	if word_forms_rows.is_empty():
		print('no rows in the table %s some error occured' % word_forms_table_name)
		return create_dummy_verb()
	
	var selected_verb_form: Dictionary = word_forms_rows[randi_range(0, word_forms_rows.size() - 1)]
	
	return Verb.create_verb(
		selected_verb["infinitive"],
		selected_verb["translation"],
		selected_verb_form["tense"],
		selected_verb_form["pronoun"],
		selected_verb_form["verb"])

func add_new_verb_to_db(verb: Verb) -> bool:
	var rows = db.select_rows(
		infinitives_table_name, 
		"infinitive = '%s'" % verb.infinitive, 
		infinitives_table_schema.keys())
	var infinitive_id = 0
	if not rows.is_empty():
		infinitive_id = rows[0]['id']
	else:
		var inserted: bool = db.insert_row(
			infinitives_table_name, 
			{
				"infinitive": verb.infinitive, 
				"translation": verb.translation
			}
		)
		if not inserted:
			print('failed to insert rows to table: ', infinitives_table_name)
			print(db.get_error_message())
			print(verb)
			return false

		var arr = db.select_rows(
			infinitives_table_name, 
			"infinitive = '%s'" % verb.infinitive, 
			['id'])
		assert(not arr.is_empty(), "we just inserted new element but can't select it?")
		print(verb)

		infinitive_id = arr[0]['id']
	rows = db.select_rows(
		word_forms_table_name,
		"verb = '%s' AND tense = '%s' AND pronoun = '%s'" % [verb.correct_form, verb.tense, verb.pronoun],
		word_forms_table_schema.keys())
	if rows.is_empty():
		var inserted: bool = db.insert_row(
			word_forms_table_name, 
			{
				"infinitive_id": infinitive_id,
				"tense": verb.tense,
				"pronoun": verb.pronoun,
				"verb": verb.correct_form,
			}
		)
		if not inserted:
			print('failed to insert rows to table: ', word_forms_table_name)
			verb.print()
			return false
	return true
