{% set test_case_app_name_prefix = test_case.app_name_prefix | default('testapp', True) %}
{% set test_case_app_name_suffix = lookup('community.general.random_string', length = 5, upper = false, special = false) %}
{% set test_case_app_name = test_case_app_name_prefix ~ "-" ~ test_case_app_name_suffix %}
{% set test_case_tags = test_case.tags | default([]) %}

Create {{ test_case.name | default(test_case.app_template, True) }}
    [Tags]  {{ (test_case_tags + ["create"]) | join('  ') }}
{% if test_case.create_timeout is defined and test_case.create_timeout %}
    [Timeout]  {{ test_case.create_timeout }}
{% endif %}
    ${cluster} =  Find Kubernetes Cluster By Name  ${apps_cluster_name}
    ${template} =  Fetch Kubernetes App Template  {{ test_case.app_template }}
    ${latest} =  Get Latest Version For Kubernetes App Template  ${template}
    ${defaults} =  Get Defaults For Kubernetes App Template Version  ${latest}
    ${app} =  Create Kubernetes App
    ...  {{ test_case_app_name }}
    ...  ${template.id}
    ...  ${cluster.id}
    ...  ${defaults}

Verify {{ test_case.name | default(test_case.app_template, True) }}
    [Tags]  {{ (test_case_tags + ["verify"]) | join('  ') }}
{% if test_case.verify_timeout is defined and test_case.verify_timeout %}
    [Timeout]  {{ test_case.verify_timeout }}
{% endif %}
    ${app} =  Find Kubernetes App By Name  {{ test_case_app_name }}
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

Delete {{ test_case.name | default(test_case.app_template, True) }}
    [Tags]  {{ (test_case_tags + ["delete"]) | join('  ') }}
{% if test_case.delete_timeout is defined and test_case.delete_timeout %}
    [Timeout]  {{ test_case.delete_timeout }}
{% endif %}
    ${app} =  Find Kubernetes App By Name  {{ test_case_app_name }}
    Delete Kubernetes App  ${app.id}
