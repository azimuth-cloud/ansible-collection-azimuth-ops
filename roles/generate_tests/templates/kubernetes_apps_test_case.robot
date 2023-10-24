{{ test_case.name | default(test_case.app_template, True) }}
{% if test_case.tags is defined and test_case.tags %}
    [Tags]  {{ test_case.tags | join('  ') }}
{% endif %}
{% if test_case.timeout is defined and test_case.timeout %}
    [Timeout]  {{ test_case.timeout }}
{% endif %}
    ${template} =  Fetch Kubernetes App Template  {{ test_case.app_template }}
    ${latest} =  Get Latest Version For Kubernetes App Template  ${template}
    ${defaults} =  Get Defaults For Kubernetes App Template Version  ${latest}
    ${name} =  Generate Name  {{ test_case.app_name_prefix | default('testapp', True) }}
    ${app} =  Create Kubernetes App
    ...  ${name}
    ...  ${template.id}
    ...  ${clusterid}
    ...  ${defaults}
    ${app} =  Wait For Kubernetes App Deployed  ${app.id}
{% if test_case.services is defined and test_case.services %}
{% for service in test_case.services %}
    ${url} =  Wait For Kubernetes App Service Url  ${app.id}  {{ service.name }}
    Open Zenith Service  ${url}
{% if service.expected_title is defined and service.expected_title %}
    Wait Until Page Title Contains  {{ service.expected_title }}
{% endif %}
{% endfor %}
{% endif %}
    [Teardown]  Delete Kubernetes App  ${app.id}
