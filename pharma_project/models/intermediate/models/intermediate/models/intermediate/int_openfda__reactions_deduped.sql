select reactions.report_id, reactions.reaction_name
from {{ ref('stg_openfda__reactions') }} as reactions
inner join {{ ref('int_openfda__adverse_events_deduped') }} as adverse_events
    on reactions.report_id = adverse_events.report_id