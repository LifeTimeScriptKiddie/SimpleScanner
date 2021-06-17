#!/bin/bash

IP_addresses=(
# 'IP 1 here'
# 'IP 2 here'
# 'IP 3 here'
# 'IP 4 here'
)
####################
###Create Folders###
####################
for ip in "${IP_addresses[@]}"
do
 echo " ############### Creating directories  #####################"
 mkdir -p ./$ip/recon
 echo "############### Directories are created ####################"
done



####################
##### Nmap Scan#####
####################

for ip in "${IP_addresses[@]}"
do 
 echo "################# Starting nmap scan on $ip#######################"
 nmap -sC -sV -p- -Pn -O -A -oN ./$ip/recon/nmap_full $ip
 echo "################### $ip nmap scan is done ########################"
done


####################
##### gobuster #####
####################



for ip in "${IP_addresses[@]}"
do
  cat ./$ip/recon/nmap_full |grep -E "http|https|ssl/http" |grep tcp|awk -F "/" '{print$1}' | while IFS= read -r port;
  do 
  echo "############### Running GOBUSTER on http://$ip:$port #########################"  
  gobuster dir -u http://$ip:$port -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt  -e -k |tee ./$ip/recon/$port.gobuster;
  
  sleep 5;
  
  echo "################## Running FFUF on http://$ip:$port ######################"
  ffuf -u http://$ip:$port/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt |tee ./$ip/recon/$port.ffuf


  echo "#################  Running NIKTO on http://$ip:$port  #######################"
  nikto -h http://$ip:$port |tee ./$ip/recon/$port.nikto

  done 
done
  

