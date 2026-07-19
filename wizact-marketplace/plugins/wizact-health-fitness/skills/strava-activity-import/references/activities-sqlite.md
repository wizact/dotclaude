# `activities.sqlite` reference

This reference describes the SQLite database expected by
`strava-activity-import`. The database location is user-provided and may be a
local path, mounted volume, object-store download, or another accessible
filesystem location. Do not assume a particular storage provider.

## Expected relative layout

Treat `(location)` as the directory containing the database:

```text
(location)/activities.sqlite
(location)/activities/{activity_id}.{fit,gpx,tcx,tcx.gz,fit.gz}
```

The activity files are source evidence; the SQLite database is the sole activity
index. A compressed source file may be read through a decompressor, but the
original file must not be modified. If the matching
`activities/{activity_id}.gpx` exists, store its relative path in `filename`.

## Tables and constraints

The database contains two tables:

```sql
CREATE TABLE activity_columns (
  position INTEGER PRIMARY KEY,
  source_header TEXT NOT NULL,
  database_column TEXT NOT NULL UNIQUE
);

CREATE TABLE activities (
  activity_id INTEGER PRIMARY KEY,
  import_order INTEGER NOT NULL UNIQUE,
  activity_id_text TEXT NOT NULL,
  activity_date TEXT NOT NULL,
  activity_name TEXT NOT NULL,
  activity_type TEXT NOT NULL,
  activity_description TEXT NOT NULL,
  elapsed_time TEXT NOT NULL,
  distance TEXT NOT NULL,
  max_heart_rate TEXT NOT NULL,
  relative_effort TEXT NOT NULL,
  commute TEXT NOT NULL,
  activity_private_note TEXT NOT NULL,
  activity_gear TEXT NOT NULL,
  filename TEXT NOT NULL,
  athlete_weight TEXT NOT NULL,
  bike_weight TEXT NOT NULL,
  detailed_elapsed_time TEXT NOT NULL,
  moving_time TEXT NOT NULL,
  detailed_distance TEXT NOT NULL,
  max_speed TEXT NOT NULL,
  average_speed TEXT NOT NULL,
  elevation_gain TEXT NOT NULL,
  elevation_loss TEXT NOT NULL,
  elevation_low TEXT NOT NULL,
  elevation_high TEXT NOT NULL,
  max_grade TEXT NOT NULL,
  average_grade TEXT NOT NULL,
  average_positive_grade TEXT NOT NULL,
  average_negative_grade TEXT NOT NULL,
  max_cadence TEXT NOT NULL,
  average_cadence TEXT NOT NULL,
  detailed_max_heart_rate TEXT NOT NULL,
  average_heart_rate TEXT NOT NULL,
  max_watts TEXT NOT NULL,
  average_watts TEXT NOT NULL,
  calories TEXT NOT NULL,
  max_temperature TEXT NOT NULL,
  average_temperature TEXT NOT NULL,
  detailed_relative_effort TEXT NOT NULL,
  total_work TEXT NOT NULL,
  number_of_runs TEXT NOT NULL,
  uphill_time TEXT NOT NULL,
  downhill_time TEXT NOT NULL,
  other_time TEXT NOT NULL,
  perceived_exertion TEXT NOT NULL,
  type TEXT NOT NULL,
  start_time TEXT NOT NULL,
  weighted_average_power TEXT NOT NULL,
  power_count TEXT NOT NULL,
  prefer_perceived_exertion TEXT NOT NULL,
  perceived_relative_effort TEXT NOT NULL,
  detailed_commute TEXT NOT NULL,
  total_weight_lifted TEXT NOT NULL,
  from_upload TEXT NOT NULL,
  grade_adjusted_distance TEXT NOT NULL,
  weather_observation_time TEXT NOT NULL,
  weather_condition TEXT NOT NULL,
  weather_temperature TEXT NOT NULL,
  apparent_temperature TEXT NOT NULL,
  dewpoint TEXT NOT NULL,
  humidity TEXT NOT NULL,
  weather_pressure TEXT NOT NULL,
  wind_speed TEXT NOT NULL,
  wind_gust TEXT NOT NULL,
  wind_bearing TEXT NOT NULL,
  precipitation_intensity TEXT NOT NULL,
  sunrise_time TEXT NOT NULL,
  sunset_time TEXT NOT NULL,
  moon_phase TEXT NOT NULL,
  bike TEXT NOT NULL,
  gear TEXT NOT NULL,
  precipitation_probability TEXT NOT NULL,
  precipitation_type TEXT NOT NULL,
  cloud_cover TEXT NOT NULL,
  weather_visibility TEXT NOT NULL,
  uv_index TEXT NOT NULL,
  weather_ozone TEXT NOT NULL,
  jump_count TEXT NOT NULL,
  total_grit TEXT NOT NULL,
  average_flow TEXT NOT NULL,
  flagged TEXT NOT NULL,
  average_elapsed_speed TEXT NOT NULL,
  dirt_distance TEXT NOT NULL,
  newly_explored_distance TEXT NOT NULL,
  newly_explored_dirt_distance TEXT NOT NULL,
  activity_count TEXT NOT NULL,
  total_steps TEXT NOT NULL,
  carbon_saved TEXT NOT NULL,
  pool_length TEXT NOT NULL,
  training_load TEXT NOT NULL,
  intensity TEXT NOT NULL,
  average_grade_adjusted_pace TEXT NOT NULL,
  timer_time TEXT NOT NULL,
  total_cycles TEXT NOT NULL,
  recovery TEXT NOT NULL,
  with_pet TEXT NOT NULL,
  competition TEXT NOT NULL,
  long_run TEXT NOT NULL,
  for_a_cause TEXT NOT NULL,
  with_kid TEXT NOT NULL,
  downhill_distance TEXT NOT NULL,
  total_sets TEXT NOT NULL,
  total_reps TEXT NOT NULL,
  media TEXT NOT NULL
);
```

