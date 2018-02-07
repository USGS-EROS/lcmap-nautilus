FROM usgseros/lcmap-spark:1.0

RUN sudo /usr/local/bin/conda install scikit-learn seaborn pyyaml --yes
