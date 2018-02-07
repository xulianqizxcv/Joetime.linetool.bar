macroScript openBatchExporterImporterExportSelected
	category:"Batch Exporter Importer" 
	toolTip:"Batch Exporter Importer - Export Selected" 
	buttonText:"Batch Export Selected"
	icon:#("BatchExporterImporter", 2)
(

	on execute do
	(
		if BatchExporterImporter == undefined then
		(
			local run_file = (getDir #userScripts) + "/batchexporterimporter/run_export_selected.mse"
			fileIn run_file
		)
		else
		(
			BatchExporterImporter.Show()
		)
	)
)