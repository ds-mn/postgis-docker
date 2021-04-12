FROM postgis/postgis:13-3.1

RUN set -ex;\
    mkdir -p /gisdata ;\
    chmod 1777 /gisdata ;\
    apt-get update ;\
    apt-get install -y \
        wget \
        unzip \
        postgis \
        postgresql-plpython3-${PG_MAJOR} \
        ;\
    apt-get install -y --no-install-recommends \
        python3-numpy \
        python3-pip \
        python3-scipy \
        ;\
    apt-get -y dist-upgrade ;\
    apt-get --purge -y autoremove ;\
    apt-get -y clean ;\
    rm -rf /var/lib/apt/lists/*

VOLUME /gisdata

ENV TIGER_YEAR=2019
ENV PIP_PACKAGES=""

COPY 2*.sh /docker-entrypoint-initdb.d/
COPY load_state.sh bootstrap-pip.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/bootstrap-pip.sh" , "/usr/local/bin/docker-entrypoint.sh"]

CMD ["postgres"]
