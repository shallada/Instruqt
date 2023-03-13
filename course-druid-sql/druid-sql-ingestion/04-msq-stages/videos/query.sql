INSERT INTO wiki_stages

WITH langs AS (
  SELECT *
  FROM TABLE(
    EXTERN(
      '{"type": "local", "baseDir": "/root", "filter": "langs.json"}',
      '{"type": "json"}',
      '[{"name": "channel", "type": "string"}, {"name": "language", "type": "string"}]'
    )
  )
),

wiki AS (
  SELECT *
  FROM TABLE(
    EXTERN(
      '{"type": "http", "uris": ["https://static.imply.io/gianm/wikipedia-2016-06-27-sampled.json"]}',
      '{"type": "json"}',
      '[{"name": "added", "type": "long"}, {"name": "channel", "type": "string"}, {"name": "cityName", "type": "string"}, {"name": "comment", "type": "string"}, {"name": "commentLength", "type": "long"}, {"name": "countryIsoCode", "type": "string"}, {"name": "countryName", "type": "string"}, {"name": "deleted", "type": "long"}, {"name": "delta", "type": "long"}, {"name": "deltaBucket", "type": "string"}, {"name": "diffUrl", "type": "string"}, {"name": "flags", "type": "string"}, {"name": "isAnonymous", "type": "string"}, {"name": "isMinor", "type": "string"}, {"name": "isNew", "type": "string"}, {"name": "isRobot", "type": "string"}, {"name": "isUnpatrolled", "type": "string"}, {"name": "metroCode", "type": "string"}, {"name": "namespace", "type": "string"}, {"name": "page", "type": "string"}, {"name": "regionIsoCode", "type": "string"}, {"name": "regionName", "type": "string"}, {"name": "timestamp", "type": "string"}, {"name": "user", "type": "string"}]'
    )
  )
  LIMIT 100
)

SELECT
  FLOOR(TIME_PARSE(wiki."timestamp") TO HOUR) AS __time,
  wiki.page,
  wiki."channel",
  langs."language",
  SUM(wiki.added) sum_added,
  SUM(wiki.deleted) sum_deleted
FROM wiki
LEFT JOIN langs ON wiki.channel = langs.channel
GROUP BY 1,2,3,4
PARTITIONED BY DAY
CLUSTERED BY "page"
