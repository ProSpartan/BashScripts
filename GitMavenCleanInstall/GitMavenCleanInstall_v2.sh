################################################################################
#
# License:.....GNU General Public License v3.0
# Author:......CodeMonkey
# Date:........14 November 2018
# Title:.......GitMavenCleanInstall.sh
# Description: This script is designed to cd to a set Maven POM Project,
#   perform a git remote update and pull, and clean install the changed
#   files projects.
# Notice:......The project structure this script was originally set to target
#   is structured as a Maven POM Project that contains several sub-POM Projects.
#   The sub-POM Projects contain Maven Java Application projects. The targets
#   should be easy to change, and allow for others to target other structures.
#
################################################################################
#
# Change History:
# 19 Nov 18 - Change diff output to be --name-only from --name-status
#             Removed if check on single character, since the diff output
#               is now file paths only.
#
################################################################################

#!/bin/bash
#Function to check if array has element
containsElement () {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}

#Navigate to the POM Project
cd PATH/TO/POM/PROJECT
#Remote update
git remote update -p
#Pull
git pull

#Get the current working branch
CURRENT_BRANCH="$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')"
#Get the output of the command git diff
GIT_DIFF_OUTPUT="$(git diff --name-only HEAD@{1} ${CURRENT_BRANCH})"

#Split the diff output into an array
read -a GIT_DIFF_OUTPUT_ARY <<< $GIT_DIFF_OUTPUT
#Declare empty array for root path
declare -a GIT_DIFF_OUTPUT_ARY_ROOT_PATH=()
FORWARD='/'
#Loop diff output array
for i in "${GIT_DIFF_OUTPUT_ARY[@]}"
do
    #Split the file path by /
    IFS='/' read -ra SPLIT <<< $i
    #Concatenate first path + / + second path
    path=${SPLIT[0]}$FORWARD${SPLIT[1]}
    #Call function to see if it already exists in the root path array
    containsElement "$path" "${GIT_DIFF_OUTPUT_ARY_ROOT_PATH[@]}"
    if [[ $? != 0 ]]
    then
        #Add the path since it was not found
        GIT_DIFF_OUTPUT_ARY_ROOT_PATH+=($path)
    fi
done

#Loop root path array
for val in ${GIT_DIFF_OUTPUT_ARY_ROOT_PATH[@]}
do
    #CD into root path
    cd $val
    #Maven call to clean install
    mvn -DskipTests=true --errors -T 8 -e clean install
    #CD back up before next project
    cd ../../
done
