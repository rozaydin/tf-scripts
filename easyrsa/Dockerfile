FROM alpine/openssl

RUN apk update && apk add bash && apk add git
RUN git clone https://github.com/OpenVPN/easy-rsa.git

WORKDIR /easy-rsa/easyrsa3
RUN ./easyrsa init-pki
COPY vars ./pki

COPY generate-keys.sh /
RUN ["chmod", "+x", "/generate-keys.sh"]

# RUN ./easyrsa build-ca nopass
# RUN ./easyrsa build-server-full server nopass
# RUN ./easyrsa build-client-full client1.domain.tld nopass

# RUN mkdir /vpn_keys
# RUN cp pki/ca.crt /vpn_keys
# RUN cp pki/issued/server.crt /vpn_keys
# RUN cp pki/private/server.key /vpn_keys
# RUN cp pki/issued/client1.domain.tld.crt /vpn_keys
# RUN cp pki/private/client1.domain.tld.key /vpn_keys

# WORKDIR /vpn_keys
ENTRYPOINT [ "bash", "-c", "/generate-keys.sh" ]