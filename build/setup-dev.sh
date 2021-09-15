# Get the private key from the environment variable
echo "Setting up DEV Connection..."
mkdir keys
echo $CERT_KEY | base64 -d > keys/server.key
# Authenticate to salesforce
echo "Authenticating..."
sfdx force:auth:jwt:grant --clientid $BRAVE_APP_KEY --jwtkeyfile keys/server.key --username $BRAVE_USERNAME --setdefaultdevhubusername -a brave-org