---
name: strava-activity-import
description: Use when adding a Strava activity record to activities.sqlite from FIT, GPX, or Garmin TCX files, including requests to interpret an activity export or reconcile Strava and Garmin activity data.
---

# Strava Activity Import

Add one activity to an existing Strava `activities.sqlite` database using the
supplied activity files. The SQLite database is the sole activity index; do not
expect, read, create, or modify `activities.csv`. Prefer actual source values and
store unavailable Strava-only fields as empty strings. Do not fabricate weather,
relative effort, grade-adjusted distance, gear, description, media, or private
notes.

Before constructing a record, read
[`references/activities-sqlite.md`](references/activities-sqlite.md). Resolve the
user-provided database location and use its `activity_columns` table as the
authoritative source-header mapping. The expected relative layout is
`(location)/activities.sqlite` plus
`(location)/activities/{activity_id}.{fit,gpx,tcx,tcx.gz,fit.gz}`; the storage
provider is intentionally unspecified.

## Workflow

1. Open `activities.sqlite` and inspect `activity_columns` before constructing
   the record. It defines the source-header-to-unique-database-column mapping.
   Verify that `activities` has the required columns and that all non-ID values
   use `TEXT` storage. Do not infer column names from a CSV header.
2. Inspect all supplied files. Treat Garmin TCX as the preferred source for lap
   totals, time, distance, calories, heart rate, speed, cadence, watts, and
   elevation samples. Use Strava GPX to confirm activity name, activity type,
   timestamps, and track consistency. Read FIT when a compatible local decoder
   is available; never modify or convert source files.
3. Derive values only when required by the SQLite schema and directly supported by the
   samples:
   - `Elapsed Time`: first-to-last recorded timestamp; use TCX lap total only
     when it represents the full elapsed duration.
   - `Moving Time`: sum TCX lap `TotalTimeSeconds` values.
   - `Distance`: final TCX cumulative distance, in metres; the leading summary
     distance is kilometres rounded to two decimals.
   - Heart rate, cadence, watts, calories, speed, and elevation: use source
     summary values when present. Otherwise calculate simple time-sample means
     and maxima from TCX points, clearly using only available values.
   - Elevation gain/loss: derive from track elevations with modest distance
     sampling to reduce GPS noise. Do not use raw one-second altitude changes
     without smoothing.
   - Unix `Start Time`: UTC epoch seconds from the first timestamp.
   - `Average Elapsed Speed`: distance divided by elapsed time.
   - `Total Steps`: only populate when cadence is available; estimate as
     `2 * sum(run cadence) / 60` for one-second samples, rounded to an integer.
4. Use `Run` for GPX `trail_running` and Garmin `Running` activities unless the
   export establishes a more specific existing convention. Use the GPX track
   name as the activity name.
5. Set `from_upload` to `1.0` for a manually reconstructed export row. Set both
   commute columns (`commute` and `detailed_commute`) to `false` unless source
   data says otherwise. Set `prefer_perceived_exertion` to `0.0` when matching
   contemporary rows.
6. If `activities/<strava-id>.gpx` exists, reference it in `Filename`. Do not
   copy temporary source files into `activities/` unless explicitly requested.
7. Insert exactly one record in a SQLite transaction. Use the supplied Strava ID
   for both `activity_id` (INTEGER) and `activity_id_text` (its original decimal
   lexeme). Set `import_order` to `MAX(import_order) + 1`; it is insertion history,
   not chronological order. Store every non-ID value as its exact source decimal
   or text lexeme; never bind floating-point values.
8. Roll back on any error. After committing, verify the inserted row by
   `activity_id`, confirm all stored values match the constructed record exactly,
   and confirm `COUNT(DISTINCT activity_id)` remains equal to `COUNT(*)`.
   Query chronological results with `ORDER BY CAST(start_time AS INTEGER) DESC`,
   not `import_order`. Report the key interpreted values, inferred values, and
   fields intentionally left empty.

## Safety

- Never overwrite an existing row with the same Activity ID. Stop and report it.
- Never modify other activity rows, source activity files, or media.
- Never create or modify `activities.csv`.
- Preserve unrelated worktree changes.
