changed_files=$(
  current_git_branch=$(git rev-parse --abbrev-ref HEAD)
  git diff-tree --no-commit-id --name-only -r $current_git_branch
)

mkdir -p builds/otp

function run_build {
  docker build -t otp-build build-scripts -f $HEROKU_STACK.dockerfile
  docker run -t -e OTP_VERSION=$OTP_VERSION --name=otp-build-${OTP_VERSION}-${HEROKU-STACK} otp-build-${HEROKU_STACK}

  docker cp otp-build-${OTP_VERSION}:/home/build/OTP-${OTP_VERSION}.tar.gz otp-builds/OTP-${OTP_VERSION}-${HEROKU_STACK}.tar.gz
  ls builds/otp
}

if [[ $changed_files =~ "otp-versions" ]]; then
  echo "file changed"
else
  echo "file not changed"
fi
