FROM ubuntu:focal
USER root
WORKDIR /data
ARG ROOTDATADIR=/data
ARG RPCUSERNAME=user
ARG RPCPASSWORD=pass
ARG LTCVERSION=0.18
ARG ARCH=x86_64

ARG MAINP2P=9333
ARG MAINRPC=9332
ARG TESTP2P=19335
ARG TESTRPC=19332

# You can confirm your timezone by setting the TZ database name field from:
# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
ARG LOCALTIMEZONE=UTC

# Set to 1 for running it in testnet mode
ARG TESTNET=1

# Do we want any blockchain pruning to take place? Set to 4096 for a 4GB blockchain prune.
# Alternatively set size=1 to prune with RPC call 'pruneblockchainheight <height>'
ARG PRUNESIZE=0

# Update apt cache and set tzdata to non-interactive or it will fail later.
# Also install essential dependencies for the build project.
RUN DEBIAN_FRONTEND="noninteractive" apt-get update \
	&& apt-get -y install tzdata \
	&& ln -fs /usr/share/zoneinfo/${LOCALTIMEZONE} /etc/localtime \
	&& dpkg-reconfigure --frontend noninteractive tzdata \
	&& apt-get install -y wget git build-essential libtool autotools-dev automake \
	pkg-config libssl-dev libevent-dev bsdmainutils python3 libboost-system-dev \
	libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev \
	libdb-dev libdb++-dev curl zip unzip cmake

# Build libmw
RUN git clone https://github.com/ltc-mweb/libmw.git --recursive \
	&& cd libmw/vcpkg/vcpkg && ./bootstrap-vcpkg.sh \
	&& ./vcpkg install --triplet x64-linux @../packages.txt \
	&& cd ../.. && mkdir -p build && cd build \
	&& cmake -DCMAKE_BUILD_TYPE=Release .. && cmake --build . --target install

# RUN git clone https://github.com/litecoin-project/litecoin/ --branch ${LTCVERSION} --single-branch
RUN git clone https://github.com/ltc-mweb/litecoin/

RUN cd ${ROOTDATADIR}/litecoin \
	&& cd depends \
	&& make \
	&& cd .. \
	&& ./contrib/install_db4.sh `pwd` \
	&& ./autogen.sh \
	&& ./configure BDB_LIBS="-L${ROOTDATADIR}/litecoin/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${ROOTDATADIR}/litecoin/include" --prefix=$PWD/depends/x86_64-pc-linux-gnu \
	&& make && make install


RUN mkdir -vp ${ROOTDATADIR}/.litecoin
VOLUME ${ROOTDATADIR}/.litecoin

# Allow Mainnet P2P comms
EXPOSE 9333

# Allow Mainnet RPC
EXPOSE 9332

# Allow Testnet RPC
EXPOSE 19335

# Allow Testnet P2P comms
EXPOSE 19332

# Command for running
CMD /data/litecoin/depends/x86_64-pc-linux-gnu/bin/litecoind -testnet=${TESTNET} -txindex=0 -rpcpassword=$RPCPASSWORD} -rpcuser=${RPCUSERNAME} -daemon=1 -rpcallowip=127.0.0.1 -prune=${PRUNESIZE} -server=1
