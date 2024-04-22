#!/bin/bash

#This script will run the openscap security assessment against the machine as listed in the profile, we'll then automate the hourly run and report using cron.
#This script assumes that OpenScap is installed but has included a function if not.

#Variables
report_directory="/usr/local/share/Openscapreports"
scan_profile="xccdf_org.ssgproject.content_profile_pci-dss"
content_profile="/usr/share/xml/scap/ssg/content/ssg-centos8-ds-1.2.xml"


#Some VM's come with the stuff baked in which may cause problems with the content so we need to check if the item's exist first. 
prechecks(){
dnf list scap-security-guide

    if [ $? -eq 0 ] then;
        echo "scap-security-guide is not installed"
    else
        sudo yum autoremove scap-security-guide -y
    fi
    
dnf list openscap-scanner
    if [ $? -eq 0 ] then;
        echo "openscap-scanner is not installed"
    else
        sudo yum autoremove openscap-scanner -y
    fi
    
dnf list aide
    if [ $? -eq 0 ] then;
        echo "aide is not installed"
    else
        sudo yum autoremove aide -y
    fi
}

#Installing Openscap AND making a reports directory. 
func1(){

    yum update -y
    yum upgrade -y
    sudo yum install openscap-scanner scap-security-guide aide -y
    #ls -l /usr/share/xml/scap/ssg/content/
    #echo "Select your preferred scap security guide for the OS"
    #echo "To select, prepend the previous command with OSCAP INFO and append it with the SSG of your choice"
    #in this instance it has already been added to the variable, will get Ali to help me write it so that your input with read is used to populate the variable. 

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

#Sending the html report as an email to security folk
# func4(){

#  recipient="thomaspepper@duck.com"
#  subject="OpenScap Report"
#  body="The output of the report should be attached. Security Never Sleeps"
#  file_path="$report_directory/report.html"

# echo {"$body"} | mail -v -s {"$subject"} {$file_path} {"$recipient"}

# }

prechecks
func1
func2
func3