Important implications:

- `activity_id` is the integer primary key. Use the supplied decimal Activity
  ID for it; do not allocate a new ID.
- `activity_id_text` preserves the original Activity ID lexeme as text.
- `import_order` is a required unique insertion sequence. Set it to
  `MAX(import_order) + 1`; it is not a chronological ordering.
- Every other `activities` column is required and has `TEXT` storage. Preserve
  source decimal/text lexemes and bind values as text rather than converting
  them through floating-point types.
- `activity_columns.database_column` is unique, and `position` is its ordered
  source-header position. The table is the authoritative source-header mapping.
- The duplicate source headers are intentional. For example, `Distance` maps
  to both `distance` and `detailed_distance`, while `Commute` maps to both
  `commute` and `detailed_commute`.

## Source-header mapping

Read the mapping from the database before constructing a row:

```sql
SELECT position, source_header, database_column
FROM activity_columns
ORDER BY position;
```

The current mapping has positions `0` through `102` and includes these
important duplicate-header mappings:

| Position | Source header | Database column |
|---:|---|---|
| 0 | Activity ID | `activity_id_text` |
| 5 | Elapsed Time | `elapsed_time` |
| 6 | Distance | `distance` |
| 7 | Max Heart Rate | `max_heart_rate` |
| 8 | Relative Effort | `relative_effort` |
| 9 | Commute | `commute` |
| 15 | Elapsed Time | `detailed_elapsed_time` |
| 17 | Distance | `detailed_distance` |
| 30 | Max Heart Rate | `detailed_max_heart_rate` |
| 37 | Relative Effort | `detailed_relative_effort` |
| 50 | Commute | `detailed_commute` |

Do not infer the remaining mappings from a CSV export or from column order in a
different database. Query this table for the active database instance.

## Verification queries

Before inserting, inspect the schema and reject an incompatible database:

```sql
PRAGMA table_info(activity_columns);
PRAGMA table_info(activities);
SELECT name, sql
FROM sqlite_master
WHERE type IN ('table', 'index', 'view', 'trigger')
ORDER BY type, name;
```

After inserting exactly one row in a transaction, verify it and the uniqueness
invariant:

```sql
SELECT *
FROM activities
WHERE activity_id = ?;

SELECT COUNT(*) AS row_count,
       COUNT(DISTINCT activity_id) AS distinct_activity_ids
FROM activities;

SELECT activity_id, activity_date, activity_name, start_time
FROM activities
ORDER BY CAST(start_time AS INTEGER) DESC;
```

The insert must be rolled back on error. Never overwrite an existing
`activity_id`, modify another activity, or create/modify `activities.csv`.
