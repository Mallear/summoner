#!/bin/bash

function usage
{
  echo -e "Summoner "
  echo -e "Maxime Sibellas - maxime.sibellas@gmail.com"
  echo -e "Usage : $0 <action>"
  echo -e "\nAction :"
  echo -e "install : install Summoner context."
  echo -e "summon : summon a minion. Get sources, install an deploy."
  echo -e "release : release a minion."
  echo -e "uninstall : uninstall Summoner context."
  echo -e "\nFor more info and examples, please see the README file.\n\n"
  exit 1
}

case "$1" in
  "install")
    if [ ! -d "script/tools" ]; then
      git clone git@gitlab.com:puzle-project/Summoner.git
    fi
    script/tools/setup.sh
  ;;
  "summon")
    if [ ! -f ~/.summoner ]; then
      echo -e "Summoner not installed. Please install before summoning a minion."
      exit 1
    fi
    if [ $# -neq 2 ]; then
      usage
    fi
    script/tools/summon.sh $2
  ;;
  "unleash")
    echo "not implemented yet"
  ;;
  "uninstall")
    echo "not implemented yet"
  ;;
  *)
    usage
  ;;
esac
