#!/bin/bash

# Check if there no argument
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

# Try to get json from git api
query="https://api.github.com/repos/"$userrepo"/pulls?state=open"

#stderr to abyss...
query=$(curl $query 2> /dev/null)
#check of curl passed or not (returning 0 means yes)
lock=$?
# Catch error
if [[ "$lock" -ne 0 ]]
then
  echo "error: trouble in curl command."
  exit 1
fi

# Parse the Curl output
contributors=$(jq '.[].user.login' <<< $query)
lock=$?
# Catch error
if [[ "$lock" -ne 0 ]]
then
  echo "error: trouble in jq command."
  exit 1
fi

if [[ $contributors == "null" || $contributors == "" ]]; then
  echo "Open pull requests is absent"
  exit 1
else
  echo "Open pull requests is present"
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
  Liders=$(awk "{if ( \$1>1 ) {print \$1,\$2}}" <<< "$contributor")
done

echo ""
#remove "" from names
Liders="${Liders//'"'}"
echo "$Liders"
echo ""
