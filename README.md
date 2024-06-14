# Learning TEE Security: a TEE-based trusted setup

Let's try to finish a meaningful end-to-end example of using SGX to do something useful we couldn't do without it:
We'll show how to make a TEE-based "trusted setup" for cryptography.

## Motivating example: a trusted setup for RSA 
The simplest example is generating the parameters for an [RSA accumulator.](https://alinush.github.io/2020/11/24/RSA-accumulators.html) If you want more background, you can look at how this is used in [Zerocoin](https://en.wikipedia.org/wiki/Zerocoin_protocol) and [Anoncoin](https://anoncoin.github.io/), but it's not needed for this post.

All you need to know today is this: we need to generate an RSA modulus, that is a number `N` that is the product of two primes `N = pq`, but we also need to prove we've thrown away `p` and `q` and they can never leak.

This problem is called a [trusted setup](https://a16zcrypto.com/posts/article/on-chain-trusted-setup-ceremony/). The elements `p` and `q` are called toxic waste, because the only way to produce the public parameter `N` is to first compute `p` and `q`, but we want to provably dispose of them.

## Solution: Python script in Gramine
What we'll do is this: we'll define a TEE enclave that generates `N` without leaking `p` or `q`, and provides a remote attestation to this effect. If the remote attestation checks out, we have confidence that `N` was generated within a TEE, and can't have leaked, not even to the attacker in the host OS.

- You can look at [rsademo.py](rsademo.py) to see the implementation. The strategy is rejection sampling and probabilistic primality checking. For sampling `p` and `q` we sample integers around the right size (1024 bits) until we find one that is probaby prime. By probably prime we mean we apply the Miller-Rabin primality test for 40 iterations.

- To run this in a TEE, we need to define the Gramine `python.maniest.template`. This is based on the `CI-Examples/Python` example from Gramine. It copies over the system python, which is `python3.8` in the environment we'll use.

- For remote attestation, we'll use the Gramine interface, which is special files in `/dev/attestation/*` that will only be available when running in the enclave. The application specifies a 64-byte field by writing to `/dev/attestation/user_report_data` and then reads the quote from `/dev/attestation/quote`. If you don't have SGX you can still see how it generates RSA numbers but it won't be able to produce attestations.

## Reproducing the enclave build
The main reproducibility strategy is to use a fairly common and widely distributed base image, in this case the `1.5` release from Gramine projct. 
- [Dockerfile](Dockerfile): based on gramine image 1.5 and copies over just the application in this repository

To carry out the build and print the MRENCLAVE:

```shell
docker build -t gramine .
docker run --rm gramine
```

The reference MRENCLAVE for this release is `db718ecdcec7b7db2cd7206b7599b2472c02376195b70629fa72690e377ba69c`. You should check to see if you can reproduce it.

You can also just run `make` in this directory if you have gramine installed, and this is a convenient way to develop, but you're unlikely to get an identical match unless you have exactly the same python3.8 and packages as the base image.

## Running with SGX
To run from the docker environment on SGX, we can pass in the devices and AESM service from the host. You must have already set up the SGX driver and AESM service and all the DCAP packages, in the host outside the docker container. See the DCAP installation instructions from [Gramine.](https://gramine.readthedocs.io/en/stable/devel/building.html#install-dependencies-for-dcap)

- docker-compose.yml: This is mainly to support running on SGX. It passes in `/dev/sgx_enclave` and `/dev/sgx_provision` from the underlying host, along with the `/var/run/aesmd/aesmd.socket` for the remote attestation.
 
To run the enclave in gramine:
```shell
docker compose run --rm gramine gramine-sgx python
```

### Example output
```bash
Gramine is starting. Parsing TOML manifest file, this may take some time...
RSA modulus N:  0xb50c284c429ef4fffb2851a596210a062cc80741a505a68f215cb697294301bfcfcb259d323b63d900b0d8f4b912b9258dc6ed9b7389d25180141de43c31d911d0adf950e1d0dc37986f88e5ab7b95b42f8544c479c85bac955d3e89c9a6a131bf32b70a969cc1f9d81b11d53cb73127bc7ce87ef880fe3d13a06614b3b35fd67f6a4f70ca3bd3e69a6373f2a511bf0e63d0f84237ccf919c40c681e0a736b9e3108bdcefd2372f58e1d81c48976de8739310d18182256ec1165af8bd7e02e318b5236884f47f75eff721d28755e646bbca77c122c4e241505ed8527a51b4dd149240ff3f8857d053712a1bc7c066056834db28f97889924899e1ece70b0a3f3
sha2(N): 65c43b0c43adc9bd301253cca9ab2d0b14d91d3e24b77bc9124dbe30dc07dffc
quote
0300020000000000.....2d2d0a00
```

## Verifying the output
The output clearly includes a quote.
We can save the quote to `quote.hex` and convert to binary with
```shell
cat quote.hex | xxd -r -p > quote.dat
```

Finally, we can use the gramine quote decoder to interpret it:
```shell
gramine-sgx-quote-view quote.dat
```

You'll be able to match up the `mr_enclave` of the quote with the reproducible build step, and see that the `report_data` field contains hash of the modulus.

Finishing the verification would be possible. For example, see the [Automata implementation of quote verification in Solidity](https://github.com/automata-network/automata-dcap-v3-attestation) or the Intel [quote verification library](https://github.com/intel/SGX-TDX-DCAP-QuoteVerificationLibrary)

### Example output
```
quote_body        :
 version          : 0300
 sign_type        : 0200
 epid_group_id    : 00000000
 qe_svn           : 0a00
 pce_svn          : 0f00
 xeid             : 939a7233
 basename         : f79c4ca9940a0db3957f0607ce48836fd48a951172fe155220a719bd00000000
report_body       :
 cpu_svn          : 14140207018001000000000000000000
 misc_select      : 00000000
 reserved1        : 0000000000000000000000
 isv_ext_prod_id  : 00000000000000000000000000000000
 attributes.flags : 0500000000000000
 attributes.xfrm  : 0700000000000000
 mr_enclave       : f9841922b84a3bc60f9687bca1a596e42b4e7c6372b5d5f3a92dc1e52075647b
 reserved2        : 0000000000000000000000000000000000000000000000000000000000000000
 mr_signer        : 4e1e0575ccd68fd4b479adba51feb45c5b13684ffd98a17847a6af17c4a44400
 reserved3        : 0000000000000000000000000000000000000000000000000000000000000000
 config_id        : 00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
 isv_prod_id      : 0000
 isv_svn          : 0000
 config_svn       : 0000
 reserved4        : 000000000000000000000000000000000000000000000000000000000000000000000000000000000000
 isv_family_id    : 00000000000000000000000000000000
 report_data      : 65c43b0c43adc9bd301253cca9ab2d0b14d91d3e24b77bc9124dbe30dc07dffc0000000000000000000000000000000000000000000000000000000000000000
signature_size    : 4164 (0x1044)
signature         : a1c771d2......d0a00
```
