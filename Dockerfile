FROM alpine:3.9

# Split these up so the prior ones are available to the next as they build on one another
ENV JMETER_VERSION=5.1
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN=${JMETER_HOME}/bin
ENV PATH="${PATH}:${JMETER_BIN}"

# Install some nice tools and such
RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates \
    openssh-client \
    openjdk8-jre \
    tzdata \
    unzip

# Download jmeter and install
RUN curl --silent --fail --location --retry 3 --output /tmp/jmeter.tgz --url http://apache.osuosl.org/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz > /tmp/jmeter.tgz \
    && tar -xzf /tmp/jmeter.tgz -C /opt \
    && rm /tmp/jmeter.tgz

# Make output directory and link within jmeter home
RUN mkdir -p /opt/output \
    && ln -s /opt/output ${JMETER_HOME}/output

# Set up entrypoint
COPY ./entrypoint.sh ${JMETER_BIN}/entrypoint

# Execute the default run command
ENTRYPOINT ["entrypoint"]
