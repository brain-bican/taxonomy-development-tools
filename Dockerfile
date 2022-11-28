FROM ubuntu:22.04

ENV WORKSPACE=/tools
RUN mkdir $WORKSPACE
RUN mkdir $WORKSPACE/dendR

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&  \
    apt-get install -y --no-install-recommends \
    git \
    python3-pip  \
    python3-dev  \
    python3-virtualenv \
    make \
    r-base

# TODO install pandoc https://pandoc.org/installing.html#linux (required by AllenInstitute/CCN)
# https://github.com/jgm/pandoc/releases/download/2.19.2/pandoc-2.19.2-1-amd64.deb
# sudo dpkg -i $DEB

ADD Makefile $WORKSPACE
ADD requirements.txt $WORKSPACE
ADD tdt/tdt.py $WORKSPACE
ADD dendR/nomenclature_builder.R $WORKSPACE/dendR
ADD dendR/install_packages.R $WORKSPACE/dendR

RUN python3 -m pip install  -r $WORKSPACE/requirements.txt
RUN Rscript $WORKSPACE/dendR/install_packages.R

WORKDIR $WORKSPACE

RUN chmod 777 $WORKSPACE/*.py
CMD python3 $WORKSPACE/tdt.py