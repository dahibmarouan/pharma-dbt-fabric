-- For the top 5 drugs most associated with serious cases,
-- what are their 3 most frequent reactions?
-- (which drug/reaction pairs occur together most often)

with drug_reactions as (
    select
        drugs.drug_name,
        reactions.reaction_name,
        count(*) as frequency
    from {{ ref('int_openfda__drugs_deduped') }} as drugs
    inner join {{ ref('int_openfda__reactions_deduped') }} as reactions
        on drugs.report_id = reactions.report_id
    group by drugs.drug_name, reactions.reaction_name
),

drug_totals as (
    select drug_name, sum(frequency) as total_mentions
    from drug_reactions
    group by drug_name
    order by total_mentions desc
    limit 5
),

ranked as (
    select
        drug_reactions.drug_name,
        drug_totals.total_mentions,
        drug_reactions.reaction_name,
        drug_reactions.frequency,
        row_number() over (
            partition by drug_reactions.drug_name
            order by drug_reactions.frequency desc
        ) as rank
    from drug_reactions
    inner join drug_totals
        on drug_reactions.drug_name = drug_totals.drug_name
)

select drug_name, total_mentions, reaction_name, frequency
from ranked
where rank <= 3
order by total_mentions desc, frequency desc