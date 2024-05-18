FROM gramineproject/gramine:v1.5

RUN apt-get update
RUN apt-get install -y make gcc

ENV SGX 1

RUN gramine-sgx-gen-private-key

WORKDIR /root/

ADD rsademo.py ./
ADD python.manifest.template ./
ADD Makefile ./

RUN mkdir -p enclave_data

RUN SGX=1 make

CMD [ "gramine-sgx-sigstruct-view", "python.sig" ]
