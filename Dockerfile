FROM usgseros/lcmap-spark:1.1.0-develop

# Additional Conda packages that are nice to have
RUN sudo /usr/local/bin/conda install --yes scikit-learn \
                                            seaborn \
                                            pyyaml \
                                            xarray

# Re-install Maven and do anything maveny
COPY pom.xml /root
RUN sudo yum install -y maven

RUN sudo mvn -e -f /root/pom.xml dependency:copy-dependencies -DoutputDirectory=$SPARK_HOME/jars

# Clean up Everything to reduce the image size
RUN sudo yum erase -y maven
RUN sudo yum clean all
RUN conda clean --all -y
