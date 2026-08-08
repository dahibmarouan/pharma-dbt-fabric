select
    drugs.report_id,
    drugs.drug_name,
    adverse_events.received_date,
    adverse_events.is_serious,
    adverse_events.patient_age,
    adverse_events.patient_sex_code
from {{ ref('int_openfda__drugs_deduped') }} as drugs
inner join {{ ref('int_openfda__adverse_events_deduped') }} as adverse_events
    on drugs.report_id = adverse_events.report_id