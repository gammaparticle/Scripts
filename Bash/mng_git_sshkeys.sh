#!/bin/bash
###
###
###
### Purpose: Add Github SSH Key for given ID to ssh-agent.
### Started: 2020/06/06 (fynn)
###
### ######################################################

invoked=$_
OPTIND=1


## Environment Variables
export SSH_ENV="${HOME}/.ssh/environment"


## Variables
KILL="/bin/kill"
SSH="/usr/bin/ssh"
SSH_AGENT="/usr/bin/ssh-agent"
SSH_ADD="/usr/bin/ssh-add"
SSH_AGENT_PID=$(ps -C ssh-agent -o pid= | sed 's/^ *//g')
SSH_KEY_ID_1="${HOME}/.ssh/id_rsa"
SSH_KEY_ID_2="${HOME}/.ssh/id_rsa_fynn"
SSH_KEY_ID_3="${HOME}/.ssh/id_rsa_gitlab"
SSH_KEY_ID_4="${HOME}/.ssh/id_rsa_gitlab_fynn"
NUMARGS=${#}
SCRIPT=`basename ${BASH_SOURCE[0]}`


## Functions
function show_usage {
    echo "Usage: . ./${SCRIPT} [-h] [-s] [-a] [-k] "
    echo "  ${SCRIPT} -h    Display this help message."
    echo "  ${SCRIPT} -s    Start ssh-agent."
    echo "  ${SCRIPT} -a    Add all ssh keys for GitHub accounts."
    echo "  ${SCRIPT} -k    Kill ssh-agent."
}

function add_ssh_key_1 {
    echo "Adding ssh key (1)..."
    ${SSH_ADD} ${SSH_KEY_ID_1}
    echo "Testing github.com ssh connection..."
    ${SSH} -T git@github.com
}

function add_ssh_key_2 {
    echo "Adding ssh key (2)..."
    ${SSH_ADD} ${SSH_KEY_ID_2}
    echo "Testing github.com-fynn ssh connection..."
    ${SSH} -T git@github.com-fynn
}

function add_ssh_key_3 {
    echo "Adding ssh key (3)..."
    ${SSH_ADD} ${SSH_KEY_ID_3}
}

function add_ssh_key_4 {
    echo "Adding ssh key (4)..."
    ${SSH_ADD} ${SSH_KEY_ID_4}
}

function add_ssh_keys {
    if [ -z ${SSH_AGENT_PID} ]; then
        echo "SSH Agent is not running. Unable to add ssh keys."
    else
        add_ssh_key_1
        add_ssh_key_2
        add_ssh_key_3
        add_ssh_key_4
    fi
}

function start_ssh_agent {
    if [ -z ${SSH_AGENT_PID} ]; then
        echo "Starting ssh-agent..."
        ${SSH_AGENT} | sed 's/^echo/#echo/' > "${SSH_ENV}"
        
        if [ -f ${SSH_ENV} ]; then
            chmod 600 "${SSH_ENV}"
            . "${SSH_ENV}" > /dev/null
            echo "File ${SSH_ENV} sourced."
        else 
            echo "File ${SSH_ENV} does not exist."
        fi

    else
        echo "ssh-agent already running..."
        . "${SSH_ENV}" > /dev/null
    fi 
}

function kill_ssh_agent {
    if [ -z ${SSH_AGENT_PID} ]; then
        echo "SSH agent is not running."
        if [[ ${invoked} != $0 ]]; then
            return 1
        else
            exit 1
        fi
    else
        ${KILL} ${SSH_AGENT_PID}
        echo "SSH agent has been killed." 
    fi

    unset SSH_AGENT_PID
    unset SSH_AUTH_SOCK
    unset SSH_ENV
}


## Main

if [ $NUMARGS -eq 0 ]; then
    show_usage 
fi

# Parse command line flags
while getopts ":hsatk" opt; do
    case ${opt} in
         h) # Show usage
          show_usage
          ;;
         s) # Start ssh agent
          start_ssh_agent
          ;;
         a) # Add ssh keys
          add_ssh_keys
          ;;
         k) # Kill ssh agent
          kill_ssh_agent
          ;;
        \?) # unknown option
          show_usage
          ;;
    esac
done
