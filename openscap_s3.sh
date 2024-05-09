#!/usr/bin/env bash

#Variables
report_directory="/user/ssm-user/OpenScap/SecurityReports"
arf_output="/user/ssm-user/OpenScap/arf_outputs"
scan_profile="xccdf_org.ssgproject.content_profile_standard"
content_profile="/usr/share/xml/scap/ssg/content/ssg-al2023-ds.xml"
file_name="securityreport.html"
arf_report="securityreport_arf.xml"

#_$(hostname)_$(date +%F_%T)

#Some VMs come with the stuff baked in which may cause problems with the content so we need to check if the item's exist first. 
# prechecks(){
# dnf list scap-security-guide
#     if [[ $? -eq 1 ]] then
#         echo "scap-security-guide is installed"
#     fi
# dnf list openscap-scanner
#     if [[ $? -eq 1 ]] then
#         echo "openscap-scanner is installed"
#     fi
# dnf list aide
#     if [[ $? -eq 1 ]] then
#         echo "aide is installed"
#     fi
# }
#Installing Openscap AND making a reports directory. 
func1(){

    yum update -y
    yum upgrade -y
    sudo yum install openscap-scanner scap-security-guide aide -y
}

#Create S3 buckets and the local report directory 
func2(){
    #Authentication 
    $AWS_ACCESS_KEY_ID
    $AWS_SECRET_ACCESS_KEY

    #Create the bucket
    
    aws s3api create-bucket --bucket openscap-reports --create-bucket-configuration LocationConstraint=eu-west-2
   
   #Make the report directory 
   sudo mkdir -p $report_directory
   sudo mkdir -p $arf_output    
}

#Performing the assessment
func3(){

    sudo oscap xccdf eval \
    --profile  $scan_profile \
    --results-arf $arf_output/$arf_report \
    --report $report_directory/$file_name \
    "$content_profile"
}
 func4(){
    aws s3api put-object --bucket openscap-reports --server-side-encryption AES256 --key reports/securityreport.html --body /user/ssm-user/OpenScap/SecurityReports/securityreport.html
 }



sleep 15s

#Sending the html report as an email to security folk
func5(){
    sudo  dnf install pip -y
        if [[ $? -eq 0 ]] then
            echo "pip is already installed"
        fi 

    sleep 10s

    sudo pip install boto3
        if [[ $? -eq 0 ]] then
            echo "boto is already installed"
        fi
    
    #run the email script using python sdk
    python3 send_mail_output_2.py
}

#prechecks
func1
func2
func3
func4
func5
