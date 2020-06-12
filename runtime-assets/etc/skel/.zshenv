alias k=kubectl
alias t=terraform
alias v=virsh
alias o=openstack

# AWS Profile switching
aws-profile() {
    unset AWS_PROFILE AWS_EB_PROFILE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    local profile_name="$1"
    local token_code="$2"
    export AWS_PROFILE="$profile_name"
    export SOURCE_AWS_PROFILE="$AWS_PROFILE"
    export AWS_EB_PROFILE="$profile_name"
    export SOURCE_AWS_EB_PROFILE="$AWS_EB_PROFILE"
    caller_identity="$(aws sts get-caller-identity)"
    account_number="$(echo $caller_identity | jq -r '.Account')"
    arn="$(echo $caller_identity | jq -r '.Arn')"
    mfa="$(echo $arn | sed 's|\:user/|\:mfa/|g')"
    export SOURCE_AWS_PROFILE SOURCE_AWS_EB_PROFILE AWS_PROFILE AWS_EB_PROFILE
    if [ -n "$token_code" ]; then
        AWS_CREDENTIALS="$(aws sts get-session-token --serial-number "$mfa" --token-code "$token_code")"
        export AWS_ACCESS_KEY_ID="$(echo "$AWS_CREDENTIALS" | jq -r '.Credentials.AccessKeyId')"
        export SOURCE_AWS_ACCESS_KEY="$AWS_ACCESS_KEY_ID"
        export AWS_SECRET_ACCESS_KEY="$(echo "$AWS_CREDENTIALS" | jq -r '.Credentials.SecretAccessKey')"
        export SOURCE_AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
        export AWS_SESSION_TOKEN="$(echo "$AWS_CREDENTIALS" | jq -r '.Credentials.SessionToken')"
        export SOURCE_AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
    fi
    echo "Using AWS Account: $account_number ($profile_name) - ARN: $arn"
}

aws-role() {
    local role_arn="$1"
    eval $(aws sts assume-role --role-arn "$role_arn" --role-session-name "$USER@$HOST" | jq -r '.Credentials | @sh "export AWS_ACCESS_KEY_ID=\(.AccessKeyId)", @sh "export AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)", @sh "export AWS_SESSION_TOKEN=\(.SessionToken)"')
    aws sts get-caller-identity
}

aws-no-role() {
    export AWS_PROFILE="$SOURCE_AWS_PROFILE"
    export AWS_EB_PROFILE="$SOURCE_AWS_EB_PROFILE"
    export AWS_ACCESS_KEY_ID="$SOURCE_AWS_ACCESS_KEY_ID"
    export AWS_SECRET_ACCESS_KEY="$SOURCE_AWS_SECRET_ACCESS_KEY"
    export AWS_SESSION_TOKEN="$SOURCE_AWS_SESSION_TOKEN"
}

alias mfa="gauth|grep AWS|cut -f3 -d' '"
alias t="terraform"
alias k="kubectl"
