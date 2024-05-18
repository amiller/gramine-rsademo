FROM gramineproject/gramine:v1.5

RUN apt-get update
RUN apt-get install make

ENV SGX 1

RUN gramine-sgx-gen-private-key

WORKDIR /root/

ADD rsademo.py ./
ADD python.manifest.template ./
ADD Makefile ./

RUN mkdir -p input_data output_data enclave_data

RUN SGX=1 make

CMD "bash"
# CMD [ "gramine-sgx-sigstruct-view", "python.sig" ]
