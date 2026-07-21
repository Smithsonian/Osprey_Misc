# transcription qc fill

A bug in the web app caused the transcription qc to use the `qc_settings` table to get the sample size for QC of each folder. It was supposed to be `transcription_qc_settings`. This script fills the rest of the sample to allow the staff to continue the QC in each folder and not have to restart them.
