#!/bin/bash
opt=`getopt -q adhs:p: $@`
opt=${opt//\'/}
set -- $opt

flag_add=0
flag_del=0
flag_pass="redhat"
flag_shell="/bin/bash"

# 当把所有参数弹出后结束
until [[ $# -eq 0 ]]; do
    case $1 in
        -a)
            flag_add=1
        ;;
        -d)
            flag_del=1
        ;;
        -s)
            flag_shell=$2
            shift
        ;;
        -h)
            echo "Description: this script is use to manage user"
            echo -e "-a\t\tcreate the user"
            echo -e "-d\t\tdelete the user"
            echo -e "-p PASSWORD\tset the password of user"
            echo -e "-m\t\tset password to default [redhat]"
            echo -e "-h\t\tget help"
        ;;
        -p)
            flag_pass=$2
            shift
        ;;
        --)
            shift
            break
        ;;
        *)
            echo "Error: please enter -h get help"
            exit 1
        ;;
    esac

shift
done

# create the user
if [[ flag_add -eq 1 ]]; then
    while read line; do
        id $line > /dev/null 2>&1
        # user exist
        if [[ $? -eq 0 ]];then
            echo "user $line exist"
        else
        # user not exist.useradd
            useradd -s $flag_shell $line
            echo "$flag_pass" | passwd --stdin $line > /dev/null 2>&1
            echo "user $line added"
        fi
    done < $1
fi

# delete the user
if [[ $flag_del -eq 1 ]]; then
    id $line > /dev/null 2>&1
    while read line; do
        # user exist.userdel
        if [[ $? -eq 0 ]];then
            userdel -r $line
            echo "user $line delete"
        # user not exist
        else
            echo "user $line not exist"
        fi
    done < $1
fi