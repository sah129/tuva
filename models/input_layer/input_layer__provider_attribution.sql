{{ config(
     enabled = var('claims_enabled',var('tuva_marts_enabled',False)) | as_bool
   )
}}
SELECT *
FROM {{ ref('provider_attribution') }}
