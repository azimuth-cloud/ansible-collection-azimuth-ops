{{ test_case.name | default('Test ' ~ test_case.cluster_type) }}
{% if "tags" in test_case %}
    [Tags]  {{ test_case.tags | join('  ') }}
{% endif %}
{% if "timeout" in test_case %}
    [Timeout]  {{ test_case.timeout }}
{% endif %}
    ${ctype} =  Find Cluster Type By Name  {{ test_case.cluster_type }}
    ${name} =  Generate Name  {{ test_case.name_prefix | default('test') }}
    ${params} =  Guess Parameter Values For Cluster Type  ${ctype}
{% if "params" in test_case %}
    Set To Dictionary  ${params}
{% for name, value in test_case.params.items() %}
{% if value is boolean %}
    ...  {{ name }}={{ '${TRUE}' if value else '${FALSE}' }}
{% else %}
    ...  {{ name }}={{ value }}
{% endif %}
{% endfor %}
{% endif %}
    ${cluster} =  Create Cluster  ${name}  ${ctype.name}  &{params}
    ${cluster} =  Wait For Cluster Ready  ${cluster.id}
{% for service in (test_case.zenith_services | default([])) %}
    ${service} =  Get Cluster Service URL  ${cluster}  {{ service.name }}
    Open Zenith Service  ${service}
    Wait Until Page Title Contains  {{ service.expected_title }}
{% endfor %}
    [Teardown]  Delete Cluster  ${cluster.id}
