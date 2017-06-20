#!/bin/bash
# Author: Alexander Epstein https://github.com/alexanderepstein
# Update utility version 1.0.2

currentVersion="" #make sure this is the name you give to the tag for the github release. Also make sure to start each realease tag with v as this is an assumption made by the script but do not give this variable a v.Ex variable set to 1.5.0 github release tag is v1.5.0
repositoryName=""
githubUserName=""
versionReleaseLen=$(echo ${#currentVersion})
versionReleaseLen=$((10 + $versionReleaseLen))



if [[ $currentVersion == "" || $repositoryName == "" || $githubUserName == "" ]];then
  echo "Error: update utility has not been configured correctly." >&2
  exit 1

elif [[ $(curl -s https://api.github.com/repos/$githubUserName/$repositoryName/tags) == "" ]];then
   echo "Error: no active internet connection" >&2
   exit 1
else
 latestVersion=$(curl -s https://api.github.com/repos/$githubUserName/$repositoryName/tags | grep -Eo '"name":.*?[^\\]",'| head -1 | cut "-c11-$versionReleaseLen") #to grab the v in your updates change -c11 to -c10
 if [[ "$latestVersion" != "$currentVersion"  && "$latestVersion" != "" ]]; then
    echo "Version $latestVersion available"
    echo -n "Do you wish to update $repositoryName [Y/n]: "
    read -r answer
    if [[ "$answer" == "Y" || "$answer" == "y" ]] ;then
        cd  ~ || { echo 'Update Failed' ; exit 1 ; }
        rm -r $repositoryName  2> /dev/null
        git clone "https://github.com/$githubUserName/$repositoryName" || { echo "Couldn't download latest version" ; exit 1; }
        cd $repositoryName ||  { echo 'Update Failed' ; exit 1 ;}
        git checkout "v$latestVersion" 2> /dev/null || git checkout "$latestVersion" 2> /dev/null || echo "Couldn't git checkout to stable release, updating to latest commit."
        #chmod +x install.sh #this might be necessary in your case but wasnt in mine.
        ./install.sh
        cd ..
        rm -r $repositoryName #might need to add sudo to this command depending on type of application
    else
         exit 1
    fi

  else
    echo "$repositoryName is already the latest version"
  fi
fi
