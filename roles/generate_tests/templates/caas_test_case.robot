{{ test_case.name | default(test_case.cluster_type, True) }}
{% if test_case.tags is defined and test_case.tags %}
    [Tags]  {{ test_case.tags | join('  ') }}
{% endif %}
{% if test_case.timeout is defined and test_case.timeout %}
    [Timeout]  {{ test_case.timeout }}
{% endif %}
    ${ctype} =  Find Cluster Type By Name  {{ test_case.cluster_type }}
    ${name} =  Generate Name  {{ test_case.cluster_name_prefix | default('test', True) }}
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
    ${cluster} =  Create Cluster  ${name}  ${ctype.name}  &{params}
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
    [Teardown]  Delete Cluster  ${cluster.id}
