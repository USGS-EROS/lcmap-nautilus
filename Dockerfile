FROM usgseros/lcmap-spark:latest

RUN sudo /usr/local/bin/conda install scikit-learn seaborn pyyaml --yes
