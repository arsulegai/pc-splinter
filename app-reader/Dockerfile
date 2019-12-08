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
    gcc \
    openssl \
    pkg-config \
    git \
    wget \
#    librdkafka-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /project

RUN git clone https://github.com/edenhill/librdkafka.git \
  && cd librdkafka \
  && ./configure --prefix /usr \
  && make \
  && make install

RUN wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz \
  && tar -xvf go1.13.3.linux-amd64.tar.gz \
  && mv go /usr/local

ENV GOROOT=/usr/local/go

ENV PATH=$GOPATH/bin:$GOROOT/bin:${PATH}
