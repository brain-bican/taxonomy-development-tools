FROM ubuntu:22.04

ENV WORKSPACE=/tools
RUN mkdir $WORKSPACE
RUN mkdir $WORKSPACE/dendR
RUN mkdir $WORKSPACE/scripts

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&  \
    apt-get install -y --no-install-recommends \
    build-essential  \
    git \
    openjdk-11-jdk-headless \
    python3-pip  \
    python3-dev  \
    python3-virtualenv \
    make \
    curl  \
    wget  \
    libcurl4-openssl-dev  \
    openssl \
    r-base  \
    leiningen

# to speedup R package installations (try apt-cache search r-cran-remotes) https://datawookie.dev/blog/2019/01/docker-images-for-r-r-base-versus-r-apt/
#RUN apt-get update && \
#    apt-get install -y -qq \
#    r-cran-remotes \
#    r-cran-jsonlite \
#    r-cran-data.table \
#    r-cran-ggplot2 \
#    r-cran-dendextend \
#    r-cran-biocmanager \
#    r-cran-knitr \
#    r-cran-httr

# install pandoc (required by AllenInstitute/CCN)
#RUN wget https://github.com/jgm/pandoc/releases/download/2.19.2/pandoc-2.19.2-1-amd64.deb
#RUN dpkg -i ./pandoc-2.19.2-1-amd64.deb

ADD Makefile $WORKSPACE
ADD requirements.txt $WORKSPACE
ADD tdt/tdt.py $WORKSPACE
ADD dendR/nomenclature_builder.R $WORKSPACE/dendR
ADD dendR/install_packages.R $WORKSPACE/dendR
ADD dendR/required_scripts.R $WORKSPACE/dendR
ADD scripts/run.sh $WORKSPACE/scripts
ADD scripts/import.py $WORKSPACE/scripts

RUN python3 -m pip install  -r $WORKSPACE/requirements.txt
#RUN Rscript $WORKSPACE/dendR/install_packages.R

WORKDIR $WORKSPACE

### NANOBOT reources
RUN mkdir $WORKSPACE/nanobot
ADD nanobot/nanobot.toml $WORKSPACE/nanobot
RUN mkdir $WORKSPACE/nanobot/src
RUN mkdir $WORKSPACE/nanobot/src/schema
ADD nanobot/src/schema/column.tsv $WORKSPACE/nanobot/src/schema
ADD nanobot/src/schema/datatype.tsv $WORKSPACE/nanobot/src/schema
ADD nanobot/src/schema/table.tsv $WORKSPACE/nanobot/src/schema
RUN mkdir $WORKSPACE/nanobot/src/assets
ADD nanobot/src/assets/bstreeview.css $WORKSPACE/nanobot/src/assets
ADD nanobot/src/assets/bstreeview.js $WORKSPACE/nanobot/src/assets
ADD nanobot/src/assets/ols-autocomplete.css $WORKSPACE/nanobot/src/assets
ADD nanobot/src/assets/ols-autocomplete.js $WORKSPACE/nanobot/src/assets
ADD nanobot/src/assets/styles.css $WORKSPACE/nanobot/src/assets
RUN mkdir $WORKSPACE/nanobot/src/resources
ADD nanobot/src/resources/cross_taxonomy.html $WORKSPACE/nanobot/src/resources
ADD nanobot/src/resources/ols_form.html $WORKSPACE/nanobot/src/resources

RUN apt-get install -y aha \
    sqlite3 \
    python3-psycopg2

# restore WORKDIR
WORKDIR /tools


RUN chmod 777 $WORKSPACE/*.py
CMD python3 $WORKSPACE/tdt.py
