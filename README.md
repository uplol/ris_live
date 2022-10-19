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

## Example Queries

### Updates in the last hour for a given prefix (all RIPE RRC hosts)

```sql
WITH
    flatten(announcements.prefixes) AS prefixes,
    has(prefixes, '1.0.0.0/24') AS found
SELECT
    host,
    timestamp,
    originating_asn,
    path,
    announcements.prefixes,
    announcements.next_hop
FROM ris_live
WHERE (found = 1) AND (timestamp > (now() - toIntervalHour(1)))
ORDER BY
    timestamp DESC,
    host ASC
LIMIT 20;
```

### Number of updates that impacted a given IP Address (all RIPE RCC Hosts)

```sql
WITH
    flatten(announcements.prefixes) AS prefixes,
    arrayExists(prefix -> isIPAddressInRange('1.1.1.1', prefix), prefixes) AS found
SELECT count() AS c
FROM ris_live
WHERE found = 1;
```

### Top 20 ASNs that sent out updates in the last 10 minutes (as seen by a particular RIPE RCC Host)

```sql
SELECT
    originating_asn,
    count() AS c
FROM ris_live
WHERE (originating_asn != 0) AND (host = 'rrc12.ripe.net') AND (timestamp > (now() - toIntervalMinute(10)))
GROUP BY originating_asn
ORDER BY c DESC
LIMIT 20;
```

### Top 20 most updated prefixes in the last 10 minutes (as seen by a particular RIPE RCC Host)

```sql
SELECT
    arrayJoin(arrayJoin(announcements.prefixes)) AS prefix,
    count() AS c
FROM ris_live
WHERE timestamp > (now() - toIntervalMinute(10)) AND (host = 'rrc01.ripe.net')
GROUP BY prefix
ORDER BY c DESC
LIMIT 20;
```
