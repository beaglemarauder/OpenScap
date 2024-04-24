#!/bin/bash

#This script will run the openscap security assessment against the machine as listed in the profile, we'll then automate the hourly run and report using cron.
#This script assumes that OpenScap is installed but has included a function if not.

#Variables
report_directory="/usr/local/share/Openscapreports"
scan_profile="xccdf_org.ssgproject.content_profile_standard"
content_profile="/usr/share/xml/scap/ssg/content/ssg-al2023-ds.xml"


#Some VM's come with the stuff baked in which may cause problems with the content so we need to check if the item's exist first. 
prechecks(){
dnf list scap-security-guide
    if [[ $? -eq 1 ]] then
        echo "scap-security-guide is installed"
    fi
dnf list openscap-scanner
    if [[ $? -eq 1 ]] then
        echo "openscap-scanner is installed"
    fi
dnf list aide
    if [[ $? -eq 1 ]] then
        echo "aide is installed"
    fi
}
#Installing Openscap AND making a reports directory. 
func1(){

    yum update -y
    yum upgrade -y
    sudo yum install openscap-scanner scap-security-guide aide -y
    cd ls -la /usr/share/xml/scap/ssg/content/
    echo "Now run the folllowing command oscap info + {your chosen ssg profile}"
    echo "For example oscap info /usr/share/xml/scap/ssg/content/ssg-al2023-ds.xml"
    echo "You will be presented with a list of SSGs and you can choose one to scan"
    
    # echo "Select your preferred scap security guide for the OS"
    #     read -p "Select your SSG"> $chosen_ssg
    # echo "To select, prepend the previous command with OSCAP INFO and append it with the SSG of your choice"
    #     read -p "Select your scan profile" > $chosen_scan_profile


}

#Make the reports directory if it doesn't exist and get the scanning information
func2(){
    sudo mkdir -p $report_directory
}

#Performing the assessment
func3(){

    sudo oscap xccdf eval \
    --profile  $scan_profile \
    --results-arf arf.xml \
    --report $report_directory/securityreport_$(hostname)_$(date +%F_%T).html \
    "$content_profile"
}


# # func4(){

#     sleep 15m
# }


#Sending the html report as an email to security folk
func5(){
    #Move to the report directory for the script. 
    cd /Users/Tom.Pepper/Documents/Bash/AWS_Testing
    #run the email script using python sdk
    python3 send_mail.output.py
}

prechecks
func1
func2
func3
#func4
func5
