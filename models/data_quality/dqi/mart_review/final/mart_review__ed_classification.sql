{{ config(
     enabled = var('claims_enabled',var('tuva_marts_enabled',False))
 | as_bool
   )
}}

with cte as
(
    select distinct location_id, npi, name
    from {{ ref('core__location') }}
)

select
    e.encounter_id
    , case when s.encounter_id is null then 'Not Classified' else s.ed_classification_description end as ed_classification_description
    , case
        when s.encounter_id is null then 'Non-Avoidable'
        when cast(s.ed_classification_order as int) <= 3 then s.ed_classification_description
        else 'Non-Avoidable' end as avoidable_category
    , e.paid_amount
    , e.primary_diagnosis_code
    , e.primary_diagnosis_description
    , {{ concat_custom([
        'e.primary_diagnosis_code',
        "'|'",
        'e.primary_diagnosis_description'
    ]) }} as primary_diagnosis_and_description
    , p.ccsr_parent_category
    , p.ccsr_category
    , p.ccsr_category_description
    , {{ concat_custom([
        'p.ccsr_category',
        "'|'",
        'p.ccsr_category_description'
    ]) }} as ccsr_parent_category_and_description
    , b.body_system
    , e.facility_id
    , e.allowed_amount
    , e.charge_amount
    , e.data_source
    , e.length_of_stay
    , {{ concat_custom([
        "e.discharge_disposition_code",
        "'|'",
        "e.discharge_disposition_description"
    ]) }} as discharge_code_and_description
    , {{ concat_custom([
        "e.person_id",
        "'|'",
        "e.data_source"
    ]) }} as patient_source_key
    , e.facility_name
    , e.encounter_start_date
    , '{{ var('tuva_last_run') }}' as tuva_last_run
from {{ ref('core__encounter') }} as e
left outer join {{ ref('ed_classification__summary') }} as s on e.encounter_id = s.encounter_id
left outer join cte on e.facility_id = cte.location_id
left outer join {{ ref('ccsr__dx_vertical_pivot') }} as p
  on e.primary_diagnosis_code = p.code
  and p.ccsr_category_rank = 1
left outer join {{ ref('ccsr__dxccsr_v2023_1_body_systems') }} as b on p.ccsr_parent_category = b.ccsr_parent_category
where e.encounter_type = 'emergency department'
