#! /usr/bin/env bash
#
# Overwrite a generated tempest.conf file with standard osic used one
#
# Created because I'm lazy and got tired of copy/pasting values between
# the generated conf and the conf template
# 
# Dan Kolb <dankolbrs@gmail.com>
# March 2017 

function display_help {
	echo "Usage: "
	echo -e "\toverwrite_tempest.sh <GENERATED> <OUTPUT> [-a|--aio]"
	echo ""
	echo "Overwrite generated configuration with OSIC configuration"
	echo ""
	echo -e "\tGENERATED - Tempest generated configuration file"
	echo -e "\tOUTPUT - Tempest config file to write"
	echo -e "\t-a|--aio - specify this is for an all-in-one"
	echo -e "\t\t(currently just removes min_compute_hosts)"
	echo ""
	exit 1
} 

# if there's not the expected parameters
if [[ -z ${1} || -z ${2} ]]
	then
	display_help
fi
if [[ ${1} == "--help" || ${1} == "-h" ]] 
	then
	display_help
fi

# just in case we're going to overwrite existing configuration
if [[ -f etc/tempest.conf ]]
	then
	mv etc/tempest.conf{,.$(date +%s)}
fi
if [[ -f tempest.conf ]]
	then
	mv etc/tempest.conf{,.$(date +%s)}
fi


ORIG=${1}
OUTPUT=${2}
OSIC_TEMPEST="https://raw.githubusercontent.com/osic/qe-jenkins-baremetal/master/jenkins/tempest.conf"
wget ${OSIC_TEMPEST} -O tempest.conf.from_git
keys="admin_password image_ref image_ref_alt uri uri_v3 public_network_id"
for key in $keys
	do
	a="${key} ="
        # overwrite each key in tempest conf to be "key ="
        sed -ri "s|$a.*|$a|g" tempest.conf.from_git
        # get each key from generated tempest conf
        b=$(cat ${ORIG} | grep "$a")
        # overwrite each key from original to downloaded tempest conf
        sed -ri "s|$a|$b|g" tempest.conf.from_git
done
if [[ ${3} == "-a" || ${3} == "--aio" ]]
	then
	sed -i '/min_compute_nodes/d' tempest.conf.from_git
fi

mv tempest.conf.from_git ${OUTPUT}
