select drugs.report_id, drugs.drug_name
from {{ ref('stg_openfda__drugs') }} as drugs
inner join {{ ref('int_openfda__adverse_events_deduped') }} as adverse_events
    on drugs.report_id = adverse_events.report_id