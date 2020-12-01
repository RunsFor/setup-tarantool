#!/bin/bash -e

tarantool_default_version="2.6"
version="$1"

detect_os ()
{
  if [[ ( -z "${os}" ) && ( -z "${dist}" ) ]]; then
    if [ -e /etc/centos-release ]; then
      os="centos"
      dist=$(cat /etc/centos-release | grep -Po "[6-9]" | head -1)
    elif [ -e /etc/os-release ]; then
      os=$(. /etc/os-release && echo $ID)
      if [ $os = "debian" ]; then
        dist=$(echo $(. /etc/os-release && echo $VERSION) | sed 's/^[[:digit:]]\+ (\(.*\))$/\1/')
      elif [ $os = "ubuntu" ]; then
        ver_id=$(. /etc/os-release && echo $VERSION_ID)
        if [ $ver_id = "14.04" ]; then
          dist="trusty"
        elif [ $ver_id = "16.04" ]; then
          dist="xenial"
        elif [ $ver_id = "18.04" ]; then
          dist="bionic"
        elif [ $ver_id = "18.10" ]; then
          dist="cosmic"
        elif [ $ver_id = "19.04" ]; then
          dist="disco"
        elif [ $ver_id = "19.10" ]; then
          dist="eoan"
        elif [ $ver_id = "20.04" ]; then
          dist="focal"
        else
          unsupported_os
        fi
      elif [ $os = "fedora" ]; then
        dist=$(. /etc/os-release && echo $VERSION_ID)
      fi
    else
      unsupported_os
    fi
  fi

  if [[ ( -z "${os}" ) || ( -z "${dist}" ) ]]; then
    unsupported_os
  fi

  os="${os// /}"
  dist="${dist// /}"

  echo "Detected operating system as ${os}/${dist}."
}

curl_check ()
{
  echo -n "Checking for curl... "
  if command -v curl > /dev/null; then
    echo
    echo -n "Detected curl... "
  else
    echo
    echo -n "Installing curl... "
    ${package_manager} install -q -y curl &> /dev/null
    if [ "$?" -ne "0" ]; then
      echo "Unable to install curl! Your base system has a problem; please check your default OS's package repositories beca
use curl should work."
      echo "Repository installation aborted."
      exit 1
    fi
  fi
  echo "done."
}

unsupported_os ()
{
  echo "Unfortunately, your operating system is not supported by this script."
  exit 1
}

main ()
{
  detect_os
  if [ ${os} = "centos" ] && [[ ${dist} =~ ^(6|7|8)$ ]]; then
    echo "Setting up yum repository... "
    package_manager="yum"
  elif [ ${os} = "fedora" ] && [[ ${dist} =~ ^(28|29|30|31)$ ]]; then
    echo "Setting up yum repository..."
    package_manager="yum"
  elif ( [ ${os} = "debian" ] && [[ ${dist} =~ ^(jessie|stretch|buster)$ ]] ) ||
       ( [ ${os} = "ubuntu" ] && [[ ${dist} =~ ^(trusty|xenial|bionic|cosmic|disco|eoan|focal)$ ]] ); then
    echo "Setting up apt repository... "
    package_manager="apt-get"
  else
    unsupported_os
  fi

  curl_check

  curl -L https://tarantool.io/release/${version}/installer.sh | bash
  user=$(whoami)
  if [[ $user = 'root' ]]
  then ${package_manager} install -q -y tarantool
  else sudo ${package_manager} install -q -y tarantool
  fi
  tarantool --version
}

main