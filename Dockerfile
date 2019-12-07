# Copyright 2019 Walmart Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:bionic

RUN apt-get update \
 && apt-get install -y -q --allow-downgrades \
    build-essential \
    curl \
    libssl-dev \
    gcc \
    libzmq3-dev \
    openssl \
    pkg-config \
    unzip \
    git \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN curl -OLsS https://github.com/google/protobuf/releases/download/v3.5.1/protoc-3.5.1-linux-x86_64.zip \
 && unzip protoc-3.5.1-linux-x86_64.zip -d protoc3 \
 && rm protoc-3.5.1-linux-x86_64.zip

RUN curl https://sh.rustup.rs -sSf > /usr/bin/rustup-init \
 && chmod +x /usr/bin/rustup-init \
 && rustup-init -y

ENV PATH=$PATH:/protoc3/bin:/root/.cargo/bin \
    CARGO_INCREMENTAL=0

RUN mkdir /project

RUN rustup update \
 && rustup default nightly \
 && rustup target add wasm32-unknown-unknown --toolchain nightly

WORKDIR /project

RUN git clone https://github.com/arsulegai/splinter-admin-ops-daemon

WORKDIR /project/splinter-admin-ops-daemon

RUN cargo build

# The build can be found in the following directory
# /project/splinter-admin-ops-daemon/target/debug/admin-serviced
ENV PATH="${PATH}:/project/splinter-admin-ops-daemon/target/debug/"

WORKDIR /project

RUN git clone https://github.com/arsulegai/splinter-sabre-dataexporter

WORKDIR /project/splinter-sabre-dataexporter

RUN cargo build

# The build can be found in the following directory
# /project/splinter-sabre-dataexporter/target/debug/event-listener
ENV PATH="${PATH}:/project/splinter-sabre-dataexporter/target/debug/"

WORKDIR /project

RUN git clone https://github.com/arsulegai/produce-consume

WORKDIR /project/produce-consume/processor

RUN cargo build --target wasm32-unknown-unknown --release

# Copy produce-consume.wasm from here
# /project/produce-consume/processor/target/wasm32-unknown-unknown/release
ENV PATH="${PATH}:/project/produce-consume/processor/target/wasm32-unknown-unknown/release/"
