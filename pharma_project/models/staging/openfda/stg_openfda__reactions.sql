select
    safetyreportid as report_id,
    unnest.reactionmeddrapt as reaction_name
from {{ source('openfda', 'raw_adverse_events') }},
     unnest(patient.reaction)