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

### Zapytania i Wyniki Analizy

Poniżej znajdują się zapytania SQL użyte do weryfikacji powyższych hipotez wraz z uzyskanymi wynikami.

**1. Przychody według gatunku gier:**
```sql
SELECT
    genre,
    SUM(total_revenue_usd) AS total_revenue_by_genre
FROM
    gog_data_marts.fact_daily_revenue
GROUP BY
    genre
ORDER BY
    total_revenue_by_genre DESC
LIMIT 10;
```
**Wyniki:**
| Gatunek | Całkowity Przychód (USD) |
| :--- | :--- |
| Simulation | 113,400.78 |
| FPS | 107,044.49 |
| Adventure | 106,355.53 |
| Sports | 104,047.71 |
| Strategy | 97,175.17 |
| Racing | 93,465.71 |
| Action | 90,671.63 |
| Puzzle | 87,610.59 |
| RPG | 83,114.14 |
| Indie | 83,113.62 |

**2. Przychody w weekendy vs dni robocze:**
```sql
SELECT
    CASE
        WHEN strftime(revenue_date, '%w') IN ('0', '6') THEN 'Weekend'
        WHEN strftime(revenue_date, '%w') = '5' THEN 'Weekend'
        ELSE 'Dni robocze'
    END AS day_type,
    SUM(total_revenue_usd) AS total_revenue,
    AVG(total_revenue_usd) AS average_daily_revenue
FROM
    gog_data_marts.fact_daily_revenue
GROUP BY
    day_type
ORDER BY
    total_revenue DESC;
```
**Wyniki:**
| Typ Dnia | Całkowity Przychód (USD) | Średni Dzienny Przychód (USD) |
| :--- | :--- | :--- |
| Dni robocze | 561,366.20 | 64.82 |
| Weekend | 423,781.71 | 64.00 |

**3. Średnia wartość transakcji według metody płatności:**
```sql
SELECT
    payment_method,
    SUM(total_revenue_usd) / SUM(total_transactions) AS average_transaction_value_usd
FROM
    gog_data_marts.fact_daily_revenue
GROUP BY
    payment_method
ORDER BY
    average_transaction_value_usd DESC;
```
**Wyniki:**
| Metoda Płatności | Średnia Wartość Transakcji (USD) |
| :--- | :--- |
| GOG Wallet | 10.88 |
| Paysafecard | 10.41 |
| PayPal | 10.36 |
| Bank Transfer | 10.13 |
| Credit Card | 10.03 |
