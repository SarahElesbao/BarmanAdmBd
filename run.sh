#!/bin/bash

function configure(){

    mkdir -m 755 -p "$(pwd)/data/pgbarman/sshkeys"
    mkdir -m 755 -p "$(pwd)/data/pgbarman/log"
    mkdir -m 755 -p "$(pwd)/data/pgbarman/backupcfg"
    mkdir -m 755 -p "$(pwd)/data/pgbarman/backups"

    ssh-keygen -b 4096 -t rsa -N '' -f "$(pwd)/data/pgbarman/sshkeys/id_rsa"
    ssh-keygen -f "$(pwd)/data/pgbarman/sshkeys/id_rsa" -y >> "$(pwd)/data/pgbarman/sshkeys/authorized_keys"

    #ssh-keygen -f $(pwd)/data/pgbarman/sshkeys/id_rsa -y >> $(pwd)/data/postgresql/sshkeys/authorized_keys
    #ssh-keygen -f $(pwd)/data/postgresql/sshkeys/id_rsa -y >> $(pwd)/data/pgbarman/sshkeys/authorized_keys

    chmod 755 "$(pwd)/data/pgbarman/sshkeys/id_rsa"
    chmod 755 "$(pwd)/data/pgbarman/sshkeys/id_rsa.pub"
    chmod 755 "$(pwd)/data/pgbarman/sshkeys/authorized_keys"
    chmod -R 755 "$(pwd)/data/pgbarman/sshkeys"

    cp Barman/postgres-source-db.conf "$(pwd)/data/pgbarman/backupcfg/."
}

function build(){
    docker-compose --compatibility --project-name "postgresql-barman" build --memory 1g --no-cache;
}

function up(){
    docker-compose --compatibility --project-name "postgresql-barman" up -d;
}

function stop(){
    docker-compose --compatibility --project-name "postgresql-barman" stop;
}

function drop(){
    docker-compose --compatibility --project-name "postgresql-barman" down;
}

function drop_hard(){
    docker-compose --compatibility --project-name "postgresql-barman" down --remove-orphans --volumes --rmi 'all' && \
    [ -d "./data" ] && sudo rm -rf ./data;
    docker builder prune -f;
}

function populate(){
    docker exec postgres-source-db psql -U dbadmin -d 'db' -p 5432 -c "$(cat ./Postgres/populate_primary_db.sql)";
}

function seed(){
    docker exec postgres-source-db psql -U dbadmin -d 'db' -p 5432 -c "$(cat ./Postgres/populate_primary_db2.sql)";
}

$1