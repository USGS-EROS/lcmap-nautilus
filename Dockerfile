FROM usgseros/lcmap-spark:1.1.0-develop

USER root

ENV JPTR_KERNELS /usr/local/share/jupyter/kernels

# Yum installations that we want to keep
RUN yum install -y maven \
                   make \
                   git && \
    yum clean all && \
    rm -rf /var/cache/yum

# Additional Python packages that are nice to have
RUN conda install --yes scikit-learn \
                        cython \
                        seaborn \
                        pyyaml \
                        gdal \
                        xarray && \
    pip install cassandra-driver \
                https://dist.apache.org/repos/dist/dev/incubator/toree/0.2.0-incubating-rc5/toree-pip/toree-0.2.0.tar.gz && \
    jupyter toree install --spark_home=$SPARK_HOME && \
    conda clean --all -y

# Maven installations
COPY pom.xml /tmp

RUN mvn -e -f /tmp/pom.xml dependency:copy-dependencies -DoutputDirectory=$SPARK_HOME/jars && \
    rm -f $SPARK_HOME/jars/akka-actor_2.11-2.3.11.jar && \
    rm -f /tmp/pom.xml

# Clojure stuff
RUN curl -o /usr/local/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && \
    chmod +x /usr/local/bin/lein && \
    lein && \
    mkdir /tmp/clojupyter && \
    git clone https://github.com/clojupyter/clojupyter.git /tmp/clojupyter && \
    make -C /tmp/clojupyter && \
    mkdir -p $JPTR_KERNELS/clojure && \
    cp /tmp/clojupyter/bin/clojupyter $JPTR_KERNELS/clojure && \
    sed 's|KERNEL|'$JPTR_KERNELS/clojure/clojupyter'|' /tmp/clojupyter/resources/kernel.json > $JPTR_KERNELS/clojure/kernel.json && \
    rm -rf /tmp/clojupyter

RUN chown -Rf lcmap $HOME

USER lcmap

CMD ["jupyter", "notebook", "--port=8888", "--ip=0.0.0.0", "--no-browser", "--notebook-dir=~"]
