#!/bin/bash

CERTSTOR=/etc/ssl/certs
KEYSTOR=/etc/ssl/private
WORKDIR=/var/lib/lego
CONFDIR=/etc/lego-wrapper.d
DOMDIR=$CONFDIR/domains
CONFFILE="$CONFDIR/lego.conf"
RENEWWINDOW=30
LEGO=`which lego`
TOS="--accept-tos"
EMAIL="user@example.com"

TESTSERVER="--server=https://acme-staging.api.letsencrypt.org/directory"
usage() {

cat << EOF

usage: $0 [-rci] 

  -r: perform a renew of all renewable certificates
  -c: create any configured certificate that does not exist yet
  -i: copy created/renewed certificates from lego's working directory to certstore and keystore respectively

When no parameter is specified, performs a check of creatablilty or renewability.

EOF

}

renew() {
	exp=$(date +%s -d "`openssl x509 -enddate -noout -in $WORKDIR/certificates/${domains[0]}.crt |cut -d'=' -f2`")
	now=$(date +%s)

	renewtime=$(( $exp - $now - $RENEWWINDOW*24*3600 ))

	unset d
	for i in "${domains[@]}"; do
		d="$d -d $i";
	done

	if [ $renewtime -le 0 ]; then 
        	if [ x$renew == "xtrue" ]; then
			echo "Renewing"; 
			$LEGO $TESTSERVER $TOS $d --email $EMAIL --path $WORKDIR renew
		else
			echo "${domains[0]} eligible for renewal for ${renewtime#-} seconds, but renewal not requested"
		fi
	else
		echo "${domains[0]} not eliglible for renewal yet, ${renewtime#-} seconds until in renewing window";
	fi
}

create() {
	unset d
	for i in "${domains[@]}"; do
		d="$d -d $i";
	done

       	if [ x$create == "xtrue" ]; then
		echo "Creating new single certificate for ${domains[*]}..."
		$LEGO $TESTSERVER $TOS $d --email $EMAIL --path $WORKDIR run
	else
		echo "no certificate for ${domains[0]} found but creation not requested"
	fi
}

doinstall() {
	echo "Installing certificate files for ${domains[0]}..."
	cp $WORKDIR/certificates/${domains[0]}.crt $CERTSTOR
	install -m 0400 $WORKDIR/certificates/${domains[0]}.key $KEYSTOR
}

while getopts rc o; do
        case $o in
                "r") renew=true;;
                "c") create=true;;
                "i") doinst=true;;
                "?") err "Unknown option: $OPTARG"; usage 1;;
esac
done


[ -r "$CONFFILE" ] && . $CONFFILE


for domfile in $DOMDIR/*; do
	if [ ! -e $domfile ]; then 
		echo "Nothing to do, $DOMDIR is empty or missing, exitting..."
		exit 0
	fi

	echo Checking file $domfile...
	unset domains
	declare -a domains
	while read domain; do
	if grep -q '^[-a-zA-Z0-9][-a-zA-Z0-9\.]\{0,62\}[-a-zA-Z0-9]$' <<< $domain; then
		domains[${#domains[@]}]=$domain;
	else
		echo "ERROR: Invalid domain name: '$domain' in $domfile";
		usage
		exit 1
	fi	
	done < $domfile
	
	if [ -f $WORKDIR/certificates/${domains[0]}.crt -a -f $WORKDIR/certificates/${domains[0]}.key ]; then
		renew
	fi

	if [ ! -f $WORKDIR/certificates/${domains[0]}.crt -a ! -f $WORKDIR/certificates/${domains[0]}.key ]; then
		create
	fi

        if [ x$doinst == "xtrue" ]; then
		doinstall
	fi

done
