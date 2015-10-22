#!/usr/bin/env bash

if [ -z "$OTP_VERSION" ]; then
  echo "OTP_VERSION not set"
else
  echo "Building OTP_VERSION $OTP_VERSION"
  export OTP_URL=https://github.com/erlang/otp/archive/OTP-$OTP_VERSION.tar.gz
  export OTP_TAR_NAME=$(basename https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz)
  export OTP_UNTAR_DIR="otp-OTP-$OTP_VERSION"

  wget $OTP_URL
  echo "******====*******"
  ls
  echo "******====*******"
  tar -zxf $OTP_TAR_NAME
  chmod -R 777 $OTP_UNTAR_DIR

  cd $OTP_UNTAR_DIR

  ./otp_build autoconf
  ./configure --with-ssl --enable-dirty-schedulers
  make
  make release

  cd ../
  mv otp-OTP-${OTP_VERSION}/release/x86_64-unknown-linux-gnu/ OTP-${OTP_VERSION}
  rm OTP-${OTP_VERSION}.tar.gz
  tar -zcf OTP-${OTP_VERSION}.tar.gz OTP-${OTP_VERSION}
fi
