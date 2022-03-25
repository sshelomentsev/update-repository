#!/bin/sh -l

git_setup() {
  cat <<- EOF > $HOME/.netrc
    machine github.com
    login $GITHUB_ACTOR
    password $GITHUB_TOKEN
    machine api.github.com
    login $GITHUB_ACTOR
    password $GITHUB_TOKEN
EOF
  chmod 600 $HOME/.netrc

  git config --global user.email "$GITBOT_EMAIL"
  git config --global user.name "$GITHUB_ACTOR"
}

git_cmd() {
  if [[ "${DRY_RUN:-false}" == "true" ]]; then
    echo $@
  else
    eval $@
  fi
}

SRC_REPO="${INPUT_SOURCE}"

git_setup
git_cmd git remote update

echo "Using repository ${INPUT_SOURCE} to update current"
git_cmd git remote add src "${SRC_REPO}"
git_cmd git fetch src

DST_BRANCH="${INPUT_BRANCH}"
SRC_BRANCH="src/${INPUT_BRANCH}"
git_cmd git merge $SRC_BRANCH
echo "Push to ${DST_BRANCH} branch"
git_cmd git push -u origin $DST_BRANCH
