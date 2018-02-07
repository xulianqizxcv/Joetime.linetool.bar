/* 
 Import rollout
*/

fileIn "importer.mse"
fileIn "data.mse"

struct ImportRollout
(
	public
	roll,
	rollAdvancedOptions,
	
	-- Constructor function of ImportRollout struct. Called at object creation.
	-- @return (boolean) true
	function Constructor =
	(
		-- Create the data object if doesn't exist. Saved in the global variable _data.
		if (_data == undefined) do	_data = DataObject()
		
		rollout roll "Import"
		(
			button btnBrowseFile "Browse for files" width:250
			-- @Todo dotnet ListView
			multiListbox mlbImportFiles height:13 width:250 align:#center tooltip:"Double click to delete a file" items:(_data.optionImportFiles.Value())
			button btnSelectedFiles "No files to import" align:#left across:2 offset:[0,-5] height:20 border:false
			button btnClear "Clear" align:#right height:20 offset:[0,-5] border:false
			radioButtons rbtImportType labels:#("import","merge","replace") default:(_data.optionImportType.Value()) \
			tooltip:#("Import non-native files into 3ds Max","Insert objects from external 3ds Max files into the current scene",\
				"Replaces objects in the current 3ds Max scene with objects from a exernal scene")
				
			subRollout subRollAdvancedOptions width:275 height:75 align:#center
			
			button btnImportSelection "Import Selection" width:204 height:25 across:2 offset:[35,0]
			button btnImportAll "All" width:50 height:25 offset:[43,0]

			/* Functions */
			-- Update the text of the selected button
			-- @example "1/3 files selected"
			function updateSelectedButton = 
			(
				if (mlbImportFiles.items.count == 0) do
				(
					btnSelectedFiles.text = "No files to import"
					return undefined
				)
				-- Count the selected items
				bitArr = mlbImportFiles.selection  
				number_of_selected_files = 0
				for i = 1 to bitArr.count do
				(
					if bitArr[i] == true do number_of_selected_files+=1
				)
				if number_of_selected_files == 0 then
				(
					btnSelectedFiles.text = "All files"
				)
				else
				(
					number_of_files = mlbImportFiles.items.count
					btnSelectedFiles.text = (number_of_selected_files as string) + "/" + number_of_files as string + " files selected"
				)
			)
			-- Check if nothing is selected
			-- @return (boolean)
			function isNothingSelected =
			(
				bitArr = mlbImportFiles.selection
				for i = 1 to bitArr.count do
				(
					if bitArr[i] == true do 
					(
						return false
						exit
					)
				)
				return true
			)
			-- Import files
			-- @param all (boolean) Import all items
			function import all =
			(
				bitArr = mlbImportFiles.selection
				nothingSelected = isNothingSelected()
				bShowOptions = _data.optionImportOptions.Value()
				i = Importer()
				
				disableSceneRedraw() -- Avoid delay of scene redraw every time something gets imported
				
				for i_files = 1 to (mlbImportFiles.items.count) do
				(
					item = mlbImportFiles.items[i_files]
					if item != undefined do
					(
						/* Import file if
						- item is selected
						- imported all is pressed
						- nothing is selected */
						if nothingSelected or bitArr[i_files] == true or all do
						(
							fileName = item as string
							i.MImportFile fileName bShowOptions:bShowOptions
							if bShowOptions do bShowOptions = false
						)
					)
				)
				enableSceneRedraw() -- Enable the scene redraw
				redrawViews() -- Redraw views
				--completeRedraw() -- Redraw views
			) -- End import
			
			/* Callbacks */
			on btnBrowseFile pressed do
			(
				-- Use a dotnet openFileDialog because we need the possibility to select mutiple files
				browse_dialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
				browse_dialog.title = "PLEASE Select One Or More Files" --set the title
				browse_dialog.Multiselect = true --allow multiple files to be selected
				browse_dialog.Filter = "OBJ Files (*.obj)|*.obj|FBX Files (*.fbx)|*.fbx|All Files (*.*)|*.*" --specify the filter
				browse_dialog.FilterIndex = 2 --set the filter drop-down list to All Files
				result = browse_dialog.showDialog() --display the dialog, get result into variable
				if (result.Equals result.OK) do 
				(
					itemArr = mlbImportFiles.items
					join itemArr browse_dialog.fileNames --the selected filenames will be returned as an array
					mlbImportFiles.items = itemArr
					_data.optionImportFiles.SetValue itemArr
					updateSelectedButton()
				)
			)
			-- If user double clicks an item in the list, delete this item
			on mlbImportFiles doubleClicked index do
			(
				mlbImportFiles.items = deleteItem mlbImportFiles.items index
				_data.optionImportFiles.SetValue (mlbImportFiles.items)
				updateSelectedButton()
			)
			on mlbImportFiles selected index do (updateSelectedButton())
			on btnSelectedFiles pressed do (mlbImportFiles.selection = #{};	updateSelectedButton())
			on btnClear pressed do (
				mlbImportFiles.items = #()
				_data.optionImportFiles.SetValue #()
				updateSelectedButton()
			)
			on rbtImportType changed state do (_data.optionImportType.SetValue state)
			
			on btnImportSelection pressed do (import false)
			on btnImportAll pressed do (import true)
		) -- End rollout roll
		
		rollout rollAdvancedOptions "Advanced"
		(
			checkbox chbCreateFileLayers "Create file layers" offset:[-5,0] checked:(_data.optionImportCreateFileLayers.Value()) \
				tooltip:"Create a layer for every file with the filename and put all content in layer"
			checkbox chbRenameToFileName "Rename to file name" offset:[-5,0] checked:(_data.optionImportRenameToFileName.Value()) \
				tooltip:"Rename objects in file to the filename, will be numbered _1 if multiple are found"
			checkbox chbAttachObjectsInFile "Attach in file" offset:[-5,0] checked:(_data.optionImportAttachObjectsInFile.Value()) \
				tooltip:"Attach all the objects from the file to one with the name of the file"
			checkbox chbGroupObjectsInFile "Group in file" offset:[-5,0] checked:(_data.optionImportGroupObjectsInFile.Value()) \
				tooltip:"Group all the objects from the file with the name of the file"
			checkbox cbxImportOptions "Import options" offset:[-5,0] checked:(_data.optionImportOptions.Value())
			
			on chbAttachObjectsInFile changed state do (_data.optionImportAttachObjectsInFile.SetValue state)
			on chbGroupObjectsInFile changed state do (_data.optionImportGroupObjectsInFile.SetValue state)	
			on chbRenameToFileName changed state do (_data.optionImportRenameToFileName.SetValue state)
			on chbCreateFileLayers changed state do (_data.optionImportCreateFileLayers.SetValue state)
			on cbxImportOptions changed state do (_data.optionImportOptions.SetValue state)
		) -- End rollout rollAdvancedOptions
		return true
	),
	-- Constructor function will be executed when this struct is created.
	init = Constructor()
) -- End struct ImportRollout
