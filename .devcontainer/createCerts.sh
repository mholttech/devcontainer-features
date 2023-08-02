#!/bin/bash

output=$(echo "QUIT" | openssl s_client -showcerts -servername "google.com" -connect "google.com":443 2>&1)
openssl_cnf_path="/etc/ssl/openssl.cnf"

# Check if 'unsafe legacy renegotiation' is supported
if echo "$output" | grep -q "unsafe legacy renegotiation"; then
    # Check and insert options in openssl.cnf if necessary
    echo "Ensuring UnsafeLegacyRenegotiation SSL option is enabled..."

    declare -A options
    options=(["openssl_init"]="ssl_conf = ssl_sect" ["ssl_sect"]="system_default = system_default_sect" ["system_default_sect"]="Options = UnsafeLegacyRenegotiation")

    for category in "${!options[@]}"; do
        if grep -q "^\[$category\]" $openssl_cnf_path; then
            if ! grep -q "^${options[$category]}" $openssl_cnf_path; then
                sudo sed -i "/^\[$category\]/a\\${options[$category]}" $openssl_cnf_path
            fi
        else
            echo "[$category]" | sudo tee -a $openssl_cnf_path
            echo "${options[$category]}" | sudo tee -a $openssl_cnf_path
        fi
    done
else
    echo "Unsafe legacy renegotiation ia already enabled already. Skipping..."
fi

sudo openssl s_client -showcerts -verify 5 -connect wikipedia.org:443 < /dev/null | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; out="cert"a".crt"; print >out}'; echo "Certificates:"; for cert in *.crt; do newname=$(openssl x509 -noout -subject -in $cert | sed -nE 's/.*CN ?= ?(.*)/\1/; s/[ ,.*]/_/g; s/__/_/g; s/_-_/-/; s/^_//g;p' | tr '[:upper:]' '[:lower:]').crt; echo "${newname}"; mv "${cert}" "/usr/local/share/ca-certificates/${newname}"; done
sudo rm /usr/local/share/ca-certificates/wikipedia_org.crt
sudo update-ca-certificates