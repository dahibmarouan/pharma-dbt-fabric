select
    reactions.report_id,
    reactions.reaction_name,
    adverse_events.received_date,
    adverse_events.is_serious,
    adverse_events.patient_age,
    adverse_events.patient_sex_code
from {{ ref('int_openfda__reactions_deduped') }} as reactions
inner join {{ ref('int_openfda__adverse_events_deduped') }} as adverse_events
    on reactions.report_id = adverse_events.report_id