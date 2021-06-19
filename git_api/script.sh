#!/bin/bash

# check argument
if [ -z "$1" ]; then
  echo "error: pls enter the address."
  exit 1
fi

# Get the user and repo
userrepo=$(echo $1 | awk -F'.com/' '{print $2}') # "$user/$repo"
user=$(echo $userrepo | awk -F'/' '{print $1}') # "$user"
repo=$(echo $userrepo | awk -F'/' '{print $2}') # "$repo"

echo "[+]Username and repo name:"
echo "User = $user"
echo "Repo = $repo"
echo ""
echo -ne "[+]Checking PR is started\r"
echo ""
echo -ne "[|]Checking PR....(10%) \r"

query="https://api.github.com/repos/"$userrepo"/pulls?per_page=1000&state=open"
echo -ne "[/]Checking PR...(20%) \r"


query=$(curl $query 2> /dev/null)
lock=$? # check if curl passed or not (returning 0 means yes)

#------\/Catch curl error\/------
if [[ "$lock" -ne 0 ]]
then
  echo "error: trouble in curl command."
  exit 1
fi
#------/\Cath curl error/\------
echo -ne "[—]Checking PR...(40%) \r"


# parse the curl output
contributors=$(jq '.[].user.login' <<< $query)
lock=$? # check if jq passed or not
echo -ne "[\]Checking PR...(60%) \r"

#------\/Cath jq error\/------
if [[ "$lock" -ne 0 ]]
then
  echo "error: trouble in jq command."
  exit 1
fi
#------/\Catch jq error/\------
echo -ne "[|]Checking PR...(80%) \r"


echo "[+]Checking PR is done"

if [[ $contributors == "null" || $contributors == "" ]]; then
  echo "Open pull requests is absent"
else
  echo "Open pull requests is present"
fi
echo ""
echo -ne "[+]Computing PR count is started \r"
echo ""
echo -ne "[|]Computing PR count...(10%) \r"


# Counting pull requests for the contributors
s_contributors=$(sort <<< "$contributors")
echo -ne "[/]Computing PR count...(30%) \r"

u_contributors=$(uniq -c <<< "$s_contributors")
echo -ne "[—]Computing PR count...(50%) \r"

# Get the contributers names
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
echo -ne "[\]Computing PR count...(60%) \r"

echo ""
rabotyagi="${rabotyagi//'"'}" # remove "" from names
echo -ne "[|]Computing PR count...(80%) \r"
echo ""
echo "[+]Computing PR count is done"
echo ""
echo "Contributors with more than one pull request:"
echo "-----------------"
echo "Count|Contributor"
echo "-----------------"
echo "$rabotyagi" | sed G | sed -e 's/^$/----------------/' | sed 's/ /    |/g'


echo ""
tags=$(jq '.[].labels[0].name' <<< $query 2> /dev/null) # get labels
lock=$?

#------\/Catch jq error\/------
if [[ "$lock" -ne 0 ]]
then
  echo "Script aborted! Error in jq command with Names."
  exit 1
fi
#------/\Cath jq error/\------


# changing IFS value for successful converting "tags" var to array
# and use new value for output in future

ifs_backup=$IFS
IFS=$'\n'
cnt_arr=($contributors)
lbl_arr=($tags)
#IFS=$ifs_backup


#lf=$'\n'

for i in $(seq 0 ${#cnt_arr[@]})
do
    # checking if PR contains a label
    if [[ ${lbl_arr[$i]} != "null" && ${lbl_arr[$i]} != "" ]];
    then
        if [[ $dude_with_labeled_PR == "" ]];
        then
            dude_with_labeled_PR=${cnt_arr[$i]}
        else
            dude_with_labeled_PR=${dude_with_labeled_PR}${IFS}${cnt_arr[$i]}
        fi
    fi
done
#echo $dude_with_labeled_PR
IFS=$ifs_backup
echo "Contributors with labeled pull requests:"
echo "-----------------"
echo "Count|Contributor"
echo "-----------------"
dude_with_labeled_PR="${dude_with_labeled_PR//'"'}"
echo "$dude_with_labeled_PR" | sort | uniq -c | awk '{print $1,$2}' | sed G | sed -e 's/^$/----------------/' | sed 's/ /    |/g'
