/*
 Export objects rollout
*/

fileIn "data.mse"
fileIn "exporter.mse"

struct ExportObjectsRollout
(
	public
	roll,
	rollAdvancedOptions,
	
	-- Constructor function of ExportFilesRollout struct. Called at object creation.
	-- @return (boolean) true
	function Constructor =
	(
		-- Create the data object if doesn't exist. Saved in the global variable _data.
		if (_data == undefined) do	_data = DataObject()
		
		rollout roll "Export Settings"
		(
			checkbox cbxDeleteTurbo offset:[-5,0] across:3 checked:(_data.optionDeleteTurboSmooth.Value()) \
				tooltip:"Delete turboSmooth modifiers on selected objects when exporting \n(will be undone after export)"
			button btnDeleteTurbo "Now" width:50 tooltip:"Delete turboSmooth modifiers on selected objects" offset:[-80,-3]
			label lblInfo2 "Delete turboSmooth" offset:[-85,0] align:#left
				
			checkbox cbxReset offset:[-5,0] across:4 checked:(_data.optionResetObj.Value()) \
				tooltip:"Reset geometry when exporting \n(will be undone after export)"
			button btnReset "Now" width:50 tooltip:"reset geometry now" offset:[-50,-3]
			label lblInfo "Reset geometry (" offset:[-45,0] align:#left
			checkbox chbResetPivot "Pivot)" checked:(_data.optionPivotToOrigin.Value()) offset:[-20,0] \
				tooltip:"Unchecked will the pivot stay at the same location"
			
			checkbox cbxMoveToOrigin across:3 offset:[-5,0] checked:(_data.optionMoveToOrigin.Value())
			button btnMoveToOrigin "Now" width:50 offset:[-80,-3]
			label lblMoveToOrigin "Move objects to [0,0,0]" offset:[-85,0] align:#left
			checkbox chbRotateObj across:5 offset:[-5,0] checked:(_data.optionRotateObj.Value())
			button btnRotateObj "Now" width:50 offset:[-32,-3]
			spinner spnRotateX "Rotate   " range:[-360,360,(_data.optionRotateArr.Value())[1]] type:#integer fieldwidth:30 offset:[14,0]
			spinner spnRotateY range:[-360,360,(_data.optionRotateArr.Value())[2]] type:#integer fieldwidth:30 offset:[12,0]
			spinner spnRotateZ range:[-360,360,(_data.optionRotateArr.Value())[3]] type:#integer fieldwidth:30 offset:[10,0]
			checkbox chbScaleObj across:3 offset:[-5,0] checked:(_data.optionScaleObj.Value())
			button btnScaleObj "Now" width:50 offset:[-80,-3]
			spinner spnScale "Scale     " range:[0.001,1000,(_data.optionScaleValue.Value())] type:#float fieldwidth:35 align:#left offset:[-85,0]
			
			checkbox cbxResetAfter offset:[-5,0] across:4 checked:(_data.optionResetObjAfter.Value()) \
				tooltip:"Reset geometry when exporting \n(will be undone after export)"
			button btnResetAfter "Now" width:50 tooltip:"reset geometry now" offset:[-50,-3]
			label lblInfo3 "Reset geometry after (" offset:[-45,0] align:#left
			checkbox chbResetPivotAfter "Pivot)" checked:(_data.optionPivotToOriginAfter.Value()) offset:[6,0] \
				tooltip:"Unchecked will the pivot stay at the same location"
				
			dropdownlist ddlOutputpath width:230 height:20 items:(_data.optionOutputPath.Value()) tooltip:"" across:2 offset:[-5,0]
			button btnGetFolder "..." width:25 height:20 tooltip:"Browse for folder" offset:[60,0]
			label lblformat "Format" across:2 align:#left
			dropdownlist ddlFormat items:(_data.optionFormat.Value()) selection:1 width:50 align:#left offset:[-80,-3]
			
			subRollout subRollAdvancedOptions width:275 height:140 align:#center
			button btnExportSelection "Export Selection" width:204 height:25 across:2 offset:[35,0]
			button btnExportAll "All" width:50 height:25 offset:[43,0]

			/* Functions */
			function ShowResultDialog exporterInstance =
			(
				message = ""
				if exporterInstance.successes.count > 0 do
				(
					message += "\n-----------------------\nSuccess\n-----------------------\n"
					for m in exporterInstance.successes do
					(
						message += ("\n" + m)
					)
				)
				if exporterInstance.errors.count > 0 do
				(
					message += "\n-----------------------\nErrors\n-----------------------\n"
					for m in exporterInstance.errors do
					(
						message += ("\n" + m)
					)
				)
				
				messageBox message title:"Batch Export" beep:false
			)
			
			/* Callbacks */
			on cbxReset changed state do (_data.optionResetObj.SetValue state)
			on chbResetPivot changed state do (_data.optionPivotToOriginAfter.SetValue state)
			on cbxResetAfter changed state do (_data.optionResetObjAfter.SetValue state)
			on chbResetPivotAfter changed state do (_data.optionPivotToOriginAfter.SetValue state)
			on btnReset pressed do
			(
				e = Exporter()
				undo "Reset selected objects" on (e.ResetObjectOnSelected())
			)
			on btnResetAfter pressed do
			(
				e = Exporter()
				undo "Reset selected objects" on (e.ResetObjectOnSelected())
			)
			on cbxDeleteTurbo changed state do (_data.optionDeleteTurboSmooth.SetValue state)
			on btnDeleteTurbo pressed do
			(
				e = Exporter()
				undo "Delete turboSmooth modifiers on selected" on (e.DeleteTurboSmoothOnSelected())
			)
			on cbxMoveToOrigin changed state do (_data.optionMoveToOrigin.SetValue state)
			on btnMoveToOrigin pressed do
			(
				e = Exporter()
				undo "Move selected to origin" on (e.MoveObjectToOriginOnSelected())
			)
			on btnRotateObj pressed do
			(
				e = Exporter()
				undo "Rotate selected" on (e.RotateObjectOnSelected())
			)
			on btnScaleObj pressed do
			(
				e = Exporter()
				undo "Scale selected" on (e.ScaleObjectOnSelected())
			)
			on btnGetFolder pressed do
			(
				OutputArr = ddlOutputpath.items
				savePath = (getSavePath "Save to:" initialDir:(@"C:\Users\"+sysInfo.username+"\Desktop")) as string
				if (savePath != "undefined") do
				(
					e = Exporter()
					OutputArr = e.InsertItemInArray OutputArr savePath
					-- Set a limit for the array
					if (OutputArr.count > 10) do
					(
						newArr = #()
						for i = 1 to 10 do (newArr[i] = OutputArr[i])
						OutputArr = newArr
					)
					ddlOutputpath.items = OutputArr
					ddlOutputpath.selection = 1
					ddlOutputpath.tooltip = ddlOutputpath.items[1] as string
					_data.optionOutputPath.SetValue OutputArr
				)
			)
			on ddlOutputpath selected arg do
			(
				arr = ddlOutputpath.items
				-- Set the tooltip because the path can be longer than the width of the dropdownlist
				ddlOutputpath.tooltip = arr[arg] as string 
				sel = arr[arg]
				e = Exporter()
				arr = e.InsertItemInArray arr sel
				
				ddlOutputpath.selection = 1
				ddlOutputpath.items = arr
				_data.optionOutputPath.SetValue arr
			)
			on ddlFormat selected arg do
			(
				arr = ddlFormat.items
				sel = arr[arg]
				e = Exporter()
				arr = e.InsertItemInArray arr sel
				
				ddlFormat.selection = 1
				ddlFormat.items = arr
				_data.optionFormat.SetValue arr
			)
			on chbRotateObj changed state do (_data.optionRotateObj.SetValue state)
			on spnRotateX changed value do (arr=_data.optionRotateArr.Value();arr[1]=value;_data.optionRotateArr.SetValue arr)
			on spnRotateY changed value do (arr=_data.optionRotateArr.Value();arr[2]=value;_data.optionRotateArr.SetValue arr)
			on spnRotateZ changed value do (arr=_data.optionRotateArr.Value();arr[3]=value;_data.optionRotateArr.SetValue arr)
			on chbScaleObj changed state do (_data.optionScaleObj.SetValue state)
			on spnScale changed value do (_data.optionScaleValue.SetValue value)
			on btnExportSelection pressed do 
			(
				e = Exporter()
				e.ExportSelectedObjects()
				ShowResultDialog e
			)
			on btnExportAll pressed do (
				e = Exporter()
				if _data.optionExportMode.Value() == 1 then e.ExportAllObjects()
				else if _data.optionExportMode.Value() == 2 then e.ExportAllLayers()
				else messageBox "Export mode not supported"
				ShowResultDialog e
			)
		) -- End rollout roll
		
		rollout rollAdvancedOptions "Advanced"
		(
			label lblExportMode "Mode" across:2 align:#left width:100
			dropdownlist ddlExportMode items:#("Objects To Files","Layers To Files") selection:(_data.optionExportMode.Value()) align:#left width:200 offset:[-75,-2]
			checkbox cbxChangeName "Enable name change" checked:(_data.optionChangeName.Value()) offset:[-5,0]
					tooltip:"change exportname, example:\nhouse_+scene name+_v2" 
			edittext edtPrefix width:75 text:(_data.optionPrefixName.Value()) across:3 offset:[10,0]
			label lblObjectName "+ obj name +" offset:[4,0]
			edittext edtSuffix width:75 text:(_data.optionSuffixName.Value())
			checkbox cbxExportCollision "Combine collisionmesh, string:" offset:[-5,0] checked:(_data.optionCombineCollision.Value()) across:2
				tooltip:"objects with name x and prefix_x/postfix_x in selection will be exported together"
			edittext edtCollisionPrefix width:50 text:(_data.optionCollisionString.Value()) offset:[35,0]
			checkbox chbCombineLODs "Combine LODs, string:" offset:[-5,0] checked:(_data.optionCombineLODs.Value()) across:2 \
				tooltip:"Export meshes with given prefix/postfix (* is numbering) to the same file"
			edittext edtLODPostfix width:60 text:(_data.optionLODString.Value()) offset:[7,0]
			checkbox cbxCollapseGroups "Collapse groups" offset:[-5,0]
				tooltip:"Convert group to editable poly before exporting.\n(will be undone after export)" checked:(_data.optionCollapseGroups.Value())
			checkbox cbxExportOptions "Export options" offset:[-5,0]
				tooltip:"Display export dialog" checked:(_data.optionExportOptions.Value())
			checkbox cbxFBXPreset "FBX Preset" offset:[-5,0]
				tooltip:"Set FBX preset file to specify options. You can find the presets under C:/Users/YOU/Documents/3dsMax/FBX/version/Presets" checked:(_data.optionExportFBXUsePreset.Value()) across:3
			dropdownlist ddlPreset width:150 height:20 items:(_data.optionExportFBXPreset.Value()) 
				tooltip:"Preset file" offset:[-8,0]
			button btnGetPreset "..." width:25 height:20 tooltip:"Browse for preset" offset:[40,0]
			
			/* Callbacks */
			on ddlExportMode selected index do (_data.optionExportMode.SetValue index)
			on cbxChangeName changed state do (_data.optionChangeName.SetValue state)
			on edtPrefix changed text do (_data.optionPrefixName.SetValue text)
			on edtSuffix changed text do (_data.optionSuffixName.SetValue text)
			on cbxExportCollision changed state do (_data.optionCombineCollision.SetValue state)
			on edtCollisionPrefix changed text do (_data.optionCollisionString.SetValue text)
			on chbCombineLODs changed state do (_data.optionCombineLODs.SetValue state)
			on edtLODPostfix changed text do (_data.optionLODString.SetValue text)
			on cbxCollapseGroups changed state do (_data.optionCollapseGroups.SetValue state)
			on cbxExportOptions changed state do (_data.optionExportOptions.SetValue state)
			on cbxFBXPreset changed state do (_data.optionExportFBXUsePreset.SetValue state)
			
			on btnGetPreset pressed do
			(
				browse_dialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
				browse_dialog.title = "Please select preset" --set the title
				browse_dialog.Multiselect = false --allow multiple files to be selected
				browse_dialog.Filter = "FBX Preset Files (*.fbxexportpreset)|*.fbxexportpreset|All Files (*.*)|*.*" --specify the filter
				browse_dialog.FilterIndex = 1 --set the filter drop-down list to All Files
				browse_dialog.InitialDirectory = "C:\Users\jos\Documents\3dsMax\FBX\3dsMax2014_X64\Presets\2014.0.1\export\BatchExport.fbxexportpreset"
				result = browse_dialog.showDialog() --display the dialog, get result into variable
				
				if (result.Equals result.OK) do 
				(
					preset_arr = ddlPreset.items
					
					e = Exporter()
					preset_arr = e.InsertItemInArray preset_arr browse_dialog.fileNames[1]
					-- Set a limit for the array
					if (preset_arr.count > 10) do
					(
						newArr = #()
						for i = 1 to 10 do (newArr[i] = preset_arr[i])
						preset_arr = newArr
					)
					ddlPreset.items = preset_arr
					ddlPreset.selection = 1
					ddlPreset.tooltip = ddlPreset.items[1] as string
					_data.optionExportFBXPreset.SetValue preset_arr
					
				)
			)
			
			on ddlPreset selected arg do
			(
				arr = ddlPreset.items
				-- Set the tooltip because the path can be longer than the width of the dropdownlist
				ddlPreset.tooltip = arr[arg] as string 
				sel = arr[arg]
				
				e = Exporter()
				arr = e.InsertItemInArray arr sel
				
				ddlPreset.selection = 1
				ddlPreset.items = arr
				_data.optionExportFBXPreset.SetValue arr
			)
		)
		return true
	),
	init = Constructor()
) -- End struct ExportObjectsRollout

/* 
 Export files rollout
*/
struct ExportFilesRollout
(
	public
	roll,
	
	-- Constructor function of ExportFilesRollout struct. Called at object creation.
	-- @return (boolean) true
	function Constructor = 
	(
		-- Create the data object if doesn't exist. Saved in the global variable _data.
		if (_data == undefined) do	_data = DataObject()
		
		rollout roll "Export Multiple Max Files"
		(
			button btnBrowseFile "Browse for files" width: 250
			multiListbox mlbMaxFiles height:14 width:250 align:#center tooltip:"Double click to delete a file"
			button btnSelectedFiles "No files to export" align:#left across:2 offset:[0,-5] height:20 border:false
			button btnClear "Clear" align:#right height:20 offset:[0,-5] border:false
			checkbox cbxSeparate "Separate objects" offset:[-5,0]
				tooltip:"Export all objects to separate files" checked:(_data.optionSeparate.Value())
			button btnExportSelection "Export Selection" width:204 height:25 across:2 offset:[35,0]
			button btnExportAll "All" width:50 height:25 offset:[43,0]
			
			/* Functions */
			-- Update the text of the selected button
			-- Example "1/3 files selected"
			function updateSelectedButton = 
			(
				if (mlbMaxFiles.items.count == 0) do
				(
					btnSelectedFiles.text = "No files to export"
					return undefined
				)
				-- Count the selected items
				bitArr = mlbMaxFiles.selection  
				number_of_selected_files = 0
				for i = 1 to bitArr.count do
				(
					if bitArr[i] == true do number_of_selected_files+=1
				)
				if number_of_selected_files == 0 then (btnSelectedFiles.text = "All files")
				else
				(
					number_of_files = mlbMaxFiles.items.count
					btnSelectedFiles.text = (number_of_selected_files as string) + "/" + number_of_files as string + " files selected"
				)
			) -- End updateSelectedButton

			-- Export files
			-- @param onlySelected (boolean) Export only the selected items in the multiListbox
			function exportFiles onlySelected: =
			(
				bitArr = mlbMaxFiles.selection  
				e = Exporter()
				for i_files = 1 to (mlbMaxFiles.items.count) do
				(
					if onlySelected == unsupplied or bitArr[i_files] == true or btnSelectedFiles.text == "All files" do
					(
						loadMaxFile (mlbMaxFiles.items[i_files] as string) quiet:true
						select $*
						selectionList = getCurrentSelection()
		
						filename = getFilenameFile (mlbMaxFiles.items[i_files] as string)
						
						e.ExportObjects selectionList maxFile:filename
					)
				)
				
				message = ""
				if e.successes.count > 0 do
				(
					message += "\n-----------------------\nSuccess\n-----------------------\n"
					for m in e.successes do
					(
						message += ("\n" + m)
					)
				)
				if e.errors.count > 0 do
				(
					message += "\n-----------------------\nErrors\n-----------------------\n"
					for m in e.errors do
					(
						message += ("\n" + m)
					)
				)
				
				messageBox message title:"Batch Export" beep:false

			) -- End exportFiles onlySelected:
			
			/* Callbacks */
			on btnBrowseFile pressed do
			(
				-- Use a dotnet openFileDialog because we need the possibility to select mutiple files
				browse_dialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
				browse_dialog.title = "Please Select One Or More Files" --set the title
				browse_dialog.Multiselect = true --allow multiple files to be selected
				browse_dialog.Filter = "MAX Files (*.max)|*.max"--|"All Files (*.*)|*.*" --specify the filter
				browse_dialog.FilterIndex = 1 --set the filter drop-down list to All Files
				result = browse_dialog.showDialog() --display the dialog, get result into variable
				if (result.Equals result.OK) do --returns TRUE if OK was pressed, FALSE otherwise
				(
					itemArr = mlbMaxFiles.items
					join itemArr browse_dialog.fileNames -- The selected filenames will be returned as an array
					mlbMaxFiles.items = itemArr
					updateSelectedButton()
				)
			)
			-- If user double clicks an item in the list, delete this item
			on mlbMaxFiles doubleClicked index do
			(
				mlbMaxFiles.items = deleteItem mlbMaxFiles.items index
				updateSelectedButton()
			)
			on mlbMaxFiles selected index do (updateSelectedButton())
			on btnSelectedFiles pressed do (mlbMaxFiles.selection = #{};updateSelectedButton())
			on btnClear pressed do (mlbMaxFiles.items = #();updateSelectedButton())
			on cbxSeparate changed state do (_data.optionSeparate.SetValue state)
			on btnExportSelection pressed do (exportFiles onlySelected:true)
			on btnExportAll pressed do (exportFiles())
		) -- End rollout roll
	
		return true
	),
	
	-- Constructor function will be executed when this struct is created.
	init = Constructor()
) -- End struct ExportFilesRollout
