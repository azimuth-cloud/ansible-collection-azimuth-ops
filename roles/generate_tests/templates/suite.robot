*** Settings ***

Name            {{ generate_tests_suite_name }}
Library         Azimuth
Suite Setup     Setup Test Environment
Suite Teardown  Teardown Test Environment


*** Keywords ***

Setup Test Environment
    Create Client From Environment  {{ generate_tests_azimuth_url }}
    Open Browser

Teardown Test Environment
    Close Client
    Close Browser
