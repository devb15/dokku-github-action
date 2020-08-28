#!/bin/sh
set -e
#Commands To Execute
#dokku proxy:ports-remove wichproj http:3000:3000
#dokku proxy:ports-add wichproj http:80:3000
#dokku proxy:ports-add wichproj https:443:3000
#dokku letsencrypt wichproj

# Setup the SSH environment
mkdir -p ~/.ssh
eval `ssh-agent -s`
ssh-add - <<< "$SSH_PRIVATE_KEY"
ssh-keyscan $DOKKU_HOST >> ~/.ssh/known_hosts

# Setup the git environment
echo "setting the git environment"
git_repo="dokku@$HOST:$PROJECT"
cd "$GITHUB_WORKSPACE"
git remote add deploy "$git_repo"

# Prepare to push to Dokku git repository
REMOTE_REF="$GITHUB_SHA:refs/heads/$BRANCH"
GIT_COMMAND="git push deploy $REMOTE_REF"

if [ -n "$FORCE_DEPLOY" ]; then
    echo "Enabling force deploy"
    GIT_COMMAND="$GIT_COMMAND --force"
fi

echo "The deploy is starting"
# Push to Dokku git repository
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" $GIT_COMMAND
