# ltc-mweb-docker
Build & test Litecoin + MW EB's from docker easily

Currently while awaiting further instructions this builds ltc-mweb/libmw and litecoin-project/litecoin (0.18, configurable)

Simply run:
<pre>git clone https://github.com/ChillingSilence/ltc-mweb-docker
cd ltc-mweb-docker
docker build -t ltc-mweb-docker:latest .
docker run ltc-mweb-docker:latest</pre>

This will download the latest release specified in the file (which can easily be tweaked manually) and get it all spun up and running, built from source on Ubuntu 20.04.
It's also very easy to run it on testnet or mainnet etc by tweaking the variables at the top of the Dockerfile
