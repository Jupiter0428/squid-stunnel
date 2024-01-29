#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "Please use user root to run this script."
    exit 1
fi

function install_squid(){
    if yum -y install squid > /dev/null 2>&1; then
        echo "Squid installation successful."
    else
        echo "Squid installation failed."
        exit 1
    fi
    squid_conf_url="https://raw.githubusercontent.com/Jupiter0428/squid-stunnel/master/squid/squid.conf"
    wget -q --no-check-certificate "${squid_conf_url}" -O /etc/squid/squid.conf
    systemctl start squid
    systemctl enable squid > /dev/null 2>&1
}

function install_openssl(){
    if yum -y install openssl > /dev/null 2>&1; then
        echo "Openssl installation successful."
    else
        echo "Openssl installation failed."
    fi
    openssl_conf_url="https://raw.githubusercontent.com/Jupiter0428/squid-stunnel/master/openssl/openssl.conf"
    wget -q --no-check-certificate "${openssl_conf_url}" -O /etc/stunnel/openssl.conf
    ## The 'stunnel.pem' file generated here needs to be distributed to the client
    # openssl req -new -x509 -days 365 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -config /etc/stunnel/openssl.conf
    stunnel_cert_url="https://raw.githubusercontent.com/Jupiter0428/squid-stunnel/master/stunnel/stunnel.pem"
    wget -q --no-check-certificate "${stunnel_cert_url}" -O /etc/stunnel/stunnel.pem
}

function install_httpd(){
    if yum -y install httpd > /dev/null 2>&1; then
        echo "Httpd installation successful."
    else
        echo "Httpd installation failed."
    fi
    ## Create a password for Squid
    # htpasswd -cd /etc/squid/htpasswd ${user}
    ## Verify whether the account password is available
    # /usr/lib64/squid/basic_ncsa_auth /etc/squid/htpasswd
}

function install_stunnel(){
    if yum -y install stunnel > /dev/null 2>&1; then
        echo "Stunnel installation successful."
    else
        echo "Stunnel installation failed."
        exit 1
    fi
}

function stunnel_server(){
    stunnel_server_conf_url="https://raw.githubusercontent.com/Jupiter0428/squid-stunnel/master/stunnel/server/stunnel.conf"
    wget -q --no-check-certificate "${stunnel_server_conf_url}" -O /etc/stunnel/stunnel.conf
}

function stunnel_client(){
    stunnel_client_conf_url="https://raw.githubusercontent.com/Jupiter0428/squid-stunnel/master/stunnel/client/stunnel.conf"
    wget -q --no-check-certificate "${stunnel_client_conf_url}" -O /etc/stunnel/stunnel.conf
    # You need to modify the IP information in the configuration file

}

function stunnel_service(){
    stunnel_service_url="https://raw.githubusercontent.com/Jupiter0428/squid-stunnel/master/stunnel/stunnel.service"
    wget -q --no-check-certificate "${stunnel_service_url}" -O /usr/lib/systemd/system/stunnel.service
    systemctl daemon-reload
    systemctl start stunnel
    systemctl enable stunnel > /dev/null 2>&1
}

function main(){
    case $1 in
        "server")
            install_squid
            install_openssl
            install_httpd
            install_stunnel
            stunnel_server
            stunnel_service
        ;;
        "client")
            install_stunnel
            stunnel_client
            stunnel_service
        ;;
        *)
            echo "Please enter parameters."
        ;;
    esac
}

main "$@"