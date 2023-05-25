#!/bin/bash

docker build . -t easyrsa
docker run --rm -it -v./keys:/vpn_keys --name easyrsa easyrsa

#aws acm import-certificate --certificate fileb://keys/server.crt --private-key fileb://keys/server.key --certificate-chain fileb://keys/ca.crt --profile rozaydin --region eu-central-1
 ## aws acm delete-certificate --certificate-arn arn:aws:acm:eu-central-1:221148627084:certificate/a01365a7-2ca1-4d0a-a87f-6c397d4cb78f --profile rozaydin --region eu-central-1
#aws acm import-certificate --certificate fileb://keys/client1.domain.tld.crt --private-key fileb://keys/client1.domain.tld.key --certificate-chain fileb://keys/ca.crt --profile rozaydin --region eu-central-1