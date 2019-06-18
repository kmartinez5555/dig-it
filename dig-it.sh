#!/bin/bash
#
#
# Author: Kyle Martinez
#
# Created: Oct-25-2017
# Updated: In development (Jun-17-19)
#
#
# Purpose: One stop shop for DNS info


## Variables
domain=$1
## Color variables
OPTS='+short +noshort'
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

  ## Help
get_help () {
  echo -e "
This command is desgined to parse commonly used DNS records and
report them in an easy to view format

Usage: digit [OPTION] [domain]

Options and their usage:
  -b, --basic          Runs only basic DNS checks (A, MX, NS)
  -v, --verbose        Runs a more verbose check of the default values
  -m, --mail           This will check common mail records. Does not
                       DKIM at this time.
  -y, --makeitweird    Checks every type of DNS record I could find that
                       does not require a variable subdomain. May get
                       weirder as I find more.
  -h, --help           Display help messages.

Common issues may occur when trying to use more than 2 variables (flag + domain
+ other). 
Author: Kyle Martinez
Report bugs to: https://github.com/kmartinez5555/dig-it/issues
Current version: 2.0.1
  "
}

  ## Whois summary
initial_whois () {
  echo -e "\nAvailble DNS Info for - ${domain}"
  whois ${domain} | egrep -i 'Registrar\:|Registrar\ URL\: h|name\ server' | sed 's/^[ \t]*//' | sort | uniq -i | sort -r
  echo '-------------------------------------------------------------------'
}

  ## Runs basic dns checks for A MX and NS records
basic_dns () {
  for record in A MX NS
  do
    local _dig=$(dig ${OPTS} ${record} ${domain})
    if [[ -z ${_dig} ]]
    then
        echo -e "  ${RED}No ${record} record Found:${RESET} \n"
    else
        echo -e "  ${GREEN}${record} record:${RESET}"
        echo "${_dig}"
    fi
  done
  unset record _dig
}


  ## Runs more verbose version of basic_dns which includes mail and nameserver resolve checks as well as PTR
verbose_dns () {
  for record in A MX NS
  do
    local _dig=$(dig ${OPTS} ${record} ${domain})
    if [[ -z ${_dig} ]]
    then
        echo -e "  ${RED}No ${record} record Found:${RESET} \n"
    else
        echo -e "  ${GREEN}${record} record:${RESET}"
        echo "${_dig}" 
          ## running case statement to check current record type and perform the resolve test or ptr
        case ${record} in
          A)
            local _ptr=$(for _ptr_output in $(echo "${_dig}" | awk '{print $5}'); do
            dig -x ${_ptr_output} | grep PTR | grep -v ';';done)
            if [[ -z ${_ptr} ]]
            then
                echo -e "  ${RED}No PTR record Found:${RESET} \n"
            else
                echo -e "  ${GREEN}PTR record:${RESET}"
                echo "${_ptr}"
            fi
            ;;

          MX)
            local _mx_ip=$(for _mx_server in $(echo "${_dig}" | awk '{print $6}'); do
            dig ${OPTS} ${_mx_server}; done)
            if [[ -z ${_mx_ip} ]]
            then
                echo -e "  ${RED}Mail server(s) does not resolve${RESET} \n"
            else
                echo -e " ${GREEN}Mail server(s) resolves to:${RESET}"
                echo "${_mx_ip}"
            fi
            ;;

          NS)
            local _ns_resolve=$(for _ns_output in $(echo "${_dig}" | awk '{print $5}'); do
            dig ${OPTS} ${_ns_output};done)
            if [[ -z ${_ns_resolve} ]]
            then
                echo -e "  ${RED}Nameservers do not resolve${RESET} \n"
            else
                echo -e "  ${GREEN}Nameserver resolves to:${RESET}"
                echo "${_ns_resolve}"
            fi
            ;;

        esac
    fi 
  done
}

  ## This is a verbose check that includes mail server resolve test and common mail records. 
  ## DKIM not included at this time due to variance
