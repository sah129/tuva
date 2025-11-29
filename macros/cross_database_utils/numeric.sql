{% macro numeric() -%}
    {{ adapter.dispatch('numeric')() }}
{%- endmacro %}

{% macro default__numeric() -%}
    NUMERIC
{%- endmacro %}

{% macro athena__numeric() -%}
    REAL
{%- endmacro %}
