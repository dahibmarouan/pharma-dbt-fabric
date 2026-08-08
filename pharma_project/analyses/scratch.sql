select reaction_name, count(*) as nb_cas_graves
from {{ ref('fct_reaction_adverse_events') }}
where is_serious
group by reaction_name
order by nb_cas_graves desc
limit 10