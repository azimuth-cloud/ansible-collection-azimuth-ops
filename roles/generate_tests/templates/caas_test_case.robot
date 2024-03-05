{% set test_case_cluster_name_prefix = test_case.cluster_name_prefix | default('test', True) %}
{% set test_case_cluster_name_suffix = lookup('community.general.random_string', length = 5, upper = false, special = false) %}
{% set test_case_cluster_name = test_case_cluster_name_prefix ~ "-" ~ test_case_cluster_name_suffix %}
{% set test_case_tags = test_case.tags | default([]) %}

Create {{ test_case.name | default(test_case.cluster_type, True) }}
    [Tags]  {{ (test_case_tags + ["create"]) | join('  ') }}
{% if test_case.create_timeout is defined and test_case.create_timeout %}
    [Timeout]  {{ test_case.create_timeout }}
{% endif %}
    ${ctype} =  Find Cluster Type By Name  {{ test_case.cluster_type }}
    ${params} =  Guess Parameter Values For Cluster Type  ${ctype}
{% if test_case.params is defined and test_case.params %}
    Set To Dictionary  ${params}
{% for name, value in test_case.params.items() %}
{% if value is boolean %}
    ...  {{ name }}={{ '${True}' if value else '${False}' }}
{% else %}
    ...  {{ name }}={{ value }}
{% endif %}
{% endfor %}
{% endif %}
    ${cluster} =  Create Cluster  {{ test_case_cluster_name }}  ${ctype.name}  &{params}

Verify {{ test_case.name | default(test_case.cluster_type, True) }}
    [Tags]  {{ (test_case_tags + ["verify"]) | join('  ') }}
{% if test_case.verify_timeout is defined and test_case.verify_timeout %}
    [Timeout]  {{ test_case.verify_timeout }}
{% endif %}
    ${cluster} =  Find Cluster By Name  {{ test_case_cluster_name }}
    ${cluster} =  Wait For Cluster Ready  ${cluster.id}
{% if test_case.services is defined and test_case.services %}
{% for service in test_case.services %}
    ${url} =  Get Cluster Service URL  ${cluster}  {{ service.name }}
    Open Zenith Service  ${url}
{% if service.expected_title is defined and service.expected_title %}
    Wait Until Page Title Contains  {{ service.expected_title }}
{% endif %}
{% endfor %}
{% endif %}

Delete {{ test_case.name | default(test_case.cluster_type, True) }}
    [Tags]  {{ (test_case_tags + ["delete"]) | join('  ') }}
{% if test_case.delete_timeout is defined and test_case.delete_timeout %}
    [Timeout]  {{ test_case.delete_timeout }}
{% endif %}
    ${cluster} =  Find Cluster By Name  {{ test_case_cluster_name }}
    Delete Cluster  ${cluster.id}
