FROM jupyter/datascience-notebook:python-3.8.13

USER root

WORKDIR home/tgao
COPY requirements.txt .
COPY fpocket/ ./fpocket/

# install packages
# If installing in China you need modify source using tinghua images(python3.8)
# install open jdk8
# there are 3.8 3.10 in this docker, activate by typing `python3.8`,`python3.10`
# create a jupyter kernel for this env
RUN export DEBIAN_FRONTEND=noninteractive && export TZ=EDT && \
    apt-get update && \
    apt install -y openjdk-8-jdk && \
    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 && \
    apt install -y software-properties-common git gcc make && \
    apt install -y graphviz-dev graphviz libgraphviz-dev pkg-config && \
    apt install -y libstdc++-9-dev libstdc++6 && \
    pip install --upgrade pip && \
    pip install torch==1.10.1 torchvision==0.11.2 torchaudio==0.10.1 torchmetrics==0.6.2 pytorch_lightning==1.5.7  && \
    wget  https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get -y install cuda && \
    pip install --no-cache-dir --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple -r requirements.txt && \
    cd fpocket && \
    make && make install && \
    python3 -m ipykernel install --user --name NucleicNet


# copy the whole Decompress halo and pdbs
COPY Database-PDB/ ./Database-PDB/
COPY NucleicNet/ ./NucleicNet/
COPY jupyter_conf/ ./jupyter_conf/
COPY Notebooks/ ./Notebooks/
COPY GoogleColab/ ./GoogleColab/
COPY LocalServerExample/ ./LocalServerExample/
COPY Models/ ./Models/
COPY NightlyBackup/ ./NightlyBackup/
COPY jupyter_conf/ ./jupyter_conf/

# =========== everything above is nucleicnet:v1 ============== #

#FROM nucleicnet:v1 # 两次搭建，防止掉线
#USER root

# Decompress halo and pdbs
# Decompress halo indexings
# Executables permission
RUN echo '\n===========start decompress pdbs, indexings and changing permission===========\n' && \
    echo $(pwd) && \
    cd ./Database-PDB/halo/ && cat halo.tar.gz.* | tar zxvf - --strip-components 1 && \
    cd .. && cd .. && cd .. && cd .. && \
    echo $(pwd) && echo '\n================halo complete=====================\n'

RUN cd ./Database-PDB/typi/ && cat typi.tar.gz.* | tar zxvf - --strip-components 1 && \
    cd .. && cd .. && cd .. && cd .. && \
    echo $(pwd) && echo '\n================typi complete=====================\n'

RUN cd ./Database-PDB/cleansed/ && cat cleansed.tar.gz.* | tar zxvf - --strip-components 1 && \
    cd .. && cd .. && cd .. && cd .. && \
    echo $(pwd) && echo '\n================cleansed complete=====================\n'

RUN cd ./Database-PDB/landmark/ && cat landmark.tar.gz.* | tar zxvf - --strip-components 1 && \
    cd .. && cd .. && cd .. && cd .. && \
    echo $(pwd) && echo '\n================landmark complete=====================\n'

RUN cd ./Database-PDB/apo/ && cat apo.tar.gz.* | tar zxvf - --strip-components 1 && \
    cd .. && cd .. && cd .. && cd .. && \
    echo $(pwd) && echo '\n================apo complete=====================\n'

RUN cd ./Database-PDB/dssp/ && cat dssp.tar.gz.* | tar zxvf - --strip-components 1 && \
    cd .. && cd .. && cd .. && cd .. && \
    echo $(pwd) && echo '\n================dssp complete=====================\n'

RUN cd ./Database-PDB/DerivedData/ && cat 3CvFoldReference_SXPR_BC.tar.gz.* | tar zxvf - && \
    cd .. && cd .. && cd .. && cd .. && \
    echo $(pwd) && echo '\n================DerivedData/3CvFoldReference_SXPR_BC complete=====================\n'

RUN cd ./Database-PDB/DerivedData/ && cat 3CvFoldReference_SXPR_Mmseq.tar.gz.* | tar zxvf - && \
    cd .. && cd .. && cd .. && cd .. && \
    echo $(pwd) && echo '\n================DerivedData/3CvFoldReference_SXPR_Mmseq complete=====================\n'

RUN cd ./NucleicNet/util/ && tar -zxvf feature-3.1.0.tar.gz && \
    cd .. && cd .. && cd .. && cd .. && \
    echo $(pwd) && echo '\n================util/feature-3.1.0.tar.gz complete=====================\n'

RUN chmod -R +x ./NucleicNet/util/dssp && \
    chmod -R +x ./NucleicNet/util/feature-3.1.0/ && \
    chmod -R +x ./Database-PDB/ && \
    echo '\n===================PDB clear=======================\n'


EXPOSE 6666

ENTRYPOINT ["python3", "-m"]
CMD ["jupyter", "notebook", "list"]
CMD ["jupyter", "notebook", "--MultiKernelManager.default_kernel_name=NucleicNet", "--allow-root", "--config=./jupyter_conf/jupyter.py"]
#jupyter notebook --MultiKernelManager.default_kernel_name=NucleicNet --allow-root --config=./jupyter_conf/jupyter.py
# how to build the docker :
# docker build --no-cache -t nucleicnet:v1 .
# how to run the jupyter server :
# docker run -it -p 8888:6666 nucleicnet:v1
# access by enter http://localhost:8888 or http://127.0.0.1:8888
# paste the token if notebook ask for password
# run container in root: docker exec --interactive --tty --user root ba0a1cf53389 /bin/bash
#docker run -it -p 8888:6666 nucleicnet:v1
#jupyter notebook: http://127.0.0.1:8888
