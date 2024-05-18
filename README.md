# Demonstration of a gramine enclave

Let's try to finish a meaningful end-to-end example of using SGX to do something useful we couldn't do without it.

## Motivating application: trusted setup for RSA accumulators

Let's generate an RSA modulus and throw away the prime factors.

An RSA modulus is a number `N` that's the product of two primes `p` and `q`. Often the security relies on not knowing p or q.

This is basically the trusted setup for Zerocoin if you want to read about it.

## Notes on the environment
- Dockerfile: based on the gramine image 1.5
- docker-compose.yml: for SGX only. This shows how to pass in /dev/sgx_enclave, /dev/sgx_provision, and the aesmd service socket for remote attestation.
- Uses python, the python3.8 that comes with the gramine image

## Building

To do the build and print the MRENCLAVE:

```shell
docker build -t gramine .
docker run --rm gramine
```

The reference MRENCLAVE for this release is `f9841922b84a3bc60f9687bca1a596e42b4e7c6372b5d5f3a92dc1e52075647b`

You can also just run `make` in this directory if you have gramine installed.

## To run the enclave on SGX
You must have already set up the SGX driver and AESM service and all the DCAP packages, in the host outside the docker container. See the DCAP installation instructions from [Gramine.](https://gramine.readthedocs.io/en/stable/devel/building.html#install-dependencies-for-dcap)

To run the enclave in gramine:
```shell
docker compose run --rm gramine gramine-sgx python
```
