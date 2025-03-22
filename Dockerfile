FROM ubuntu:14.04

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libdb++-dev \
    libboost-all-dev \
    libtool \
    autotools-dev \
    autoconf \
    pkg-config \
    libevent-dev \
    git \
    curl \
    nano \
    wget \
    automake \
    bsdmainutils \
    software-properties-common \
    python3 \
    python3-pip \
    && apt-get clean

# Optional: Create a symlink for python
RUN rm -f /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python

# Set the working directory
WORKDIR /root

# Clone the FastPeercoind repository and build the project
RUN git clone https://github.com/FastPeercoin/FastPeercoind.git fastpeercoind && \
    cd fastpeercoind && \
    ./autogen.sh && \
    ./configure --with-incompatible-bdb && \
    make -j$(nproc)

# Create a volume for persistent blockchain data
VOLUME ["/root/.peercoin"]

# Set up RPC credentials in the peercoin.conf file

# Genproclimit is number of cores to mine with
RUN mkdir -p /root/.peercoin && \
    echo "rpcuser=username" > /root/.peercoin/peercoin.conf && \
    echo "rpcpassword=password" >> /root/.peercoin/peercoin.conf && \
    echo "server=1" >> /root/.peercoin/peercoin.conf && \
    echo "daemon=0" >> /root/.peercoin/peercoin.conf && \
    echo "txindex=1" >> /root/.peercoin/peercoin.conf && \
    echo "setgenerate=true" >> /root/.peercoin/peercoin.conf && \
    echo "genproclimit=2" >> /root/.peercoin/peercoin.conf

# Expose the default Peercoin port
EXPOSE 9999

# Start the FastPeercoin daemon
CMD [ "bash", "-c", "\
  /root/fastpeercoind/src/peercoind -daemon && \
  sleep 10 && \
  /root/fastpeercoind/src/peercoin-cli setgenerate true 2 && \
  tail -f /dev/null" ]

