# Netstat/ss script

We need to present the following one-line in the form of a script.
```sh
sudo netstat -tunapl | awk '/firefox/ {print $5}' | cut -d: -f1 | sort | uniq -c | sort | tail -n5 | grep -oP '(\d+\.){3}\d+' | while read IP ; do whois $IP | awk -F':' '/^Organization/ {print $2}' ; done
```

## What this one-line does.

1. `netstat` - is a command-line utility for working with the network, for displaying various network parameters depending on the specified options.  
   `-t` or `--tcp` - show tcp ports  
   `-u` or `--udp` - show udp ports  
   `-n` Show network addresses as numbers. Show ports as number, not letters. (443 - https, etc.)  
   `-a` Shows the status of all sockets; normally, sockets used by server processes are not shown.  
   `-p` Display the PID/Name of the process that created the socket.  
   `-l` or `--listening` - view only the listening ports.  
2. `awk '/firefox/ {print $5}'`in the output of the netstat command, we look for lines containing `firefox` and output the fifth column (ip+port)  
3. `cut -d: -f1` we cut the ports, leaving only IP  
4. `sort` sort (by the first character in the string)  
5. `uniq -c` looking for repeats of IP addresses and output the number of these repeats
6. `sort` sort again
7. `tail -n5` show last five IP addresses
8. `grep -oP '(\d+\.){3}\d+'` output only IP (one or more decimal numbers with a dot three times and the last octet of IP)
9. We send the result to the `while`  loop in which we run all the IP addresses through the whois command. Using `awk`,
   we search for lines with `Organization:` and deduce the fact that after the `:` (name of the organization)

***

## My script
Why do we need a script only for ' firefox` let's specify the connections of which applications we are interested in.
1. Iteratively enter the parameters that the script requires
2. Check whether the variable was passed or not.
3. If not, we display a message asking you to specify a variable.
4. If yes, then we execute our script gradually.
5. We save the intermediate results in vars
6. If there are connections, run them through the loop and make a selection by your field parameter
8. Show this information.

***
## Example
# With netstat:
```sh
sudo ./script
Enter tool (netstat or ss): netstat
Enter process name/PID: firefox
Enter connection state: estab
Enter number of lines: 10
Enter field: City
CONNECTIONS:
1  140.82.112.25:443   ESTABLISHED  7133/firefox
1  35.244.247.133:443  ESTABLISHED  7133/firefox
1  52.41.2.143:443     ESTABLISHED  7133/firefox

WHOIS:
140.82.112.25 	 San Francisco
35.244.247.133 	 Mountain View
52.41.2.143 	 Seattle
```
# With ss
```sh
sudo ./script
Enter tool (netstat or ss): ss
Enter process name/PID: firefox
Enter connection state: estab
Enter number of lines: 5
Enter field: Organization
CONNECTIONS:
1  140.82.112.25:443  ESTAB  users:(("firefox",pid=7133,fd=66))
1  52.41.2.143:443    ESTAB  users:(("firefox",pid=7133,fd=77))

WHOIS:
140.82.112.25 	 GitHub, Inc. (GITHU)
52.41.2.143 	 Amazon Technologies Inc. (AT-88-Z)
```
