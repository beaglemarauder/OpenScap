import boto3
from botocore.client import Config
from botocore.exceptions import NoCredentialsError

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
    #s3_client = session.client('s3')
    s3_client = session.client('s3', config=Config(signature_version='s3v4'))

    try:
        response = s3_client.generate_presigned_url('get_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': object_name,},
                                                    ExpiresIn=expiration)
    except NoCredentialsError:
        print("Credentials not available")
        return None

    return response

# Usage example
if __name__ == "__main__":
    bucket = 'openscap-reports'  # TODO: replace with your bucket name
    key = 'securityreport.html'      # TODO: replace with your object key
    url = generate_presigned_url(bucket, key)

    if url is not None:
        print("Generated presigned URL: ", url)
