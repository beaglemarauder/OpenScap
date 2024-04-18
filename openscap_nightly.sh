#!/bin/bash

#This script will run the openscap security assessment against the machine as listed in the profile, we'll then automate the hourly run and report using cron.
#This script assumes that OpenScap is installed but has included a function if not.

#Variables
report_directory="/usr/local/share/Openscapreports"
scan_profile="xccdf_org.ssgproject.content_profile_pci-dss"
content_profile=/usr/share/xml/scap/ssg/content/ssg-centos8-ds-1.2.xml


#Installing Openscap AND making a reports directory. 
# func1(){

#     yum update -y
#     yum upgrade -y
#     sudo yum install openscap-scanner scap-security-guide aide -y
#     ls -l /usr/share/xml/scap/ssg/content/
#     echo "Select your preferred scap security guide for the OS"
#     echo "To select, prepend the previous command with OSCAP INFO and append it with the SSG of your choice"
#     #in this instance it has already been added to the variable, will get Ali to help me write it so that your input with read is used to populate the variable. 

# }

#Make the reports directory if it doesn't exist and get the scanning information
func2(){
    mkdir -p {$report_directory}
}

#Performing the assessment
func2(){

    oscap xccdf eval
    --profile  {$scan_profile} \
    --results-arf arf.xml \
    --report {$report_directory}/securityreport_$(hostname)_$(date +%F_%T).txt \
    {"$content_profile"}
}

#Sending the html report as an email to security folk
# func3(){

#  recipient="thomaspepper@duck.com"
#  subject="OpenScap Report"
#  body="The output of the report should be attached. Security Never Sleeps"
#  file_path="$report_directory/report.html"

# echo {"$body"} | mail -v -s {"$subject"} {$file_path} {"$recipient"}

# }

func2
func3




