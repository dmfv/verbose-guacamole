import requests
import json

pronoun_index = ['yo', 'tu', 'el, ella', 'nosotros', 'vosotros', 'ellos']
tenses = ["pretérito-perfecto", "pretérito-imperfecto", "imperativo", "presente", "futuro", "pretérito-pluscuamperfecto"]

def get_verb_forms(verb: str, translation: str) -> dict:
    url = f"http://verbe.cc/verbecc/conjugate/es/{verb}"
    resp = requests.get(url)
    if resp.status_code != 200:
        print(f"Failed to get data for {verb}")
        return []

    data = resp.json()

    moods = data.get("value", {}).get("moods", {})
    all_forms = []

    for mood, tenses in moods.items():
        for tense, forms_list in tenses.items():
            # forms_list is a list of conjugations in pronoun order
            # Since pronouns are not labeled explicitly, we just keep index
            for idx, form in enumerate(forms_list):
                if mood != 'indicativo':
                    continue
                if tense not in tenses:
                    continue
                all_forms.append({
                    "infinitive": verb,
                    # "mood": mood,
                    "tense": tense,
                    "pronoun": pronoun_index[idx],  # 0-based index for pronouns (yo, tú, él, ...)
                    "form": form,
                    'translation': translation
                })

    return all_forms

if __name__ == "__main__":
    verbs = [
        {"infinitive": "ser", "translation": "to be (essential/permanent)"},
        {"infinitive": "estar", "translation": "to be (temporary/location)"},
        {"infinitive": "tener", "translation": "to have"},
        {"infinitive": "hacer", "translation": "to do, to make"},
        {"infinitive": "poder", "translation": "to be able to, can"},
        {"infinitive": "decir", "translation": "to say, to tell"},
        {"infinitive": "ir", "translation": "to go"},
        {"infinitive": "ver", "translation": "to see"},
        {"infinitive": "dar", "translation": "to give"},
        {"infinitive": "saber", "translation": "to know (facts, information)"},
        {"infinitive": "querer", "translation": "to want, to love"},
        {"infinitive": "llegar", "translation": "to arrive"},
        {"infinitive": "pasar", "translation": "to pass, to happen"},
        {"infinitive": "deber", "translation": "should, ought to"},
        {"infinitive": "poner", "translation": "to put, to place"},
        {"infinitive": "parecer", "translation": "to seem, to appear"},
        {"infinitive": "quedar", "translation": "to stay, to remain"},
        {"infinitive": "creer", "translation": "to believe"},
        {"infinitive": "hablar", "translation": "to speak"},
        {"infinitive": "llevar", "translation": "to carry, to bring"},
        {"infinitive": "dejar", "translation": "to leave, to let"},
        {"infinitive": "seguir", "translation": "to follow, to continue"},
        {"infinitive": "encontrar", "translation": "to find"},
        {"infinitive": "llamar", "translation": "to call"},
        {"infinitive": "venir", "translation": "to come"},
        {"infinitive": "pensar", "translation": "to think"},
        {"infinitive": "salir", "translation": "to leave, to go out"},
        {"infinitive": "volver", "translation": "to return"},
        {"infinitive": "tomar", "translation": "to take, to drink"},
        {"infinitive": "conocer", "translation": "to know (people, places)"},
        {"infinitive": "vivir", "translation": "to live"},
        {"infinitive": "sentir", "translation": "to feel"},
        {"infinitive": "tratar", "translation": "to try, to treat"},
        {"infinitive": "mirar", "translation": "to look at, to watch"},
        {"infinitive": "contar", "translation": "to count, to tell"},
        {"infinitive": "empezar", "translation": "to begin, to start"},
        {"infinitive": "esperar", "translation": "to wait, to hope"},
        {"infinitive": "buscar", "translation": "to search for"},
        {"infinitive": "existir", "translation": "to exist"},
        {"infinitive": "entrar", "translation": "to enter"},
        {"infinitive": "trabajar", "translation": "to work"}
    ]

    all_data = []

    for i, verb in enumerate(verbs, 1):
        infinitive, translation = verb['infinitive'], verb['translation']

        print(f"Processing verb {i}/{len(verbs)}: {infinitive}")
        forms = get_verb_forms(infinitive, translation)
        print(f"  Found {len(forms)} forms")
        all_data.extend(forms)

    with open("verbecc_verb_forms.json", "w", encoding="utf-8") as f:
        json.dump(all_data, f, indent=2, ensure_ascii=False)

    print("Done!")
