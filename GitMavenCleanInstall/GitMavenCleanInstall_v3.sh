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
# 19 Nov 18 - Changed how to get current branch name
#             Rename Variables
#             Removed function check, replaced with previous value check.
################################################################################

#!/bin/bash
#Navigate to the POM Project
cd PATH/TO/POM/PROJECT
#Remote update
git remote update -p
#Pull
git pull

#Get the current working branch
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
#Get the output of the command git diff
GIT_DIFF_OUTPUT="$(git diff --name-only HEAD@{1} ${CURRENT_BRANCH})"
#Split the diff output into an array
readarray -t GIT_DIFF_OUTPUT_ARY << "$GIT_DIFF_OUTPUT"
decalre -a GIT_DIFF_OUTPUT_ARY_ROOT_PATH=()
PATH_SEPERATOR='/'
PREVIOUS_PATH=''
#Loop the diff output array
for file_path in "${GIT_DIFF_OUTPUT_ARY[@]}"
do
  #Split the file by /
  IFS='/' read -ra SPLIT_PATH <<< "$file_path"
  #Concatenate the first project + / + second project
  root_path="${SPLIT_PATH[0]}${PATH_SEPERATOR}${SPLIT_PATH[1]}"
  #Check if the current path is not equal to the previous path
  if [[ "$root_path" != "$PREVIOUS_PATH" ]]
  then
    #Set the output array root path to have path
    GIT_DIFF_OUTPUT_ARY_ROOT_PATH+=("$root_path")
    #Set previous path to current path
    PREVIOUS_PATH="$root_path"
  fi
done

#Loop the root paths
for path in "${GIT_DIFF_OUTPUT_ARY_ROOT_PATH[@]}"
do
  #CD into path
  cd "$path"
  #Maven clean install
  mvn -DskipTests=true --errors -T 8 -e
  #CD back up before next project
  cd ../../
done
