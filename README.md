# Projekt Analityczny dbt dla GOG

## Cel Projektu

Celem tego projektu jest przekształcenie surowych, rozproszonych danych transakcyjnych z platformy GOG w ustrukturyzowany, wiarygodny model danych. Zbudowane modele analityczne mają za zadanie wspierać podejmowanie strategicznych decyzji biznesowych poprzez dostarczanie kluczowych metryk i analiz.

## Struktura Projektu

Projekt wykorzystuje standardową strukturę dbt, aby zapewnić czytelność i łatwość w utrzymaniu:

```
.
|-- models/
|   |-- staging/         # Modele czyszczące i przygotowujące surowe dane
|   |-- marts/           # Końcowe modele analityczne (fakty i wymiary)
|   |-- sources.yml      # Definicje surowych źródeł danych
|
|-- seeds/               # Pliki CSV z surowymi danymi
|-- dbt_project.yml      # Główny plik konfiguracyjny dbt
|-- profiles.yml         # Konfiguracja połączenia z bazą danych
`-- README.md            # Ta dokumentacja
```

### Kluczowe Modele

* **`staging/`**: Modele w tym katalogu odpowiadają za podstawowe oczyszczenie danych (zmiana nazw kolumn, rzutowanie typów, filtrowanie).
* **`marts/`**:
  * **`dim_games`**: Tabela wymiaru zawierająca szczegółowe informacje o grach.
  * **`fact_daily_revenue`**: Tabela faktów agregująca dzienne przychody, uwzględniając wymiary takie jak gatunek gry, typ produktu i metoda płatności.
  * **`recon_transactions`**: Model uzgadniający transakcje z wewnętrznego systemu z danymi od dostawcy usług płatniczych (PSP), kluczowy dla analizy finansowej.

## Jak Uruchomić Projekt Lokalnie

Do uruchomienia projektu wykorzystano **DuckDB** jako lokalną bazę danych.

1. **Wymagania:**
   * Python 3.x
   * `pip` (menedżer pakietów Pythona)

2. **Instalacja:**
   * Utwórz i aktywuj wirtualne środowisko.
   * Zainstaluj zależności:
     ```bash
     pip install dbt-duckdb
     ```

3. **Konfiguracja:**
   * Upewnij się, że plik `profiles.yml` znajduje się w głównym folderze projektu i jest poprawnie skonfigurowany do użycia z DuckDB.

4. **Uruchomienie:**
   * **Zainstaluj pakiety dbt:**
     ```bash
     dbt deps
     ```
   * **Załaduj surowe dane z plików CSV do bazy:**
     ```bash
     dbt seed
     ```
   * **Zbuduj wszystkie modele analityczne:**
     ```bash
     dbt run
     ```
   * **Uruchom testy jakości danych:**
     ```bash
     dbt test
     ```

## Kluczowe Wnioski z Analizy

Analiza danych oparta na zbudowanych modelach pozwoliła zweryfikować kilka hipotez biznesowych:

1. **Najbardziej dochodowe gatunki:** Wbrew pierwotnym przypuszczeniom, najwyższe przychody generują gry **Symulacyjne** i **FPS**, a nie Strategiczne. Sugeruje to potrzebę dywersyfikacji portfolio przywracanych klasyków.
2. **Zachowania zakupowe w tygodniu:** Aktywność zakupowa jest rozłożona równomiernie na cały tydzień, a nie skumulowana w weekendy. Pozwala to na prowadzenie ciągłych, a nie tylko weekendowych, kampanii marketingowych.
3. **Najwyższa wartość transakcji (ATV):** Najwyższą średnią wartość transakcji posiadają użytkownicy korzystający z **GOG Wallet**. Wskazuje to na potencjał w promowaniu tej metody płatności, np. poprzez bonusy za doładowanie portfela.
