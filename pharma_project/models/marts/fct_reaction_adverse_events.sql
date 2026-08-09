select
    reactions.report_id,
    reactions.reaction_name,
    adverse_events.received_date,
    adverse_events.is_serious,
    adverse_events.patient_age,
    adverse_events.patient_sex_code,
     case
        when adverse_events.patient_age is null then 'Inconnu'
        when adverse_events.patient_age < 18 then '0-17 ans'
        when adverse_events.patient_age < 45 then '18-44 ans'
        when adverse_events.patient_age < 65 then '45-64 ans'
        else '65 ans et plus'
    end as age_bracket
from {{ ref('int_openfda__reactions_deduped') }} as reactions
inner join {{ ref('int_openfda__adverse_events_deduped') }} as adverse_events
    on reactions.report_id = adverse_events.report_id