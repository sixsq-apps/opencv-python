FROM ubuntu:20.04

RUN apt update && \
    apt install -y wget python3 python3-distutils libglib2.0-0 libsm6 libxrender1 libxext6 && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    pip3 install opencv-python && \
    rm -rf /var/lib/apt/lists/*
