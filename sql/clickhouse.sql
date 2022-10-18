create database if not exists bgp;

create table if not exists bgp.ris_live_queue
(
    data String
)
ENGINE = Null;

create table if not exists bgp.ris_live
(
    aggregator Nullable(String),
    announcements Nested(
        next_hop String,
        prefixes Array(String)
    ),
    as_set Array(Int32), --
    community Array(Array(Nullable(UInt32))),
    host String,
    id String,
    med Nullable(UInt32),
    origin Nullable(String),
    originating_asn UInt32, --
    path Array(Nullable(UInt32)),
    peer String,
    peer_asn String,
    timestamp DateTime64,
    type LowCardinality(String),
    withdrawals Array(Nullable(String))
)
ENGINE = MergeTree()
ORDER BY (timestamp, id);

create materialized view if not exists bgp.ris_live_mv to bgp.ris_live
as select
    JSONExtractArrayRaw(data, 'announcements') as announcements_,
    arrayMap(c -> (JSONExtractArrayRaw(c, 'prefixes')), announcements_) prefixes_,
    arrayMap(c -> (JSONExtractString(c, 'next_hop')), announcements_) as `announcements.next_hop`,
    arrayMap(a -> (arrayMap(b ->(trim(BOTH '"' FROM b)), a)), prefixes_) as `announcements.prefixes`,
    JSONExtractString(data, 'aggregator') as aggregator,
    JSONExtractArrayRaw(data, 'as_set')::Array(UInt32) as as_set,
    arrayMap(c -> (c::Array(UInt32)), JSONExtractArrayRaw(data, 'community')) as community,
    JSONExtractString(data, 'host') as host,
    JSONExtractString(data, 'id') as id,
    JSONExtractUInt(data, 'med') as med,
    JSONExtractString(data, 'origin') as origin,
    JSONExtractArrayRaw(data, 'path')::Array(UInt32) as path,
    path[-1] as originating_asn,
    JSONExtractString(data, 'peer') as peer,
    JSONExtractString(data, 'peer_asn') as peer_asn,
    JSONExtractString(data, 'timestamp') as timestamp,
    JSONExtractString(data, 'type') as type,
    JSONExtractArrayRaw(data, 'withdrawals') as withdrawals
from bgp.ris_live_queue;
