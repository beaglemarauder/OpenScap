#!/bin/bash

#This script will run the openscap security assessment against the machine as listed in the profile, we'll then automate the hourly run and report using cron.
#This script assumes that OpenScap is installed but has included a function if not.

#Variables
report_directory="/var/www/html/Openscapreports"
scan_profile="xccdf_org.ssgproject.content_profile_standard"
content_profile="/usr/share/xml/scap/ssg/content/ssg-al2023-ds.xml"


#Some VMs come with the stuff baked in which may cause problems with the content so we need to check if the item's exist first. 
# prechecks(){
# dnf list scap-security-guide
#     if [[ $? -eq 1 ]] then
#         echo "scap-security-guide is installed"
#     else
#         sudo yum autoremove scap-security-guide -y
#     fi
# dnf list openscap-scanner
#     if [[ $? -eq 1 ]] then
#         echo "openscap-scanner is installed"
#     else
#         sudo yum autoremove openscap-scanner -y
#     fi
# dnf list aide
#     if [[ $? -eq 1 ]] then
#         echo "aide is installed"
#     else
#         sudo yum autoremove aide -y
#     fi
# }
#Installing Openscap AND making a reports directory. 
func1(){

    yum update -y
    yum upgrade -y
    sudo yum install openscap-scanner scap-security-guide aide -y
    #ls -la /usr/share/xml/scap/ssg/content/
    # echo "Now run the folllowing command oscap info + {your chosen ssg profile}"
    # echo "For example oscap info /usr/share/xml/scap/ssg/content/ssg-al2023-ds.xml"
    # echo "You will be presented with a list of SSGs and you can choose one to scan"
    
    # echo "Select your preferred scap security guide for the OS"
    #     read -p "Select your SSG"> $chosen_ssg
    # echo "To select, prepend the previous command with OSCAP INFO and append it with the SSG of your choice"
    #     read -p "Select your scan profile" > $chosen_scan_profile


}

#Make the reports directory if it doesn't exist and get the scanning information
func2(){

    #building the webserver using httpd
    sudo dnf install httpd -y
        if [[ $? -eq 1 ]] then
            echo "httpd is installed"
        fi
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo systemctl status httpd
    sudo chmod 777 /var/www/html
    #building the report directory on the apache web server
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
    sudo  dnf install pip -y
        if [[ $? -eq 1 ]] then
            echo "pip is already installed"
        fi 
    sudo pip install boto3 -y
        if [[ $? -eq 1 ]] then
            echo "boto is already installed"
        fi
    #Move to the report directory for the script. 
    #cd home/ssm-user/OpenScap
    #run the email script using python sdk
    sudo python3 /home/ssm-user/OpenScap/send_mail_output.py
}

#prechecks
func1
func2
func3
#func4
func5
