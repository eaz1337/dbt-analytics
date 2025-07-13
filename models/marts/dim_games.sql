-- Ten model tworzy tabelę wymiaru dla gier, która będzie używana do wzbogacania danych w tabelach faktów.

with game_metadata as (
    select * from {{ source('gog_raw_data', 'game_metadata') }}
)

select
    game_id,
    game_title,
    genre,
    developer,
    release_date
from game_metadata
