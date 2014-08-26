OpenNMS for docker with multiple container linkage
=================================================

This image runs a linkable [OpenNMS](https://http://www.opennms.org/)

There is an automated build repository on docker hub for [ianblenke/docker-opennms](https://registry.hub.docker.com/builds/github/ianblenke/docker-opennms/).

This project was roughly based on the [sameersbn/gitlab](https://registry.hub.docker.com/u/sameersbn/gitlab/) project.

The scripts/init script is aware of a postgres linked container through the environment variables:

    POSTGRESQL_PORT_5432_TCP_ADDR
    POSTGRESQL_PORT_5432_TCP_PORT

Its recommended to use an image that allows you to create a database via environmental variables at docker run, like `paintedfox / postgresql`, so the db is populated when this script runs.

If you do not link a database container, a built-in postgresql database will be started.
There is an exported docker volume of /var/lib/postgresql to allow persistence of that postgresql database.

Additionally, the database variables may be overridden from the above using:

    PG_HOST
    PG_PORT

This script will create and run database migrations which should be idempotent.

This same seeding initially defines the "admin" user with a default password of "admin" as per the standard OpenNMS documentation.

The CMD launches Huginn via the scripts/init script. This may become the ENTRYPOINT later.  It does take about a minute for OpenNMS to come up.  Use environmental variables that match your DB's creds to ensure it works.

## Usage

Simple stand-alone usage:

    docker run -it -p 8980:8980 ianblenke/opennms

To link to another postgresql container, for example:

    docker run --rm --name postgresql -p 5432 paintedfox/postgresql
    docker run --rm --name huginn --link postgresql:POSTGRESQL -p 8980:8980 ianblenke/opennms

## Building on your own

You don't need to do this on your own, because there is an [automated build](https://registry.hub.docker.com/u/ianblenke/opennms/) for this repository, but if you really want:

    docker build --rm=true --tag={yourname}/opennms .

## Source

The source is [available on GitHub](https://github.com/ianblenke/docker-opennms/).

Please feel free to submit pull requests and/or fork at your leisure.

