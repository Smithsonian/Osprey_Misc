# Osprey Database — Table Reference

Database: `dpo_osprey` (MySQL/InnoDB). Source: [osprey_database_structure.sql](osprey_database_structure.sql) (DDL export, 2026-06-17), 58 tables.

Osprey tracks digitization work for the Smithsonian Digitization Program Office: projects contain **folders**, folders contain **files** (images), and each file accumulates checks, checksums, EXIF, sizes, post-processing results, and QC decisions. A parallel set of `transcription_*` tables mirrors that pipeline for transcription deliverables. The rest of the schema covers statistics, reporting, invoicing, DAMS integration, and per-project one-offs.

The `*_uid` / `*_transcription_id` columns are UUID strings used as public-facing identifiers, alongside the integer autoincrement primary keys used internally.

---

## Core pipeline

| Table | What it is for |
|---|---|
| `projects` | Master record for every digitization project: title, alias, unit, manager, dates, status, project type/method, which file checks and post-processing steps apply, DAMS project code, and display/statistics flags. Nearly everything else keys off `project_id`. |
| `folders` | A delivery/batch folder inside a project. Holds the folder path, capture date, processing status, DAMS delivery state (`delivered_to_dams`), error info, sensitive-content flag, preview state, and cached file counts (`no_files_total`, `no_files_errors`, `no_files_ok`). |
| `files` | One row per digitized file: name, extension, folder, capture timestamp, DAMS UAN (unique asset name once ingested), preview image path, and sensitive-content flag. Unique on (`file_name`, `folder_id`). |
| `files_checks` | Results of the automated validation checks run on each file — one row per (file, check). `file_check` is the check name (`raw_pair`, `magick`, `jhove`, `tifpages`, `unique_file`, `valid_name`, `prefix`, `sequence`, `tesseract`, …), `check_results` the pass/fail code, `check_info` the detail message. This is the largest operational table. |
| `file_postprocessing` | Results of post-processing steps applied after checks pass (one row per file/step), with step name, result code, and notes. |
| `file_md5` | MD5 checksum per file and file type (`tif`, `raw`, …), used to verify transfers against the vendor/DAMS checksums. |
| `files_size` | File size per file and file type. |
| `files_exif` | Full EXIF/technical metadata extracted from each file, stored one tag per row (`tag`, `taggroup`, `tagid`, `value`). Very high row volume. |
| `files_links` | Extra hyperlinks attached to an individual file (label, URL, notes, aria text) shown in the dashboard. |
| `folders_md5` | Per-folder checksum-manifest tracking (`md5_type` distinguishes the manifest kind), used to confirm the folder's MD5 file matches its contents. |
| `folders_badges` | UI badges displayed on a folder in the dashboard (`badge_type` e.g. `verification`, `no_files`; plus CSS class and text). Keyed by `folder_id` for regular folders and by `folder_uid` = `folder_transcription_id` for transcription folders. |
| `folders_links` | Extra hyperlinks attached to a folder. |
| `folders_cleanup` | Housekeeping state for folders whose working copies can be removed: whether the folder is linked to IDs and whether Osprey previews were already deleted. |
| `sensitive_contents` | Per-file sensitive-content determinations made by a user, with optional override and explanatory note. Complements the `sensitive_contents` flag on `files`/`folders`. |

## Quality control (images)

| Table | What it is for |
|---|---|
| `qc_settings` | Per-project QC sampling configuration: QC level (Normal/Reduced/Tightened), the sampling percentage for each level, and the critical/major/minor defect thresholds. |
| `qc_projects` | Which users are assigned as QC reviewers for which projects. |
| `qc_folders` | A QC pass over a folder: status, reviewer (`qc_by` → `users`), reviewer IP, notes, and the QC level in force. |
| `qc_files` | The per-file QC decision inside a folder review (pass/fail code, reviewer, IP, notes). |

## Transcription pipeline

Mirrors the folder/file/check/QC structure above for transcription deliverables (e.g. vendor-supplied transcriptions). Records are joined by the UUID keys `folder_transcription_id` and `file_transcription_id`.

| Table | What it is for |
|---|---|
| `transcription_folders` | Transcription equivalent of `folders`: batch folder per project with status, DAMS delivery state, counts, and errors. |
| `transcription_files` | Transcription equivalent of `files`: file name/extension, size, DAMS UAN, preview image, timestamps. |
| `transcription_files_checks` | Automated check results per transcription file (same shape as `files_checks`). |
| `transcription_files_text` | The transcribed content itself — one row per (file, field), with the text, notes, and a validation state. |
| `transcription_files_links` | Extra hyperlinks attached to a transcription file. |
| `transcription_sources` | The source/batch a set of transcriptions came from (name, notes, date) for a project — e.g. a vendor delivery. |
| `transcription_fields` | The field definitions a source transcribes (field name, sort order, per-field cost, notes). Feeds invoicing and the transcription display. |
| `transcription_qc_settings` | Per-project QC sampling configuration for transcription review (same columns as `qc_settings`). |
| `transcription_qc_folders` | A QC pass over a transcription folder (status, reviewer, IP, notes, level). |
| `transcription_qc` | The per-file transcription QC result within a folder/source review. |
| `folders_transcription` | Older duplicate of `transcription_folders` (same columns, plus a `transcription_text` column). Not referenced by the current web app — legacy. |
| `transcript_test` | Scratch table comparing transcribed field values against a reference and the Alembo vendor output. Ad-hoc/testing, not used by the app. |

## Statistics and reporting

