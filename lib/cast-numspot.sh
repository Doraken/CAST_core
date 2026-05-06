function get_encoded_base64()
{
  #|# Description :
  #|# Encodes a given string into Base64 format without line wrapping.
  #|#
  #|# Parameters :
  #|# ${1} : _to_encode
  #|#        String to encode (Mandatory)
  #|#
  #|# Behavior :
  #|# - Uses printf to avoid trailing newline issues
  #|# - Encodes the input string using base64
  #|# - Outputs a single-line Base64 string
  #|#
  #|# Notes :
  #|# - Option -w 0 ensures no line wrapping (GNU base64)
  #|# - Required for HTTP Authorization headers
  #|#
  #|# Example :
  #|# get_encoded_base64 "client_id:client_secret"
  #|#
  #|# Send Back :
  #|# - Base64 encoded string
  local _to_encode="${1}"

  local _encoded="$(printf ${_to_encode} | base64 -w 0 )"

  echo "${_encoded}"
}

function do_numspot_gen_token()
{
  #|# Description :
  #|# Generates an OAuth2 access token using Numspot IAM with client credentials flow.
  #|#
  #|# Parameters :
  #|# ${1} : _numspot_client_id
  #|# ${2} : _numspot_client_secret
  #|# (⚠️ currently NOT used → global variables are used instead)
  #|#
  #|# Behavior :
  #|# - Builds a Basic Authorization header from client_id:client_secret (Base64)
  #|# - Sends a POST request to /iam/token endpoint
  #|# - Uses grant_type=client_credentials
  #|# - Requests scopes: openid + offline_access
  #|# - Extracts access_token from JSON response
  #|#
  #|# Dependencies :
  #|# - curl
  #|# - python3 (for JSON parsing)
  #|#
  #|# Notes :
  #|# - Uses global variables instead of function parameters → design issue
  #|# - No error handling if API call fails
  #|#
  #|# Security Considerations :
  #|# - Sensitive credentials transmitted via Authorization header
  #|# - Avoid logging encoded credentials
  #|#
  #|# Send Back :
  #|# - Prints access_token to stdout
  local _numspot_client_id="${1}"
  local _numspot_client_secret="${2}"
  local _encoded_secret="$(get_encoded_base64 "${NUMSPOT_CLIENT_ID}:${NUMSPOT_CLIENT_SECRET}")"  
  /usr/bin/curl -s -X POST "${NUMSPOT_API_URL}/iam/token"  -H "Authorization: Basic ${_encoded_secret}" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=client_credentials&scope=openid offline_access" | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])"
}

function get_numspot_aksk()
{
   #|# Description :
  #|# Converts an OAuth2 access token into AK/SK credentials
  #|# (Access Key / Secret Key) for Numspot API usage.
  #|#
  #|# Parameters :
  #|# ${1} : _token
  #|#        OAuth2 access token (Mandatory)
  #|#
  #|# Behavior :
  #|# - Sends a PUT request to /iam/token/convert endpoint
  #|# - Passes the token in JSON body
  #|# - Extracts 'ak' and 'sk' from the response
  #|# - Stores them in global variables NUMSPOT_AK and NUMSPOT_SK
  #|#
  #|# Dependencies :
  #|# - curl
  #|# - python3 (for JSON parsing)
  #|#
  #|# Issues / Risks :
  #|# - Uses ${TOKEN} instead of ${_token} → BUG (variable mismatch)
  #|# - No error handling on API response
  #|# - Global variable pollution
  #|#
  #|# Security Considerations :
  #|# - AK/SK are highly sensitive credentials
  #|# - Must be securely stored (vault / env / restricted access)
  #|#
  #|# Send Back :
  #|# - Sets NUMSPOT_AK and NUMSPOT_SK variables globally 
 local _token="${1}"
 local _convert=$( /usr/bin/curl -s -X PUT "${NUMSPOT_API_URL}/iam/token/convert" -H "Content-Type: application/json" -d "{\"token\": \"${_token}\"}" ) 
 NUMSPOT_AK=$(echo "$_convert" | python3 -c "import sys,json; print(json.load(sys.stdin)['ak'])")
 NUMSPOT_SK=$(echo "$_convert" | python3 -c "import sys,json; print(json.load(sys.stdin)['sk'])") 
}

