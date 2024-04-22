!#/bin/bash

#Variables
report_directory="/usr/local/share/Openscapreports"
scan_profile="$chosen_ssg"
content_profile="$chosen_scan_profile"

func1(){

    #yum update -y
    #yum upgrade -y
    #sudo yum install openscap-scanner scap-security-guide aide -y
    ls -l /usr/share/xml/scap/ssg/content/
    echo "Select your preferred scap security guide for the OS"
        read -p "Select your SSG: " $chosen_ssg
    echo "To select, prepend the previous command with OSCAP INFO and append it with the SSG of your choice"
        read -p "Select your scan profile: " $chosen_scan_profile
}

#Performing the assessment
func3(){

    sudo oscap xccdf eval \
    --profile  $scan_profile \
    --results-arf arf.xml \
    --report $report_directory/securityreport_$(hostname)_$(date +%F_%T).html \
    "$content_profile"
}

func1
func3
