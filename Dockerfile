FROM gramineproject/gramine:v1.5

RUN apt-get update
RUN apt-get install -y make

ENV SGX 1

RUN gramine-sgx-gen-private-key

WORKDIR /root/

ADD rsademo.py ./
ADD python.manifest.template ./
ADD Makefile ./

RUN mkdir -p untrustedhost

RUN SGX=1 make

ENTRYPOINT []
CMD [ "gramine-sgx-sigstruct-view", "python.sig" ]
