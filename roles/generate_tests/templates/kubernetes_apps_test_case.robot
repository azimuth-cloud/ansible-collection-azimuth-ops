{% set test_case_name = app_test_case.name | default(app_test_case.app_template, True) %}
{% set test_case_tags = app_test_case.tags | default([]) %}
{% set test_case_cluster_name = test_case.name | default(test_case.kubernetes_template, True) %}

Create {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["create"]) | join('  ') }}
{% if app_test_case.create_timeout is defined and app_test_case.create_timeout %}
    [Timeout]  {{ app_test_case.create_timeout }}
{% endif %}
    ${cluster} =  Find Kubernetes Cluster By Name  ${kubernetes.cluster_names['{{ test_case_cluster_name }}']}
    ${template} =  Fetch Kubernetes App Template  {{ app_test_case.app_template }}
    ${latest} =  Get Latest Version For Kubernetes App Template  ${template}
    ${defaults} =  Get Defaults For Kubernetes App Template Version  ${latest}
    ${app} =  Create Kubernetes App
    ...  ${kubeapps.app_names['{{ test_case_name }}']}
    ...  ${template.id}
    ...  ${cluster.id}
    ...  ${defaults}

{% if generate_tests_include_upgrade_tests %}
Upgrade {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["upgrade"]) | join('  ') }}
{% if app_test_case.upgrade_timeout is defined and app_test_case.upgrade_timeout %}
    [Timeout]  {{ app_test_case.upgrade_timeout }}
{% endif %}
    ${app} =  Find Kubernetes App By Name  ${kubeapps.app_names['{{ test_case_name }}']}
    ${template} =  Fetch Kubernetes App Template  ${app.template.id}
    ${latest} =  Get Latest Version For Kubernetes App Template  ${template}
    ${defaults} =  Get Defaults For Kubernetes App Template Version  ${latest}
    Update Kubernetes App  ${app.id}  ${latest}  ${defaults}
{% endif %}

Verify {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["verify"]) | join('  ') }}
{% if app_test_case.verify_timeout is defined and app_test_case.verify_timeout %}
    [Timeout]  {{ app_test_case.verify_timeout }}
{% endif %}
    ${app} =  Find Kubernetes App By Name  ${kubeapps.app_names['{{ test_case_name }}']}
    ${app} =  Wait For Kubernetes App Deployed  ${app.id}
{% if app_test_case.services is defined and app_test_case.services %}
{% for service in app_test_case.services %}
    ${url} =  Wait For Kubernetes App Service Url  ${app.id}  {{ service.name }}
    Open Zenith Service  ${url}
{% if service.expected_title is defined and service.expected_title %}
    Wait Until Page Title Contains  {{ service.expected_title }}
{% endif %}
{% endfor %}
{% endif %}

Delete {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["delete"]) | join('  ') }}
{% if app_test_case.delete_timeout is defined and app_test_case.delete_timeout %}
    [Timeout]  {{ app_test_case.delete_timeout }}
{% endif %}
    ${app} =  Find Kubernetes App By Name  ${kubeapps.app_names['{{ test_case_name }}']}
    Delete Kubernetes App  ${app.id}
