-- Run the batch export importer. This method will be called from the button
-- To create a new mzp, run create.ms

fileIn "main_ui.mse"

BatchExporterImporter = BatchExportImport()
BatchExporterImporter.Show()