/* 
 Frame rollout
 All other rollouts are added to this rollout as subRollouts
*/

fileIn "data.mse"
fileIn "importer_ui.mse"
fileIn "exporter_ui.mse"
fileIn "info_ui.mse"
fileIn "license_ui.mse"

struct BatchExportImport
(
	public
	
	rollBatchExportImport,
	
	function Constructor =
	(
		if (_data == undefined) do _data = DataObject()

		rollout rollBatchExportImport "Temp"
		(
			local import = ImportRollout()
			local export = ExportObjectsRollout()
			local exportFiles = ExportFilesRollout()
			local info = InfoRollout()
			local license = LicenseRollout()
			
			local rollArr = #(
					#("          Import          ",#(import.roll)),
					#("          Export          ",#(export.roll,exportFiles.roll)),
					#("  Info  ",#(info.roll, license.roll))
				)
			
			local lastSubRollout = 1
			
			dotNetControl dnTabs "System.Windows.Forms.TabControl" height:20 width:420 align:#left
			subRollout theSubRollout width:280 height:390 align:#center
			
			on dnTabs Selected itm do
			(
				for subroll in rollArr[lastSubRollout][2] do
					removeSubRollout theSubRollout subroll
				
				lastSubRollout = itm.TabPageIndex+1
				for subroll in rollArr[lastSubRollout][2] do	
					addSubRollout theSubRollout subroll
				
				-- Add the extra rollout
				addSubRollout export.roll.subRollAdvancedOptions export.rollAdvancedOptions rolledUp:false
				addSubRollout import.roll.subRollAdvancedOptions import.rollAdvancedOptions rolledUp:false
			
				-- Save the slected tab
				_data.optionSelectedTab.SetValue itm.TabPageIndex
				
			)--end tabs clicked	
			
			on rollBatchExportImport open do
			(
				for aTab in rollArr do
				(
					dnTabs.TabPages.add aTab[1]
				)
				

				-- Select last open tab
				if _data.optionSelectedTab.Value() == 0 then
				(
					for subroll in rollArr[1][2] do	
						addSubRollout theSubRollout subroll
					
					addSubRollout import.roll.subRollAdvancedOptions import.rollAdvancedOptions rolledUp:false
				) 
				else 
					dnTabs.SelectTab (_data.optionSelectedTab.Value())
				
			)-- end roll open
		)
		return true
	),
	-- Show this rollout
	function Show =
	(
		createDialog rollBatchExportImport 280 425 style:#(#style_toolwindow,#style_sysmenu)
		
		-- Set the title of the rollout
		titleLabel = "Batch Export/Import v04.12"
		if (_data.optionCommercial.value()) then titleLabel += " (Commercial)"
		else titleLabel += " (Non Commercial)"

		rollBatchExportImport.title = titleLabel
	),
	-- Constructor function will be executed when this struct is created.
	init = Constructor()
) -- End struct BatchExportImport
