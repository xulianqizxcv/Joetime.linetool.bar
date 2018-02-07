-- Run the batch export importer. This method will be called from the button
-- To create a new mzp, run create.ms

fileIn "exporter_ui.mse"

fn ExportSelected =
(
    local exportObjectRollout = ExportObjectsRollout()
    local e = Exporter()
    e.ExportSelectedObjects()
    exportObjectRollout.roll.ShowResultDialog e
)

ExportSelected()