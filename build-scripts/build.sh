changed_files=$(
  current_git_branch=$(git rev-parse --abbrev-ref HEAD)
  git diff-tree --no-commit-id --name-only -r $current_git_branch
)

mkdir -p builds/otp

function run_build {
  local heroku_stack=$1
  local otp_version=$2

  docker build -t otp-build build-scripts -f $heroku_stack.dockerfile
  docker run -t -e OTP_VERSION=$otp_version --name=otp-build-${otp_version}-${heroku_stack} otp-build-${heroku_stack}

  docker cp otp-build-${otp_version}-${heroku_stack}:/home/build/OTP-${otp_version}.tar.gz otp-builds/OTP-${otp_version}-${heroku_stack}.tar.gz
  ls builds/otp
}

echo "TRAVIS COMMIT: $TRAVIS_COMMIT"
echo "TRAVIS COMMIT RANGE: $TRAVIS_COMMIT_RANGE"

if [[ $changed_files =~ "otp-versions" ]]; then
  echo "file changed"
else
  echo "file not changed"
fi
