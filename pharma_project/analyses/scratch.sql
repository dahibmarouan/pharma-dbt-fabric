-- Pour les 5 médicaments les plus associés à des cas graves,
-- quelles sont leurs 3 réactions les plus fréquentes ?
-- (quelles paires médicament/réaction reviennent le plus souvent ensemble)

with drug_reactions as (
    select
        drugs.drug_name,
        reactions.reaction_name,
        count(*) as frequence
    from {{ ref('int_openfda__drugs_deduped') }} as drugs
    inner join {{ ref('int_openfda__reactions_deduped') }} as reactions
        on drugs.report_id = reactions.report_id
    group by drugs.drug_name, reactions.reaction_name
),

drug_totals as (
    select drug_name, sum(frequence) as total_mentions
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
        drug_reactions.frequence,
        row_number() over (
            partition by drug_reactions.drug_name
            order by drug_reactions.frequence desc
        ) as rang
    from drug_reactions
    inner join drug_totals
        on drug_reactions.drug_name = drug_totals.drug_name
)

select drug_name, total_mentions, reaction_name, frequence
from ranked
where rang <= 3
order by total_mentions desc, frequence desc