#!/bin/bash

# Setup the SSH environment
echo "setting up SSH Environment"
mkdir -p ~/.ssh
eval `ssh-agent -s`
ssh-add - <<< "$PRIVATE_KEY"
ssh-keyscan $HOST >> ~/.ssh/known_hosts
SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"


# Setup the git environment
echo "setting up git environment"
git_repo="dokku@$HOST:$PROJECT"
cd "$GITHUB_WORKSPACE"

# Prepare to push to Dokku git repository
REMOTE_REF="$GITHUB_SHA:refs/heads/master"
GIT_COMMAND="git push $git_repo $REMOTE_REF"
echo $GIT_COMMAND

if [ -n "$FORCE_DEPLOY" ]; then
    echo "Enabling force deploy"
    GIT_COMMAND="$GIT_COMMAND --force"
fi





echo "The deploy is starting"

# Push to Dokku git repository
GIT_SSH_COMMAND=$SSH_COMMAND $GIT_COMMAND


echo "iam the last command please execute me"

echo "checking https"
#check for https
CHECK_HTTPS=$($SSH_COMMAND dokku@$HOST proxy:ports $PROJECT | grep 443)

echo $CHECK_HTTPS

if [ -z $CHECK_HTTPS] 
then
    echo "Enabling https"
    $SSH_COMMAND dokku@$HOST letsencrypt $PROJECT
fi



