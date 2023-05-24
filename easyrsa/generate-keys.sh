#!/bin/bash

# https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/mutual.html

/easy-rsa/easyrsa3/easyrsa build-ca nopass
/easy-rsa/easyrsa3/easyrsa build-server-full server nopass
/easy-rsa/easyrsa3/easyrsa build-client-full client1.domain.tld nopass

mkdir -p /vpn_keys
cp /easy-rsa/easyrsa3/pki/ca.crt /vpn_keys
cp /easy-rsa/easyrsa3/pki/issued/server.crt /vpn_keys
cp /easy-rsa/easyrsa3/pki/private/server.key /vpn_keys
cp /easy-rsa/easyrsa3/pki/issued/client1.domain.tld.crt /vpn_keys
cp /easy-rsa/easyrsa3/pki/private/client1.domain.tld.key /vpn_keys

# docker build . -t easyrsa && docker run --rm -d --name easyrsa easyrsa

# docker cp easyrsa:/vpn_keys/ca.crt ./keys/ca.crt
# docker cp easyrsa:/vpn_keys/server.crt ./keys/server.crt
# docker cp easyrsa:/vpn_keys/server.key ./keys/server.key
# docker cp easyrsa:/vpn_keys/client1.domain.tld.crt ./keys/client1.domain.tld.crt
# docker cp easyrsa:/vpn_keys/client1.domain.tld.key ./keys/client1.domain.tld.key

# docker stop easyrsa