select
    safetyreportid as report_id,
    strptime(receivedate, '%Y%m%d')::date as received_date,
    serious = '1' as is_serious,
    try_cast(patient.patientonsetage as integer) as patient_age,
    patient.patientsex as patient_sex_code,
    case when duplicate = '1' then true else false end as is_duplicate
from {{ source('openfda', 'raw_adverse_events') }}