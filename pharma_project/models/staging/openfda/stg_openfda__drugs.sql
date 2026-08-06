select
    safetyreportid as report_id,
    unnest.medicinalproduct as drug_name
from {{ source('openfda', 'raw_adverse_events') }},
     unnest(patient.drug)