FROM usgseros/lcmap-spark:1.1.0-develop

USER root

ENV JPTR_KERNELS /usr/local/share/jupyter/kernels

# Yum installations
RUN yum install -y maven \
                   make \
                   git

# Additional Conda packages that are nice to have
RUN conda install --yes scikit-learn \
                        cython \
                        seaborn \
                        pyyaml \
                        xarray

RUN pip install cassandra-driver

RUN pip install https://dist.apache.org/repos/dist/dev/incubator/toree/0.2.0-incubating-rc5/toree-pip/toree-0.2.0.tar.gz && \
    jupyter toree install --spark_home=$SPARK_HOME

# Maven installations
COPY pom.xml /tmp

RUN mvn -e -f /tmp/pom.xml dependency:copy-dependencies -DoutputDirectory=$SPARK_HOME/jars

# Clojure stuff
RUN curl -o /usr/local/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && \
    chmod +x /usr/local/bin/lein && \
    lein

RUN mkdir /tmp/clojupyter && \
    git clone https://github.com/clojupyter/clojupyter.git /tmp/clojupyter
WORKDIR /tmp/clojupyter

RUN make && \
    mkdir -p $JPTR_KERNELS/clojure && \
    cp bin/clojupyter $JPTR_KERNELS/clojure && \
    sed 's|KERNEL|'$JPTR_KERNELS/clojure/clojupyter'|' resources/kernel.json > $JPTR_KERNELS/clojure/kernel.json

WORKDIR $HOME

# Clean up Everything to reduce the image size
RUN yum erase -y maven && \
    yum clean all && \
    conda clean --all -y && \
    rm -rf /tmp/*

# Remove the old version of akka for toree, some env nonsense going on
RUN rm -f $SPARK_HOME/jars/akka-actor_2.11-2.3.11.jar

USER lcmap