| Table | What it is for |
|---|---|
| `projects_stats` | One cached summary row per project driving the dashboards: collection totals, objects digitized, images taken, images in DAMS/CIS/public, record counts in CIS, CollexWeb, collections.si.edu and GBIF, plus a configurable "other" statistic and OK/error totals. |
| `projects_stats_detail` | Time-series breakdown of objects digitized and images captured per project, per interval (day/week/month) and date. |
| `projects_detail_statistics` | Raw per-event rows for the detailed project statistics pages: date, step, and file name. Very high row volume. |
| `projects_detail_statistics_steps` | Defines the steps shown on those detail statistics pages — label, order, units, notes, rendering type, rounding, CSS class, active flag. |
| `general_stats` | Program-wide (not per-project) image and object counts by interval and date. Not referenced by the current web app. |
| `data_reports` | Definitions of the canned reports available per project: title, the SQL for the report, an API variant, a "last updated" query, an alias for the URL, and whether the report is pregenerated nightly to a file. |
| `dates_table` | Calendar lookup table (date, weekday name, holiday flag) for filling gaps in date-series reporting. Not referenced by the current web app. |

> Note: `scripts/` and `db/report_materializations.sql` add a `report_materializations` table for nightly pregenerated-report tracking. It is applied by hand and is **not** part of this DDL export.

## Users and API access

| Table | What it is for |
|---|---|
| `users` | Web app accounts: username, full name, password hash, email, active and admin flags, and whether the user is internal. Referenced by QC assignments and reviews. |
| `api_keys` | API keys issued to worker processes and integrations: key, owner, expiry, rate limit, admin and active flags. |
| `api_keys_usage` | API request log per key (URL, parameters, timestamp, whether the request validated). |

## DAMS integration

| Table | What it is for |
|---|---|
| `dams_vfcu_file_view_dpo` | Local copy of the DAMS VFCU (file upload) view: media file id, project code, file name, pickup location, and checksum. Used to confirm files reached DAMS with matching checksums. |
| `dams_cdis_file_status_view_dpo` | Local copy of the DAMS CDIS ingest status view: media file id, file name, project code, assigned DAMS UAN, and ingest date. Used to match Osprey files to their ingested DAMS assets. |

Both are snapshots refreshed from DAMS (named `..._view_...` but stored as ordinary tables here).

## Lookups and program metadata

| Table | What it is for |
|---|---|
| `si_units` | Smithsonian unit code → full unit name (e.g. `NMNH`). Joined to `projects.project_unit` for display. |
| `projects_settings` | Per-project key/value settings, most importantly which file checks and post-processing steps are enabled (`project_setting` = `project_checks` / `project_postprocessing`, `settings_value` = the check name). |
| `projects_links` | Additional links shown on a project page (videos, articles) with a type and title. |
| `projects_informatics` | Separate catalogue of informatics (non-imaging) projects for the informatics dashboard: title, unit, summary, record counts, PM, dates, website/GitHub links, status. Independent of the `projects` table. |
| `informatics_software` | Catalogue of software produced by the informatics program: name, details, repository, more-info link, sort order. |

## Invoicing and reconciliation

| Table | What it is for |
|---|---|
| `invoice_recon` | Reconciliation workspace for imaging invoices: a batch of vendor-supplied file names (grouped by `randomint`) matched against Osprey `file_id` and DAMS UAN so billed items can be verified. |
| `invoice_recon_transcription` | Same reconciliation workflow for transcription invoices, matching file names to `file_transcription_id` within a project. |
| `invoice_alembo_binary` | Imported per-image invoice detail from the Alembo transcription vendor: batch identifiers plus a 0/1 column per transcribed field (locality, country, collector, date, type status, sex, …) indicating what was captured. Staging/import table. |
| `invoice_alembo_values` | Price list backing those invoices: category, quantity, unit price, total. Staging/import table. |

## Project-specific tables

| Table | What it is for |
|---|---|
| `jpc_aspace_data` | ArchivesSpace archival-object metadata for the JPC Archive project: resource id, RefID, box/folder, type, unit title, URL, scope/content, content warnings. File name RefIDs are validated against this table by the JPCA file checks. |
| `jpc_aspace_resources` | ArchivesSpace resource (collection) records for JPC: resource id, repository, title, tree. |
| `jpc_aspace_data_1`, `jpc_aspace_resources1` | Older copies/backups of the two tables above. Not referenced by the current web app. |
| `jpc_aspace_boxes` | Mapping between JPC project folder names, box numbers, and archive box numbers. |
| `jpc_massdigi_ids` | Generic identifier crosswalk for JPC/mass-digitization work: an `id_relationship` label plus the two identifier values being linked, optionally tied to a folder. |
| `ento_pollinators_data` | Specimen-level data from the NMNH Entomology pollinators conveyor project, keyed by specimen barcode: drawer/tray/unit-tray ids, insect id, image count, size, damage and label conditions, who digitized it and when. |
| `external_data` | Generic key/value staging table for data pulled in from outside systems (`dataset_key` plus two values). Large; not referenced by the current web app. |

---

## Relationship summary

```
projects ─┬─ folders ─┬─ files ─┬─ files_checks
          │           │         ├─ file_postprocessing
          │           │         ├─ file_md5 / files_size / files_exif / files_links
          │           │         ├─ qc_files
          │           │         └─ sensitive_contents
          │           ├─ folders_md5 / folders_badges / folders_links / folders_cleanup
          │           └─ qc_folders
          ├─ transcription_folders ─ transcription_files ─┬─ transcription_files_checks
          │                                               ├─ transcription_files_text
          │                                               ├─ transcription_files_links
          │                                               └─ transcription_qc
          ├─ projects_settings / projects_links / projects_stats / projects_stats_detail
          ├─ data_reports
          ├─ qc_settings / qc_projects / transcription_qc_settings
          └─ transcription_sources ─ transcription_fields
```

Most child tables use `ON DELETE CASCADE`, so deleting a project removes its folders, files, and all dependent rows.
