#!/bin/bash

FILEDIR=/opt/genesyslogs/mcafee

exec   > >(tee -ia $FILEDIR/mcafee-install.log)
exec  2> >(tee -ia $FILEDIR/mcafee-install.log >& 2)
exec 19> $FILEDIR/mcafee-install.log

export BASH_XTRACEFD="19"
#set -x

version_compare() {
    if [[ $1 =~ ^([0-9]+\.?)+$ && $2 =~ ^([0-9]+\.?)+$ ]]; then
        local l=(${1//./ }) r=(${2//./ }) s=${#l[@]}; [[ ${#r[@]} -gt ${#l[@]} ]] && s=${#r[@]}

        for i in $(seq 0 $((s - 1))); do
            [[ ${l[$i]} -gt ${r[$i]} ]] && return 1
            [[ ${l[$i]} -lt ${r[$i]} ]] && return 2
        done

        return 0
    else
        echo "Invalid version number given"
        exit 1
    fi
}

cd /opt/genesyslogs/mcafee
rpm -qa | grep MFE
cmastatus=$?
#cmastatus=1
if [ "$cmastatus" == 0 ]
then
  cmaversion=`rpm -q --qf "%{VERSION}" MFEcma`
  echo
  echo "Agent version is " $cmaversion
  echo
  version_compare $cmaversion 5.5.0
  retval=$?

  if [ "$retval" == 2 ]
  then
     echo "To upgrade Agent."
     echo "./install.sh -u"
     ./install.sh -u
     echo "Current version."
     rpm -qa | grep MFE
  else
     echo "Latest version. No action. "
  fi

else
  echo "No Agent installed. To install Agent."
  echo "./install.sh -i"
  ./install.sh -i
  echo "Current version."
  rpm -qa | grep MFE
fi

echo
rpm -qa |grep ISecTP
isecstatus=$?
#isecstatus=0
isecversion=`rpm -q --qf "%{VERSION}" ISecTP`
#isecversion=10.5.0

if [ "$isecstatus" == 0 ]
then
  version_compare $isecversion 10.5.5
  echo "ISec exists. Version is" $isecversion
else
  echo "Installing ISec. "
  echo "./install-isec.sh silent"
  ./install-isectp.sh silent
  echo "Current version."
  rpm -qa |grep ISec
fi
