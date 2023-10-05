*** Settings ***

Name          {{ generate_tests_kubernetes_suite_name }}
Library       Azimuth
Library       Collections
Test Tags     {{ generate_tests_kubernetes_default_test_tags | join("  ") }}
Test Timeout  {{ generate_tests_kubernetes_default_test_timeout }}


*** Test Cases ***

{% for test_case in generate_tests_kubernetes_test_cases %}
{% include (test_case.template | default(generate_tests_kubernetes_test_case_template, True)) %}


{% endfor %}
