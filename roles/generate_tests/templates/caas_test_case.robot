{% set test_case_name = test_case.name | default(test_case.cluster_type, True) %}
{% set test_case_tags = test_case.tags | default([]) %}

Create {{ test_case_name }}
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
    ${cluster} =  Create Cluster  ${caas.cluster_names['{{ test_case_name }}']}  ${ctype.name}  &{params}

{% if generate_tests_include_upgrade_tests %}
Upgrade {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["upgrade"]) | join('  ') }}
{% if test_case.upgrade_timeout is defined and test_case.upgrade_timeout %}
    [Timeout]  {{ test_case.upgrade_timeout }}
{% endif %}
    ${cluster} =  Find Cluster By Name  ${caas.cluster_names['{{ test_case_name }}']}
    Patch Cluster  ${cluster.id}
{% endif %}

Verify {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["verify"]) | join('  ') }}
{% if test_case.verify_timeout is defined and test_case.verify_timeout %}
    [Timeout]  {{ test_case.verify_timeout }}
{% endif %}
    ${cluster} =  Find Cluster By Name  ${caas.cluster_names['{{ test_case_name }}']}
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

Delete {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["delete"]) | join('  ') }}
{% if test_case.delete_timeout is defined and test_case.delete_timeout %}
    [Timeout]  {{ test_case.delete_timeout }}
{% endif %}
    ${cluster} =  Find Cluster By Name  ${caas.cluster_names['{{ test_case_name }}']}
    Delete Cluster  ${cluster.id}
