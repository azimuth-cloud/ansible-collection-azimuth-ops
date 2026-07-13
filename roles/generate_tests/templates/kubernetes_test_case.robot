{% set test_case_name = test_case.name | default(test_case.kubernetes_template, True) %}
{% set test_case_tags = test_case.tags | default([]) %}

Create {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["create"]) | join('  ') }}
{% if test_case.create_timeout is defined and test_case.create_timeout %}
    [Timeout]  {{ test_case.create_timeout }}
{% endif %}
    ${template} =  Fetch Kubernetes Cluster Template  {{ test_case.kubernetes_template }}
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
    ...  name=${kubernetes.cluster_names['{{ test_case_name }}']}
    ...  template=${template.id}
    ...  control_plane_size=${cp_size.id}
    ${config} =  Add Node Group To Kubernetes Config  ${config}
    ...  name=md-0
    ...  machine_size=${worker_size.id}
    ...  count={{ test_case.worker_count }}
{% if test_case.monitoring_enabled is not defined or test_case.monitoring_enabled %}
    ${config} =  Enable Monitoring For Kubernetes Config  ${config}
{% endif %}
{% if generate_tests_kubernetes_scheduling_enabled %}
{% if generate_tests_kubernetes_schedule_end_time %}
    ${schedule_end_time} =  Set Variable  {{ generate_tests_kubernetes_schedule_end_time }}
{% else %}
    ${schedule_end_time} =  Evaluate
    ...  (datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=1)).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    ...  modules=datetime
{% endif %}
    Set Suite Variable  ${kubernetes_schedule_end_time_{{ test_case_name | regex_replace('[^0-9A-Za-z_]', '_') }}}  ${schedule_end_time}
    ${config} =  Enable Scheduling For Kubernetes Config  ${config}  ${schedule_end_time}
{% endif %}
    ${cluster} =  Create Kubernetes Cluster  ${config}

{% if generate_tests_include_upgrade_tests %}
Upgrade {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["upgrade"]) | join('  ') }}
{% if test_case.upgrade_timeout is defined and test_case.upgrade_timeout %}
    [Timeout]  {{ test_case.upgrade_timeout }}
{% endif %}
    ${cluster} =  Find Kubernetes Cluster By Name  ${kubernetes.cluster_names['{{ test_case_name }}']}
    ${template} =  Find Kubernetes Cluster Template For Upgrade  ${cluster.template.id}
    Upgrade Kubernetes Cluster  ${cluster.id}  ${template.id}
{% endif %}

Verify {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["verify"]) | join('  ') }}
{% if test_case.verify_timeout is defined and test_case.verify_timeout %}
    [Timeout]  {{ test_case.verify_timeout }}
{% endif %}
    ${cluster} =  Find Kubernetes Cluster By Name  ${kubernetes.cluster_names['{{ test_case_name }}']}
    ${cluster} =  Wait For Kubernetes Cluster Nodes Ready  ${cluster.id}
    ${cluster} =  Wait For Kubernetes Cluster Addons Deployed  ${cluster.id}
    ${cluster} =  Wait For Kubernetes Cluster Ready  ${cluster.id}
{% if generate_tests_kubernetes_scheduling_enabled %}
    Assert Lease Resource End Time
    ...  kube-${kubernetes.cluster_names['{{ test_case_name }}']}
    ...  ${kubernetes_schedule_end_time_{{ test_case_name | regex_replace('[^0-9A-Za-z_]', '_') }}}
{% endif %}
{% if test_case.monitoring_enabled is not defined or test_case.monitoring_enabled %}
    ${monitoring} =  Get Kubernetes Cluster Service Url  ${cluster}  monitoring
    Open Zenith Service  ${monitoring}
    Wait Until Page Title Contains  Grafana
{% endif %}

Fetch Logs {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["logs"]) | join('  ') }}
    ${cluster} =  Find Kubernetes Cluster By Name  ${kubernetes.cluster_names['{{ test_case_name }}']}
    Query Loki Logs For Kubernetes Cluster  ${cluster.id}
    ...  query={{ test_case.loki_query }}
    ...  limit={{ test_case.loki_limit }}
    ...  output_path={{ test_case_name }}-logs.tar.gz
    ...  loki_namespace={{ test_case.loki_namespace }}
    ...  loki_service={{ test_case.loki_service }}
    ...  loki_port={{ test_case.loki_port }}

Fetch Console Logs {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["logs"]) | join('  ') }}
    ${cluster} =  Find Kubernetes Cluster By Name  ${kubernetes.cluster_names['{{ test_case_name }}']}
    Get Console Logs For Kubernetes Cluster Nodes  ${cluster.id}
    ...  output_prefix={{ test_case_name }}-console-logs

Fetch Nodes {{ test_case_name }}
    [Tags]  {{ test_case_name }}  get-nodes
    ${cluster} =  Find Kubernetes Cluster By Name  ${kubernetes.cluster_names['{{ test_case_name }}']}
    Get Nodes For Kubernetes Cluster  ${cluster.id}
    ...  output_path={{ test_case_name }}-nodes.json

Fetch Pod Events {{ test_case_name }}
    [Tags]  {{ test_case_name }}  pod-events
    ${cluster} =  Find Kubernetes Cluster By Name  ${kubernetes.cluster_names['{{ test_case_name }}']}
    Get Pod Events For Kubernetes Cluster  ${cluster.id}
    ...  output_path={{ test_case_name }}-pod-events.json

Fetch Helm Releases {{ test_case_name }}
    [Tags]  {{ test_case_name }}  helm-releases
    ${cluster} =  Find Kubernetes Cluster By Name  ${kubernetes.cluster_names['{{ test_case_name }}']}
    Get Helm Releases For Kubernetes Cluster  ${cluster.id}
    ...  output_path={{ test_case_name }}-helm-releases.json

Delete {{ test_case_name }}
    [Tags]  {{ (test_case_tags + ["delete"]) | join('  ') }}
{% if test_case.delete_timeout is defined and test_case.delete_timeout %}
    [Timeout]  {{ test_case.delete_timeout }}
{% endif %}
    ${cluster} =  Find Kubernetes Cluster By Name  ${kubernetes.cluster_names['{{ test_case_name }}']}
    Delete Kubernetes Cluster  ${cluster.id}
