#!/bin/bash

# check argument
if [ -z "$1" ]; then
  echo "error: pls enter the address."
  exit 1
fi

# Get the user and repo
userrepo=$(echo $1 | awk -F'com/' '{print $2}') # "$user/$repo"
user=$(echo $userrepo | awk -F'/' '{print $1}') # "$user"
repo=$(echo $userrepo | awk -F'/' '{print $2}') # "$repo"

echo "Username and repo name:"
echo "User = $user"
echo "Repo = $repo"


declare -A pages
pages[1]=$(curl https://api.github.com/repos/"$userrepo"/pulls?page=1\&state=open 2>/dev/null)
lock=$? # check if curl passed or not (returning 0 means yes)

#------Catch curl error------
if [[ "$lock" -ne 0 ]]
then
  echo "error: trouble in curl command."
  exit 1
fi
#------Cath curl error------

flag=true
while [ "$flag" = true ]
do
  echo ${#pages[@]}
  page=2
  temp_curl=$(curl https://api.github.com/repos/"$userrepo"/pulls?page="$page"\&state=open 2>/dev/null)
  if [[ $temp_curl == "null" || $temp_curl == "" ]]; then
    flag=false
  else
    pages[$page]=$temp_curl
    page=$[$page+1]
    echo ${#pages[@]}
  fi
done



# parse the curl output
contributors=$(jq '.[].user.login' <<< $pages)
lock=$? # check if jq passed or not

#------Catch jq error------
if [[ "$lock" -ne 0 ]]
then
  echo "error: trouble in jq command."
  exit 1
fi
#------Catch jq error------


if [[ $contributors == "null" || $contributors == "" ]]; then
  echo "Open pull requests is absent"
  exit 1
fi
echo""


# Counting pull requests for the contributors
s_contributors=$(sort <<< "$contributors")
u_contributors=$(uniq -c <<< "$s_contributors")

# Get the contributers names
echo "Contributors with more than one pull request:"
# u_contributors is like:
# <count> <name>
#  ...     ...
#  ...     ...
# <count> <name>
for contributor in "$u_contributors"
do
  #if <count> more than 1 then get this dude
  rabotyagi=$(awk "{if ( \$1>1 ) {print \$1,\$2}}" <<< "$contributor")
done

echo ""
rabotyagi="${rabotyagi//'"'}" # remove "" from names
echo "$rabotyagi"
echo ""





tags=$(jq '.[].labels[0].name' <<< $query 2> /dev/null) # get labels
lock=$?

#------Catch jq error------
if [[ "$lock" -ne 0 ]]
then
  echo "Script aborted! Error in jq command with Names."
  exit 1
fi
#------Cath jq error------

SAVEIFS=$IFS
IFS=$'\n'

cnt_arr=($contributors)
lbl_arr=($tags)
