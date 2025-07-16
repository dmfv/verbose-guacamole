from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import time
import json
from bs4 import BeautifulSoup

def parse_verb_conjugations(verb: str):
    url = f"https://www.elconjugador.com/conjugacion/verbo/{verb}.html"

    options = Options()
    options.add_argument("--headless")  # no browser window
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--lang=es")  # Spanish

    driver = webdriver.Chrome(options=options)

    try:
        driver.get(url)
        time.sleep(2)  # wait for page JS to load everything, can be replaced with explicit waits

        blocks = driver.find_elements(By.CSS_SELECTOR, "div.conjugBloc")

        results = []

        for block in blocks:
            # get tense name from div.tempsBloc inside this block
            try:
                tense_name = block.find_element(By.CSS_SELECTOR, "div.tempsBloc").text.strip()
            except:
                # Some empty blocks might have no tense name, skip those
                continue

            # get HTML inside this block
            html = block.get_attribute('innerHTML')

            # parse with BeautifulSoup to easily extract tags and text
            soup = BeautifulSoup(html, "html.parser")

            # Imperative forms usually don't have pronouns, handle separately
            # The text lines can be like:
            # (yo) <b>soy</b><br/>
            # or
            # -<br/><b>sé</b><br/><b>sea</b><br/> (imperative)

            # We'll process the block line by line splitting by <br/>
            lines = html.split('<br/>')

            for line in lines:
                line = line.strip()
                if not line:
                    continue

                line_soup = BeautifulSoup(line, "html.parser")

                # check if line contains <b>
                b_tag = line_soup.find('b')
                if not b_tag:
                    continue

                form = b_tag.text.strip()

                # try to find pronoun before <b>
                # the pronoun is usually inside parentheses before the form, e.g. (yo)
                # but for imperative, there might be no pronoun, so handle that

                text_before_b = b_tag.previous_sibling
                if text_before_b and '(' in str(text_before_b) and ')' in str(text_before_b):
                    pronoun = str(text_before_b).strip().strip('()').strip()
                else:
                    # no pronoun, might be imperative form or special case
                    pronoun = None

                # save data
                results.append({
                    "infinitive": verb,
                    "tense": tense_name,
                    "pronoun": pronoun if pronoun else "-",
                    "form": form
                })

        return results

    finally:
        driver.quit()


if __name__ == "__main__":
    # verbs = ["ser", "estar", "tener", "hacer"]
    verbs = [
        "ser", "estar", "tener", "hacer", "poder", "decir", "ir", "ver", "dar", "saber",
        "querer", "llegar", "pasar", "deber", "poner", "parecer", "quedar", "creer", "hablar", "llevar",
        "dejar", "seguir", "encontrar", "llamar", "venir", "pensar", "salir", "volver", "tomar", "conocer",
        "vivir", "sentir", "tratar", "mirar", "contar", "empezar", "esperar", "buscar", "existir", "entrar",
        "trabajar", "escribir", "perder", "producir", "ocurrir", "entender", "pedir", "recibir", "recordar", "terminar"
    ]


    all_data = []
    for i, verb in enumerate(verbs, 1):
        print(f"Processing verb {i}/{len(verbs)}: {verb}")
        forms = parse_verb_conjugations(verb)
        print(f"  Got {len(forms)} forms")
        all_data.extend(forms)

    # dump to file for later use
    with open("all_verb_forms.json", "w", encoding="utf-8") as f:
        json.dump(all_data, f, indent=2, ensure_ascii=False)

    print("Done parsing all verbs.")
