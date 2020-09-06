#!/bin/sh
#Commands To Execute
#dokku proxy:ports-remove wichproj http:3000:3000
#dokku proxy:ports-add wichproj http:80:3000
#dokku proxy:ports-add wichproj https:443:3000
#dokku letsencrypt wichproj

# Setup the SSH environment
echo "setting up SSH Environment"
mkdir -p ~/.ssh
eval `ssh-agent -s`
ssh-add - <<< "$PRIVATE_KEY"
ssh-keyscan $HOST >> ~/.ssh/known_hosts

# Setup the git environment
echo "setting up git environment"
git_repo="dokku@$HOST:$PROJECT"
cd "$GITHUB_WORKSPACE"
git remote add deploy "$git_repo"
git show-ref

# Prepare to push to Dokku git repository
REMOTE_REF="$GITHUB_SHA:refs/heads/$BRANCH"
GIT_COMMAND="git push deploy $REMOTE_REF"
echo $GIT_COMMAND

if [ -n "$FORCE_DEPLOY" ]; then
    echo "Enabling force deploy"
    GIT_COMMAND="$GIT_COMMAND --force"
fi

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no dokku@apps.mobird.in proxy:ports $PROJECT

echo "The deploy is starting"
# Push to Dokku git repository
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" $GIT_COMMAND


