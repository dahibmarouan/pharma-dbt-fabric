select
    safetyreportid as report_id,
    strptime(receivedate, '%Y%m%d')::date as received_date,
    serious = '1' as is_serious,
    try_cast(patient.patientonsetage as integer) as patient_age,
    patient.patientsex as patient_sex_code
from {{ source('openfda', 'raw_adverse_events') }}