function do_write_configuration()
{
    #|# Description :
  #|# This function writes a configuration file containing AWS-compatible
  #|# credentials (AK/SK) obtained from Numspot IAM.
  #|#
  #|# Behavior :
  #|# - Takes a target file path as input
  #|# - Overwrites the file if it already exists
  #|# - Writes a [default] profile section
  #|# - Inserts access key and secret key values
  #|#
  #|# Parameters :
  #|# ${1} : _config_file
  #|#        Path to the configuration file to create/update (Mandatory)
  #|#
  #|# Dependencies :
  #|# - NUMSPOT_AK : Access Key (must be defined beforehand)
  #|# - NUMSPOT_SK : Secret Key (must be defined beforehand)
  #|#
  #|# Output Format :
  #|# [default]
  #|# aws_access_key_id = <AK>
  #|# aws_secret_access_key = <SK>
  #|#
  #|# Notes :
  #|# - File is overwritten (">") for the first line, then appended (">>")
  #|# - No validation of variables or file path is performed
  #|#
  #|# Security Considerations :
  #|# - The generated file contains sensitive credentials in clear text
  #|# - Ensure proper file permissions (e.g., chmod 600)
  #|# - Do not expose or commit this file
  #|#
  #|# Example :
  #|# do_write_configuration "/home/user/.aws/credentials"
  #|#
  #|# Send Back :
  #|# - Writes credentials into the specified configuration file
  _config_file="${1}"
  echo "[default]"                                 > ${_config_file}
  echo "aws_access_key_id = ${NUMSPOT_AK}"        >> ${_config_file}
  echo "aws_secret_access_key = ${NUMSPOT_SK}"    >> ${_config_file}
}

function do_test_numspot_auth ()
{
  #|# Description :
  #|# Test sequence for Numspot authentication flow:
  #|# - Encode credentials
  #|# - Generate OAuth token
  #|# - Convert token to AK/SK
  #|# - Display structured output

  ############ STACK_TRACE_BUILDER #####################
  Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
  ######################################################

  local _encoded_secret=""
  local _token=""

  set_message "check" "0" "Encoding credentials"
  _encoded_secret="$(get_encoded_base64 "${NUMSPOT_CLIENT_ID}:${NUMSPOT_CLIENT_SECRET}")"
  set_message "debug" "0" "encoded_secret : [ ${_encoded_secret} ]"

  set_message "check" "0" "Generating OAuth token"
  _token="$(do_numspot_gen_token "${NUMSPOT_CLIENT_ID}" "${NUMSPOT_CLIENT_SECRET}")"
  do_error_control "${?}" "Token generation status" "FAILED" "2" "" "" "nomsg"

  set_message "debug" "0" "token : [ ${_token} ]"

  set_message "check" "0" "Converting token to AK/SK"
  get_numspot_aksk "${_token}"
  do_error_control "${?}" "AK/SK conversion status" "FAILED" "2" "" "" "nomsg"

  set_message "EdSMessage" "0" "Authentication flow completed"

  echo ""
  echo "========================================"
  echo " NUMSPOT AUTH RESULT"
  echo "----------------------------------------"
  echo " AK : ${NUMSPOT_AK}"
  echo " SK : ${NUMSPOT_SK}"
  echo "========================================"
}

function prompt_numspot_credentials ()
{
  #|# Description :
  #|# This function ensures NUMSPOT_CLIENT_ID and NUMSPOT_CLIENT_SECRET are set.
  #|# If not defined or empty, it interactively prompts the user to input them.
  #|#
  #|# Behavior :
  #|# - Checks if NUMSPOT_CLIENT_ID is empty → prompts user
  #|# - Checks if NUMSPOT_CLIENT_SECRET is empty → prompts user (hidden input)
  #|# - Exports variables for current shell session
  #|#
  #|# Notes :
  #|# - Secret input is hidden using read -s
  #|# - Does not persist values (no file write)
  #|#
  #|# Security :
  #|# - Avoid echoing secrets
  #|# - Values remain in memory only
  #|#
  #|# Send Back :
  #|# - Sets NUMSPOT_CLIENT_ID and NUMSPOT_CLIENT_SECRET

  local _numspot_client_id="${NUMSPOT_CLIENT_ID}"
  local _numspot_client_secret="${NUMSPOT_CLIENT_SECRET}"

  if [[ -z "${NUMSPOT_CLIENT_ID}" ]]
  then
    echo -n "Enter NUMSPOT_CLIENT_ID: "
    read NUMSPOT_CLIENT_ID
  fi

  if [[ -z "${NUMSPOT_CLIENT_SECRET}" ]]
  then
    echo -n "Enter NUMSPOT_CLIENT_SECRET: "
    read -s NUMSPOT_CLIENT_SECRET
    echo ""
  fi

  export NUMSPOT_CLIENT_ID="${NUMSPOT_CLIENT_ID}"
  export NUMSPOT_CLIENT_SECRET="${NUMSPOT_CLIENT_SECRET}"
}