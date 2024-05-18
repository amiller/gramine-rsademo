
## Motivating application: trusted setup for RSA accumulators

Let's generate an RSA modulus and throw it away.

This is basically the trusted setup for Zerocoin if you want to read about it.

## Notes on the environment
- Dockerfile: based on the gramine image 1.5
- docker-compose.yml: for SGX only. This shows how to pass in /dev/sgx_enclave, /dev/sgx_provision, and the aesmd service socket for remote attestation.
- Uses python, the python3.8 that comes with the gramine image

## To do the build and print the MRENCLAVE

```shell
docker build -t gramine .
docker exec --rm gramine 
```

## To deploy on SGX
You must have already set up the SGX driver and AESM service and all the DCAP packages, in the host outside the docker container.

To run in gramine:
```shell
docker compose build
docker compose run gramine
```


