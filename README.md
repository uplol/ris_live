# RIS Live Ingestor

> **Warning**
> 
> Only intended to serve as a simple POC

Example pipeline to ingest [RIS Live](https://ris-live.ripe.net/) BGP messages into [Clickhouse](https://clickhouse.com/) using [Vector](https://vector.dev/)

## Requirements

- Clickhouse
- Python3
- Vector

## Example Pipeline

Setup tables and materialized view:

```bash
clickhouse-client --queries-file ./sql/clickhouse.sql
```

Ingest and process messages:

```bash
python ris_live.py | vector --config-toml ./vector/vector.toml
```
