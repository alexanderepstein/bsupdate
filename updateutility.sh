#!/bin/bash
# Author: Alexander Epstein https://github.com/alexanderepstein
# Update utility version 1.1.0
# To test the tool enter in the defualt values that are in the examples for each variable
currentVersion="" #This version variable should not have a v but should contain all other characters ex Github release tag is v1.2.4 currentVersion is 1.2.4
repositoryName="" #Name of repostiory to be updated ex. Sandman-Lite
githubUserName="" #username that hosts the repostiory ex. alexanderepstein
nameOfInstallFile="install.sh" # change this if the installer file has a different name be sure to include file extension if there is one


if [[ $currentVersion == "" || $repositoryName == "" || $githubUserName == "" ]];then
  echo "Error: update utility has not been configured correctly." >&2
  exit 1

elif [[ $(curl -s https://api.github.com/repos/$githubUserName/$repositoryName/tags) == "" ]];then
  echo "Error: no active internet connection" >&2
  exit 1
else
  latestVersion=$(curl -s https://api.github.com/repos/$githubUserName/$repositoryName/tags | grep -Eo '"name":.*?[^\\]",'| head -1 | grep -Eo "[0-9].[0-9].*[0-9]*\b" ) #always grabs the tag without the v option
  if [[ "$latestVersion" != "$currentVersion"  && "$latestVersion" != "" ]]; then
    echo "Version $latestVersion available"
    echo -n "Do you wish to update $repositoryName [Y/n]: "
    read -r answer
    if [[ "$answer" == "Y" || "$answer" == "y" ]] ;then
      cd  ~ || { echo 'Update Failed' ; exit 1 ; }
      echo "Your password is required to continue with the update" #echoing this because of the sudo call
      sudo rm -r $repositoryName  2> /dev/null #defaulting this command to sudo if you know you will already be root (kali linux) this wont be necessary
      git clone "https://github.com/$githubUserName/$repositoryName" || { echo "Couldn't download latest version" ; exit 1; }
      cd $repositoryName ||  { echo 'Update Failed' ; exit 1 ;}
      git checkout "v$latestVersion" 2> /dev/null || git checkout "$latestVersion" 2> /dev/null || echo "Couldn't git checkout to stable release, updating to latest commit."
      #chmod +x install.sh #this might be necessary in your case but wasnt in mine.
      "./$nameOfInstallFile"
      cd ..
      sudo rm -r $repositoryName #defaulting this command to sudo if you know you will already be root (kali linux) this wont be necessary
    else
      exit 1
    fi

  else
    echo "$repositoryName is already the latest version"
  fi
fi
