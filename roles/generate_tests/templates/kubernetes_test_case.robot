{{ test_case.name | default(test_case.kubernetes_template, True) }}
{% if test_case.tags is defined and test_case.tags %}
    [Tags]  {{ test_case.tags | join('  ') }}
{% endif %}
{% if test_case.timeout is defined and test_case.timeout %}
    [Timeout]  {{ test_case.timeout }}
{% endif %}
    ${template} =  Fetch Kubernetes Cluster Template  {{ test_case.kubernetes_template }}
    ${name} =  Generate Name  {{ test_case.cluster_name_prefix | default('test', True) }}
{% if test_case.control_plane_size is defined and test_case.control_plane_size %}
    ${cp_size} =  Fetch Size  {{ test_case.control_plane_size }}
{% else %}
    ${cp_size} =  Find Smallest Size With Resources  min_cpus=2  min_ram=4096  min_disk=20
{% endif %}
{% if test_case.worker_size is defined and test_case.worker_size %}
    ${worker_size} =  Fetch Size  {{ test_case.worker_size }}
{% else %}
    ${worker_size} =  Find Smallest Size With Resources  min_cpus=2  min_ram=4096  min_disk=20
{% endif %}
    ${config} =  New Kubernetes Config
    ...  name=${name}
    ...  template=${template.id}
    ...  control_plane_size=${cp_size.id}
    ${config} =  Add Node Group To Kubernetes Config  ${config}
    ...  name=md-0
    ...  machine_size=${worker_size.id}
    ...  count={{ test_case.worker_count }}
{% if test_case.dashboard_enabled is not defined or test_case.dashboard_enabled %}
    ${config} =  Enable Dashboard For Kubernetes Config  ${config}
{% endif %}
{% if test_case.monitoring_enabled is not defined or test_case.monitoring_enabled %}
    ${config} =  Enable Monitoring For Kubernetes Config  ${config}
{% endif %}
    ${cluster} =  Create Kubernetes Cluster  ${config}
    ${cluster} =  Wait For Kubernetes Cluster Ready  ${cluster.id}
{% if test_case.dashboard_enabled is not defined or test_case.dashboard_enabled %}
    ${dashboard} =  Get Kubernetes Cluster Service Url  ${cluster}  dashboard
    Open Zenith Service  ${dashboard}
    Wait Until Page Title Contains  Kubernetes Dashboard
{% endif %}
{% if test_case.monitoring_enabled is not defined or test_case.monitoring_enabled %}
    ${monitoring} =  Get Kubernetes Cluster Service Url  ${cluster}  monitoring
    Open Zenith Service  ${monitoring}
    Wait Until Page Title Contains  Grafana
{% endif %}
    [Teardown]       Delete Kubernetes Cluster  ${cluster.id}