mail_dns () {
  for record in A MX TXT
  do
    local _dig=$(dig ${OPTS} ${record} ${domain})
    if [[ -z ${_dig} ]]
    then
        echo -e "  ${RED}No ${record} record Found:${RESET} \n"
    else
        echo -e "  ${GREEN}${record} record:${RESET}"
        echo "${_dig}"
        if [[ ${record} == MX ]]
        then
            local _mx_ip=$(for _mx_server in $(echo "${_dig}" | awk '{print $6}');
            do dig ${OPTS} ${_mx_server}; done)
            if [[ -z ${_mx_ip} ]]
            then
                echo -e "  ${RED}Mail server(s) does not resolve${RESET} \n"
            else
                echo -e " ${GREEN}Mail server(s) resolves to:${RESET}"
                echo "${_mx_ip}"
            fi

        fi
    fi
  done
    ## DMARC runs seperate due to subdomain usage
  _dmarc=$(dig ${OPTS} TXT _dmarc.${domain})
    if [[ -z ${_dmarc} ]]
    then
        echo -e "  ${RED}No DMARC record Found:${RESET} \n"
    else
        echo -e "  ${GREEN}DMARC record:${RESET}"
        echo "${_dmarc}"
    fi
}

  ## This is a highly verbose check and is likely not something that is necessarry. 
  ## Includes most records that do not require additional variant subdomains.
DO_IT_ALL_dns () {
  for record in A AAAA MX TXT NS SOA
  do
    local _dig=$(dig ${OPTS} ${record} ${domain})
    if [[ -z ${_dig} ]]
    then
        echo -e "  ${RED}No ${record} record Found:${RESET} \n"
    else
        echo -e "  ${GREEN}${record} record:${RESET}"
        echo "${_dig}"
          ## running case statement to check current record type and perform the resolve test or ptr
        case ${record} in
          A)
            local _ptr=$(for _ptr_output in $(echo "${_dig}" | awk '{print $5}'); do
            dig -x ${_ptr_output} | grep PTR | grep -v ';';done)
            if [[ -z ${_ptr} ]]
            then
                echo -e "  ${RED}No PTR record Found:${RESET} \n"
            else
                echo -e "  ${GREEN}PTR record:${RESET}"
                echo "${_ptr}"
            fi
            ;;
          AAAA)
            local _aaaa_ptr=$(for _ptr_output in $(echo "${_dig}" | awk '{print $5}'); do
            dig -x ${_ptr_output} | grep PTR | grep -v ';';done)
            if [[ -z ${_aaaa_ptr} ]]
              then
                  echo -e "  ${RED}No PTR record Found:${RESET} \n"
              else
                  echo -e "  ${GREEN}PTR record:${RESET}"
                  echo "${_aaaa_ptr}"
            fi
            ;;

          MX)
            local _mx_ip=$(for _mx_server in $(echo "${_dig}" | awk '{print $6}'); do
            dig ${OPTS} ${_mx_server}; done)
            if [[ -z ${_mx_ip} ]]
            then
              echo -e "  ${RED}Mail server(s) does not resolve${RESET} \n"
            else
              echo -e " ${GREEN}Mail server(s) resolves to:${RESET}"
                echo "${_mx_ip}"
            fi
            local _dmarc=$(dig ${OPTS} TXT _dmarc.${domain})
            if [[ -z ${_dmarc} ]]
            then
                echo -e "  ${RED}No DMARC record Found:${RESET} \n"
            else
                echo -e "  ${GREEN}DMARC record:${RESET}"
                echo "${_dmarc}"
            fi
            ;;

          NS)
            local _ns_resolve=$(for _ns_output in $(echo "${_dig}" | awk '{print $5}'); do
            dig ${OPTS} ${_ns_output};done)
            if [[ -z ${_ns_resolve} ]]
            then
                echo -e "  ${RED}Nameservers do not resolve${RESET} \n"
            else
                echo -e "  ${GREEN}Nameserver resolves to:${RESET}"
                echo "${_ns_resolve}"
            fi
            ;;

        esac
    fi
  done
}

  ### This is the acutal execution of the script. This allows for flags to be run and functions to 
  ### be called individually.
if [[ $# == 1 ]] 
then 
  initial_whois
  basic_dns
else
  while [[ $# > 1 ]]
  do
  domain=$2
    case $1 in
      -w)
        initial_whois
        exit 1
        ;;
      -b | --basic)
        basic_dns
        exit 1
        ;;
      -v | --verbose)
        initial_whois
        verbose_dns
        exit 1
        ;;
      -y | --makeitweird)
        DO_IT_ALL_dns
        exit 1
        ;;
      -m | --mail)
        mail_dns
        exit 1
        ;;
      -h | --help)
        get_help
        exit 1
        ;;
      -*)
        echo "Invalid option: ${1}" >&2
        exit 1
        ;;
    esac
  done
#else
#  echo "Please enter a proper domain or option followed by a domain"
fi
