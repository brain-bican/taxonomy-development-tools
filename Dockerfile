FROM ubuntu:22.04

ENV WORKSPACE=/tools
RUN mkdir $WORKSPACE
RUN mkdir $WORKSPACE/dendR
RUN mkdir $WORKSPACE/scripts
RUN mkdir $WORKSPACE/resources
RUN mkdir $WORKSPACE/resources/assets
RUN mkdir $WORKSPACE/resources/github_actions

ENV DEBIAN_FRONTEND=noninteractive
# for cellxgene-census
ENV VCPKG_FORCE_SYSTEM_BINARIES=1

RUN apt-get update &&  \
    apt-get install -y --no-install-recommends \
#    build-essential  \
    git \
#    openjdk-11-jdk-headless \
    python3-pip  \
    python3-dev  \
    python3-virtualenv \
    make \
    curl  \
    wget  \
#    libcurl4-openssl-dev  \
#    openssl \
#    r-base  \
#    leiningen \
#    gpg \
    pkg-config \
    zip \
    unzip \
    tar
#    ninja-build \
#    supervisor

# setup supervisord
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

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
ADD resources/repo_README.md $WORKSPACE/resources
ADD resources/repo_PURL_config.yml $WORKSPACE/resources
ADD resources/repo_mkdocs.yml $WORKSPACE/resources
ADD resources/repo_mkdocs_large.yml $WORKSPACE/resources
ADD requirements.txt $WORKSPACE
ADD tdt/tdt.py $WORKSPACE
ADD tdt/api/tdt_api.py $WORKSPACE
ADD tdt/api/review.py $WORKSPACE
ADD tdt/api/user_info.py $WORKSPACE
ADD tdt/api/tdt_info.py $WORKSPACE
ADD tdt/tdt_info.yaml $WORKSPACE
ADD tdt/api/flags.py $WORKSPACE
ADD dendR/nomenclature_builder.R $WORKSPACE/dendR
ADD dendR/install_packages.R $WORKSPACE/dendR
ADD dendR/required_scripts.R $WORKSPACE/dendR
ADD scripts/run.sh $WORKSPACE/scripts
ADD scripts/run.bat $WORKSPACE/scripts
ADD scripts/import.py $WORKSPACE/scripts
ADD scripts/configurations.py $WORKSPACE/scripts
ADD scripts/export.py $WORKSPACE/scripts
ADD scripts/upgrade.py $WORKSPACE/scripts
ADD scripts/.gitignore $WORKSPACE/scripts
ADD resources/assets/logo.webp $WORKSPACE/resources/assets
ADD resources/github_actions/publish-docs.yml $WORKSPACE/resources/github_actions

RUN python3 -m pip install  -r $WORKSPACE/requirements.txt

# install cas-tools and its dependencies seperately to avoid cellxgene-census installation issues
RUN python3 -m pip install anndata==0.10.5
RUN python3 -m pip install ruamel.yaml==0.18.6
RUN python3 -m pip install jsonschema==4.4.0
RUN python3 -m pip install ordered-set==4.1.0
RUN python3 -m pip install deepmerge==1.1.0
RUN python3 -m pip install numpy==1.26.4
RUN python3 -m pip install marshmallow==3.21.1
RUN python3 -m pip install python-dateutil==2.9.0
RUN python3 -m pip install cap-anndata==0.3.0
RUN python3 -m pip install --no-deps cas-tools==1.1.5
RUN python3 -m pip install --no-deps tdta==0.1.4

#RUN Rscript $WORKSPACE/dendR/install_packages.R


#RUN python3 -m pip install --no-deps --index-url https://test.pypi.org/pypi/ --extra-index-url https://pypi.org/simple cas-tools==0.0.1.dev44

WORKDIR $WORKSPACE

### Relatable reources
RUN mkdir $WORKSPACE/relatable
ADD relatable/nanobot.toml $WORKSPACE/relatable
RUN mkdir $WORKSPACE/relatable/src
RUN mkdir $WORKSPACE/relatable/src/templates
ADD relatable/src/templates/cell_menu.html $WORKSPACE/relatable/src/templates
ADD relatable/src/templates/column_menu.html $WORKSPACE/relatable/src/templates
ADD relatable/src/templates/page.html $WORKSPACE/relatable/src/templates
ADD relatable/src/templates/row_menu.html $WORKSPACE/relatable/src/templates
ADD relatable/src/templates/table.html $WORKSPACE/relatable/src/templates
ADD relatable/src/templates/taxonomy_view.html $WORKSPACE/relatable/src/templates
RUN mkdir $WORKSPACE/relatable/bin
ADD relatable/bin/rltbl $WORKSPACE/relatable/bin

# GH cli on linux is old (2.4.0), get the latest
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
RUN chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null


RUN apt-get update &&  \
    apt-get install -y aha \
    sqlite3 \
    python3-psycopg2

RUN apt-get install gh --allow-unauthenticated

# restore WORKDIR
WORKDIR /tools


RUN chmod 777 $WORKSPACE/*.py
CMD python3 $WORKSPACE/tdt.py
