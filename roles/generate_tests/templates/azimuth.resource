*** Settings ***

Library         Process


*** Keywords ***

Assert Lease Resource End Time
    [Arguments]  ${lease_name}  ${expected_end_time}
    ${normalised_expected_end_time} =  Evaluate
    ...  datetime.datetime.fromisoformat($expected_end_time.replace("Z", "+00:00")).astimezone(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    ...  modules=datetime
    Wait Until Keyword Succeeds  2 minutes  10 seconds
    ...  Lease Resource Should Have End Time
    ...  ${lease_name}
    ...  ${normalised_expected_end_time}

Lease Resource Should Have End Time
    [Arguments]  ${lease_name}  ${expected_end_time}
    ${result} =  Run Process
    ...  kubectl
    ...  get
    ...  leases.scheduling.azimuth.stackhpc.com
    ...  -A
    ...  -o
    ...  json
    ...  stdout=PIPE
    ...  stderr=PIPE
    Should Be Equal As Integers  ${result.rc}  0
    ${lease_end_time} =  Evaluate
    ...  next((item["spec"].get("endsAt") for item in json.loads(output).get("items", []) if item.get("metadata", {}).get("name") == lease_name), None)
    ...  modules=json
    ...  output=${result.stdout}
    ...  lease_name=${lease_name}
    Should Not Be Equal  ${lease_end_time}  ${None}
    Should Be Equal As Strings  ${lease_end_time}  ${expected_end_time}
