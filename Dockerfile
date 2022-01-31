FROM ubuntu:20.04

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y wget python3 python3-distutils libglib2.0-0 libsm6 libxrender1 libxext6 python3-pip && \
    pip3 install opencv-python && \
    rm -rf /var/lib/apt/lists/*
