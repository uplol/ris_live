# Ingestor

> **Warning**
> 
> Only intended to server as a simple POC

Example pipeline to ingest [RIS Live](https://ris-live.ripe.net/) BGP messages into [Clickhouse](https://clickhouse.com/) using [Vector](https://vector.dev/)

## Example Pipeline

Setup tables and materialized view:

`clickhouse-client --queries-file ./sql/clickhouse.sql`

Ingest and process messages:

`python ris_live.py | vector --config-toml ./vector/vector.toml`
