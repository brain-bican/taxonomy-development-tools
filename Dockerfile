FROM ubuntu:22.04

ENV WORKSPACE=/tools
RUN mkdir $WORKSPACE
RUN mkdir $WORKSPACE/dendR
RUN mkdir $WORKSPACE/scripts
RUN mkdir $WORKSPACE/resources

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
    leiningen \
    gpg

# Shiny app dependencies https://github.com/AllenInstitute/annotation_comparison
# to speedup R package installations (try apt-cache search r-cran-remotes) https://datawookie.dev/blog/2019/01/docker-images-for-r-r-base-versus-r-apt/
# to search all available packages: https://packages.debian.org/stable/allpackages
RUN apt-get update && \
    apt-get install -y -qq \
    r-cran-remotes \
    r-cran-dplyr \
    r-cran-data.table \
    r-cran-dt \
    r-cran-ggplot2 \
    r-cran-ggbeeswarm \
    r-cran-shiny \
    r-cran-upsetr \
    r-cran-biocmanager \
    r-cran-shinydashboard \
    r-bioc-rhdf5

ADD Makefile $WORKSPACE
ADD resources/repo_README.md $WORKSPACE/resources
ADD resources/repo_PURL_config.yml $WORKSPACE/resources
ADD requirements.txt $WORKSPACE
ADD tdt/tdt.py $WORKSPACE
ADD dendR/nomenclature_builder.R $WORKSPACE/dendR
ADD dendR/install_packages.R $WORKSPACE/dendR
ADD dendR/required_scripts.R $WORKSPACE/dendR
ADD scripts/run.sh $WORKSPACE/scripts
ADD scripts/import.py $WORKSPACE/scripts
ADD scripts/configurations.py $WORKSPACE/scripts

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
ADD nanobot/src/resources/taxonomy_view.html $WORKSPACE/nanobot/src/resources
ADD nanobot/src/resources/table.html $WORKSPACE/nanobot/src/resources

# GH cli on linux is old (2.4.0), get the latest
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
RUN chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null


RUN apt-get update &&  \
    apt-get install -y aha \
    sqlite3 \
    python3-psycopg2 \
    gh

# install annotation_comparison tool
WORKDIR $WORKSPACE
RUN git clone https://github.com/hkir-dev/annotation_comparison.git && \
    cd annotation_comparison && \
    git checkout tdt_integration
RUN Rscript $WORKSPACE/annotation_comparison/R/install_packages.R

# restore WORKDIR
WORKDIR $WORKSPACE


RUN chmod 777 $WORKSPACE/*.py

COPY entrypoint.sh entrypoint.sh

#CMD python3 $WORKSPACE/tdt.py
CMD ./entrypoint.sh