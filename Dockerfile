FROM ubuntu:22.04

ENV WORKSPACE=/tools
RUN mkdir $WORKSPACE

RUN apt-get update &&  \
    apt-get install -y --no-install-recommends \
    git \
    python3-pip  \
    python3-dev  \
    python3-virtualenv \
    make

ADD requirements.txt $WORKSPACE/
ADD tdt/tdt.py $WORKSPACE

RUN python3 -m pip install  -r $WORKSPACE/requirements.txt

RUN chmod 777 $WORKSPACE/*.py
CMD python3 $WORKSPACE/tdt.py