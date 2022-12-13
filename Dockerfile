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
    r-base

# to speedup R package installations (try apt-cache search r-cran-remotes) https://datawookie.dev/blog/2019/01/docker-images-for-r-r-base-versus-r-apt/
RUN apt-get update && \
    apt-get install -y -qq \
    r-cran-remotes \
    r-cran-jsonlite \
    r-cran-data.table \
    r-cran-ggplot2 \
    r-cran-dendextend \
    r-cran-biocmanager \
    r-cran-knitr \
    r-cran-httr


# install pandoc (required by AllenInstitute/CCN)
RUN wget https://github.com/jgm/pandoc/releases/download/2.19.2/pandoc-2.19.2-1-amd64.deb
RUN dpkg -i ./pandoc-2.19.2-1-amd64.deb

ADD Makefile $WORKSPACE
ADD requirements.txt $WORKSPACE
ADD tdt/tdt.py $WORKSPACE
ADD dendR/nomenclature_builder.R $WORKSPACE/dendR
ADD dendR/install_packages.R $WORKSPACE/dendR
ADD dendR/required_scripts.R $WORKSPACE/dendR
ADD scripts/run.sh $WORKSPACE/scripts

RUN python3 -m pip install  -r $WORKSPACE/requirements.txt
RUN Rscript $WORKSPACE/dendR/install_packages.R

WORKDIR $WORKSPACE

### OntoDev setup
ADD scripts/run_nanobot.py $WORKSPACE
ADD ontodev.Makefile $WORKSPACE
ADD scripts/cogs.sh $WORKSPACE/scripts
ADD scripts/generate.py $WORKSPACE/scripts
ADD scripts/search_view_template.sql $WORKSPACE/scripts
ADD scripts/upload.py $WORKSPACE/scripts

RUN mkdir $WORKSPACE/resources
ADD resources/assay.tsv $WORKSPACE/resources
ADD resources/column.tsv $WORKSPACE/resources
ADD resources/datatype.tsv $WORKSPACE/resources
ADD resources/import.tsv $WORKSPACE/resources
ADD resources/import_config.tsv $WORKSPACE/resources
ADD resources/prefix.tsv $WORKSPACE/resources
ADD resources/strain.tsv $WORKSPACE/resources
ADD resources/table.tsv $WORKSPACE/resources
ADD resources/taxonomy_config.tsv $WORKSPACE/resources

RUN apt-get install -y aha \
    sqlite3

# install Rust
WORKDIR $WORKSPACE
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rust.sh
RUN sh rust.sh -y
ENV PATH="/root/.cargo/bin:$PATH"

# install wiring.py using wiring.rs bindings
WORKDIR  $WORKSPACE
RUN git clone https://github.com/ontodev/wiring.py.git
WORKDIR  $WORKSPACE/wiring.py
RUN git clone https://github.com/ontodev/wiring.rs.git
RUN mv python_module.rs wiring.rs/src/
RUN rm wiring.rs/Cargo.toml
RUN mv Cargo.toml wiring.rs/
RUN echo "mod python_module;" >> wiring.rs/src/lib.rs
RUN pip install -U pip maturin
RUN maturin build --release --out dist -m wiring.rs/Cargo.toml
RUN pip install dist/wiring_rs-0.1.1-cp36-abi3-manylinux_2_34_x86_64.whl

# install nanobot
WORKDIR $WORKSPACE
RUN git clone https://github.com/hkir-dev/nanobot.git
WORKDIR $WORKSPACE/nanobot
RUN git checkout bican
RUN pip install -e .

# install project Python requirements
#WORKDIR $WORKSPACE
#COPY requirements.txt $WORKSPACE/obi-requirements.txt
#RUN pip install -r obi-requirements.txt

# restore WORKDIR
WORKDIR /tools


RUN chmod 777 $WORKSPACE/*.py
CMD python3 $WORKSPACE/tdt.py