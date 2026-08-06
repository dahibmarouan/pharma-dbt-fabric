select *
from {{ source('openfda', 'raw_adverse_events') }}