{{ config(
     enabled = var('claims_preprocessing_enabled',var('claims_enabled',var('tuva_marts_enabled',False)))
 | as_bool
   )
}}


select
      claim_id
    , claim_line_number
    , patient_id
    , member_id
    , payer
    , plan
    , prescribing_provider_npi
    , dispensing_provider_npi
    , dispensing_date
    , ndc_code
    , quantity
    , days_supply
    , refills
    , paid_date
    , paid_amount
    , allowed_amount
    , coinsurance_amount
    , copayment_amount
    , deductible_amount
    , in_network_flag
    , data_source
from {{ ref('pharmacy_claim') }}