#!/bin/bash
# Author: Alexander Epstein https://github.com/alexanderepstein
# Update utility version 1.2.0
# To test the tool enter in the defualt values that are in the examples for each variable
currentVersion="" #This version variable should not have a v but should contain all other characters ex Github release tag is v1.2.4 currentVersion is 1.2.4
repositoryName="" #Name of repostiory to be updated ex. Sandman-Lite
githubUserName="" #username that hosts the repostiory ex. alexanderepstein
nameOfInstallFile="install.sh" # change this if the installer file has a different name be sure to include file extension if there is one
latestVersion=$(curl -s https://api.github.com/repos/$githubUserName/$repositoryName/tags | grep -Eo '"name":.*?[^\\]",'| head -1 | grep -Eo "[0-9.]+" ) #always grabs the tag without the v option

if [[ $currentVersion == "" || $repositoryName == "" || $githubUserName == "" || $nameOfInstallFile == "" ]];then
  echo "Error: update utility has not been configured correctly." >&2
  exit 1
elif [[ $latestVersion == "" ]];then
  echo "Error: no active internet connection" >&2
  exit 1
else
  if [[ "$latestVersion" != "$currentVersion" ]]; then
    echo "Version $latestVersion available"
    echo -n "Do you wish to update $repositoryName [Y/n]: "
    read -r answer
    if [[ "$answer" == "Y" || "$answer" == "y" ]] ;then
      cd  ~ || { echo 'Update Failed' ; exit 1 ; }
      if [[ -d  ~/$repositoryName ]]; then rm -r -f $repositoryName  || { echo "Your password is required to continue with the update" ; sudo rm -r -f $repositoryName ; }; fi #sudo command only on error
      git clone "https://github.com/$githubUserName/$repositoryName" || { echo "Couldn't download latest version" ; exit 1; }
      cd $repositoryName ||  { echo 'Update Failed' ; exit 1 ;}
      git checkout "v$latestVersion" 2> /dev/null || git checkout "$latestVersion" 2> /dev/null || echo "Couldn't git checkout to stable release, updating to latest commit."
      #chmod a+x install.sh #this might be necessary in your case but wasnt in mine.
      "./$nameOfInstallFile"
      cd ..
      rm -r -f $repositoryName || sudo rm -r -f $repositoryName #sudo command only on error
    else
      exit 1
    fi
  else
    echo "$repositoryName is already the latest version"
  fi
fi
