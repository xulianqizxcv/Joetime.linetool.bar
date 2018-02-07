macroScript openBatchExporterImporter 
	category:"Batch Exporter Importer" 
	toolTip:"Open the Batch Exporter/Importer" 
	buttonText:"Batch Exporter Importer"
	icon:#("BatchExporterImporter", 1)
(

	on execute do
	(
		if BatchExporterImporter == undefined then
		(
			local run_file = (getDir #userScripts) + "/batchexporterimporter/run.mse"
			fileIn run_file
		)
		else
		(
			BatchExporterImporter.Show()
		)
	)
)