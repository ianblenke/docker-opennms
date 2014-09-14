OpenNMS for docker with multiple container linkage
=================================================

This image runs a linkable [OpenNMS](https://http://www.opennms.org/)

There is an automated build repository on docker hub for [ianblenke/opennms](https://registry.hub.docker.com/u/ianblenke/opennms/).

This project was roughly based on the [sameersbn/gitlab](https://registry.hub.docker.com/u/sameersbn/gitlab/) project.

The scripts/init script is aware of a postgres linked container named `db` through the environment variables:

    DB_PORT_5432_TCP_ADDR
    DB_PORT_5432_TCP_PORT

Its recommended to use an image that allows you to create a database via environmental variables at docker run, like `paintedfox / postgresql`, so the db is populated when this script runs.

If `paintedfox / postgreql` is used, for example, the following environment variables will also be auto-inherited when the container is linked with the name `db`.

    DB_ENV_DB
    DB_ENV_USER
    DB_ENV_PASS

The above variables are also used instead of the defaults if they are available.

If you do not link a database container, a built-in postgresql database will be started.
There is an exported docker volume of /var/lib/postgresql to allow persistence of that postgresql database.

Additionally, the database variables may be overridden from the above using:

    PG_HOST
    PG_PORT

This script will create and run database migrations which should be idempotent.

This idempotent seeding initially defines the "admin" user with a default password of "admin" as per the standard OpenNMS documentation.

The CMD launches Huginn via the scripts/init script. This may become the ENTRYPOINT later.  It does take about a minute for OpenNMS to come up.  Use environmental variables that match your DB's creds to ensure it works.

## Usage

Simple stand-alone usage:

    docker run -it -p 8980:8980 ianblenke/opennms

To link to another postgresql container, for example:

    docker run --rm --name postgresql -p 5432 -e USER=opennms -e PASS=verysecretpassword -e DB=opennms paintedfox/postgresql
    docker run --rm --name huginn --link postgresql:db -p 8980:8980 ianblenke/opennms

Then visit the website in your browser:

    http://localhost:8980

The default initial login is `admin`, and password is `admin`.

## Environment Variables

As mentioned above, there are a few key environment variables that default to a locally running postgresql server, but may be changed:

    PG_HOST=${PG_HOST:-${DB_PORT_5432_TCP_ADDR:-localhost}}
    PG_PORT=${PG_PORT:-${DB_PORT_5432_TCP_PORT:-5432}}
    PG_DATABASE=${PG_DATABASE:-${DB_ENV_DB:-opennms}}
    PG_USER=${PG_USER:-${DB_ENV_USER:-postgres}}
    PG_PASS="${PG_PASS:-${DB_ENV_PASS:-}}"

Note: if you specify a password above, the OpenNMS `ip_like.sh` script will error out, as it assumes that the `pg_hba.conf` database config has been opened up to "trust" anything that connects to it. This means that `ip_like.sh` only works when the built-in postgres database is used, and will obviously not work with a linked postgres container such as `paintedfox / postgreql`.

## Building on your own

The JDBC connection pooling has a few configurable knobs using environment variables:

    <connection-pool factory="${JDBC_CONNECTION_FACTORY:-org.opennms.core.db.C3P0ConnectionFactory}"
     idleTimeout="${JDBC_IDLE_TIMEOUT:-600}"
     loginTimeout="${JDBC_LOGIN_TIMEOUT:-3}"
     minPool="${JDBC_MIN_POOL:-10}"
     maxPool="${JDBC_MAX_POOL:-50}"
     maxSize="${JDBC_MAX_SIZE:-500}" />

You don't need to do this on your own, because there is an [automated build](https://registry.hub.docker.com/u/ianblenke/opennms/) for this repository, but if you really want:

    docker build --rm=true --tag={yourname}/opennms .

## Source

The source is [available on GitHub](https://github.com/ianblenke/docker-opennms/).

Please feel free to submit pull requests and/or fork at your leisure.

