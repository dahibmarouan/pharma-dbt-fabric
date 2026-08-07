select *
from {{ ref('stg_openfda__adverse_events') }}
where not is_duplicate