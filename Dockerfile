FROM usgseros/lcmap-spark:1.1.0-develop

RUN sudo /usr/local/bin/conda install scikit-learn seaborn pyyaml xarray --yes
