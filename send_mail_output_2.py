import boto3
from botocore.exceptions import ClientError


def generate_presigned_url(bucket_name, object_name, expiration=3600):
    """
    Generate a presigned URL to share an S3 object

    :param bucket_name: string
    :param object_name: string
    :param expiration: Time in seconds for the presigned URL to remain valid
    :return: Presigned URL as string. If error, returns None.
    """
    # Create a session using your current credentials
    session = boto3.session.Session()
    # Get the S3 client using the session
    s3_client = session.client('s3')

    try:
        response = s3_client.generate_presigned_url('get_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': object_name},
                                                    ExpiresIn=expiration)
    except NoCredentialsError:
        print("Credentials not available")
        return None

    return response

# Usage example
if __name__ == "__main__":
    bucket = 'openscap-reports'  # TODO: replace with your bucket name
    key = 'reports/report.html'      # TODO: replace with your object key
    url = generate_presigned_url(bucket, key)

    if url is not None:
        print("Generated presigned URL")


#ref for this - https://docs.aws.amazon.com/ses/latest/dg/send-an-email-using-sdk-programmatically.html#send-an-email-using-sdk-programmatically-examples

# #references the generate_presigned_url.py file to get the presigned URL
# result = subprocess.run(['python3', 'generate_presigned_url.py'], stdout=subprocess.PIPE)

# # Capture the pre-signed URL from the output
# presigned_url = result.stdout.decode().strip()


SENDER = "tompepper20@gmail.com"
RECIPIENT = "tompepper20@gmail.com"
AWS_REGION = "eu-west-2"
SUBJECT = "Security Assessment Completed with OpenScap"

# The email body for recipients with non-HTML email clients.
BODY_TEXT = ("OpenScap Security Assessment Completed\r\n"
             "This email contains a link to the security report for your machine - Download your file here"
            )
            
# The HTML body of the email.
BODY_HTML = f"""
<html>
<head></head>
<body>
  <h1>OpenScap Security Assessment Completed</h1>
  <p>This email contains a link to the security report for your machine <a href="{url}">Download Your File Here!</a></p>
  <p>Please select the latest report from the available options, they are date and timestamped.</p>
</body>
</html>
            """            

# The character encoding for the email.
CHARSET = "UTF-8"

# Create a new SES resource and specify a region.
client = boto3.client('ses',region_name=AWS_REGION)

# Try to send the email.
try:
    #Provide the contents of the email.
    response = client.send_email(
        Destination={
            'ToAddresses': [
                RECIPIENT,
            ],
        },
        Message={
            'Body': {
                'Html': {
                    'Charset': CHARSET,
                    'Data': BODY_HTML,
                },
                'Text': {
                    'Charset': CHARSET,
                    'Data': BODY_TEXT,
                },
            },
            'Subject': {
                'Charset': CHARSET,
                'Data': SUBJECT,
            },
        },
        Source=SENDER,
        # If you are not using a configuration set, comment or delete the
        # following line
        #ConfigurationSetName=CONFIGURATION_SET,
    )
# Display an error if something goes wrong.	
except ClientError as e:
    print(e.response['Error']['Message'])
else:
    print("Email sent! Message ID:"),
    print(response['MessageId'])
