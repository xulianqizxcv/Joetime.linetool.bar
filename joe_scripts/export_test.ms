/*Macroscript Exporter
category:"Custom"
tooltip:" ExportTool "
--buttontext:"None"
*/
rollout exportWindow "Export"
(


	local copyType=1
	local exConfigFile=""
	local pathSource
	local pathSave
	local set_ExportFBXPreset=#()
	fn StringIsEmpty str=
	(
		if (str==undefined or str=="" or str==" ") then
		(
			return true
		)else
		(
			return false
		)
	)


	fn FilesProcess fPath=
	(
		arrNameTypes=#()
		case copyType of
			(
				1:
				(
					append arrNameTypes ".max"
				)
				2:
				(
					append arrNameTypes ".max"
					append arrNameTypes ".png"
				)
				3:
				(
					append arrNameTypes ".max"
					append arrNameTypes ".tga"
				)
				4:
				(
					append arrNameTypes ".max"
					append arrNameTypes ".psd"
				)
				5:
				(
					append arrNameTypes ""
				)
			)
		for type in arrNameTypes do
		(
			theFiles=getFiles(fPath+@"/*"+type)
			if (theFiles!=undefined and theFiles.count>0) then
			(
				for f in theFiles do
				(

					fileNameType= getFilenameType  f
					newPath=replace fPath 1 (pathSource.count) pathSave
					if (doesFileExist newPath)==false do
					(
						makeDir newPath --create folder
					)
					if fileNameType==".max" then
					(

						FBXExporterSetParam "LoadExportPresetFile" exConfigFile
						saveMaxFile f
						max select all
						fileName=getFilenameFile f
						exportFile  (newPath+@"\"+fileName+".fbx") #noPrompt selectedOnly:true using:FBXEXP
					)
					else
					(
						copyFile f (newPath+(filenameFromPath  f))
					)
				)
			)
		)

	)

	--Find Path
	fn FindFile fPath =
	(
		--print fPath
		for dir in GetDirectories (fPath+@"\*") do
		(
			--ExportFBX dir oldPath newPath
			FindFile dir
		)
		FilesProcess fPath
	)


	--try(destroyDialog exportWindow )catch()
	--rollout exportConfig "Configuration"
	--(
		/*
		radiobuttons  rad_SeType "CopyFile :" \
		labels:#("None","PNG","TGA","PSD","ALL") columns:5 align:#left  \
		offsets:#([65,-16], [5,-16], [-60,-16], [-120,-16],[-180,-16]) default:1
		on rad_SeType  changed state do
			(
				copyType=state
			)
		*/



	--)
---------------------------------------------------------------------------------
	--rollout exportWindow "Export"
	--(

		group "Source Path"
		(
			edittext sourceTxt "Source:" fieldWidth:235 labelOnTop:false across:2 align:#left
			button sourceButton "..." width:35 height:25 offset:[65,-5]
		)
		group "Save Path"
		(
			edittext prefix_Save "Save   :" fieldWidth:235 labelOnTop:false across:2 align:#left
			button btn_Save "..."  width:35 height:25  offset:[65,-5]  --across:2 align:#right
		)
		button exportButton "Explort"  width:100 height:25 across:2 alingn:#left
		--checkbutton  chk_Config  "OpenConfig"  width:100 height:25
		button chk_Config  "OpenConfig"  width:100 height:25

		checkbox cbx_FBX_pre "FBX preset" across:3 offset:[-5,0]
		--dropdownlist ddlOutputpath width:240 height:20 items:(_data.optionOutputPath.Value()) tooltip:"" offset:[-40,0]
		dropdownlist ddlPreset width:240 height:20 items:(set_ExportFBXPreset) tooltip:"" offset:[-40,0]
		button btnGetFolder "..." width:25 height:20 tooltip:"Browse for folder" offset:[45,0]

		--button btn_ExConfigPath "Find Export Configuration File " width:355 \
		--tooltip:"EX: C:\Users\UserName\Documents\3dsMax\FBX\3dsMax2014_X64\Presets\2015.0\export"
---------------------------------------------------------------------------------
		on sourceTxt changed txt do
			(
				--And the name is not the empty string,
				if txt != "" do
				(
					pathSource=txt
				)

			)


		on sourceButton pressed do
			(
				sp= getSavePath caption "Select Source Path"
				if sp!=undefined do
				(
					sourceTxt.text= sp
					pathSource=sp
				)

			)

		on prefix_Save changed txt do
			(
				--And the name is not the empty string,
				if txt != "" do
				(
					pathSave=txt
				)
			)

		on btn_Save pressed do
		(
			sp= getSavePath caption "Select Save Path"
			if sp!=undefined do
			(
				prefix_Save.text= sp
				pathSave=sp
			)
		)




		on exportButton pressed do
		(
				--print sourceTxt.text
				--print saveTxt.text

				if (StringIsEmpty pathSource) then
				(
					messagebox("Source Path Is Null .")
				)

				else if (StringIsEmpty pathSave)then
				(
					messagebox(" Save Path Is Null .")
				)

				else if (StringIsEmpty exConfigFile)then
				(
					messagebox(" Export ConfigFile File Is Null .\n Example C:\Users\UserName\Documents\
						\n 3dsMax\FBX\3dsMax2014_X64\Presets\2015.0\export")
				)

				else
				(
					try
					(
						FindFile pathSource
					)
					catch
					(
						format "*** % ***\n" (getCurrentException())
					)

				)
		)

		/*
		on chk_Config changed state do
		(
				if state then
				(
					exportWindow.height=350
				)
				else
				(
					exportWindow.height=135
				)
		)
		*/
		on chk_Config pressed do
		(

		)
		/*
		on btn_ExConfigPath pressed do
		(
			f = getOpenFileName types:"Data(*.fbxexportpreset)|*.fbxexportpreset"
			if f!=undefined do
			(
				btn_ExConfigPath.text=f
				exConfigFile=btn_ExConfigPath.text
			)
		)*/

		--SubRollout theSubrollout "Configuration" height:95  --width:360 offset:[-5,0]

		on ddlPreset selected itm do
		(
			ddlPreset.tooltip = filenamefrompath (ddlPreset.items[itm] as string)
			exConfigFile=ddlPreset.items[itm]
		)

		on btnGetFolder pressed do
		(	/*
			browse_dialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog
			browse_dialog.title = "Please select preset" --set the title
			browse_dialog.Multiselect = false --allow multiple files to be selected
			browse_dialog.Filter = "FBX Preset Files (*.fbxexportpreset)|*.fbxexportpreset|All Files (*.*)|*.*" --specify the filter
			browse_dialog.FilterIndex = 1 --set the filter drop-down list to All Files
			browse_dialog.InitialDirectory = "C:\Users\jos\Documents\3dsMax\FBX\3dsMax2014_X64\Presets\2014.0.1\export\BatchExport.fbxexportpreset"
			result = browse_dialog.showDialog() --display the dialog, get result into variable

			--if (result.Equals result.OK) do
			--(
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
				optionExportFBXPreset.SetValue preset_arr

			--)
			*/

			local get_ExportFBXPreset = getOpenFileName types:"Data(*.fbxexportpreset)|*.fbxexportpreset"
			if get_ExportFBXPreset != undefined do (
				append set_ExportFBXPreset get_ExportFBXPreset
				exConfigFile = get_ExportFBXPreset
				ddlPreset.items = set_ExportFBXPreset
			--ddlPreset.tooltip = filenamefrompath (ddlPreset.items[1] as string)
				--exConfigFile=ddlPreset.items[itm]
			)
			/*
			if f!=undefined do
			(
				btn_ExConfigPath.text=f
				exConfigFile=btn_ExConfigPath.text
			)
			*/
		)
)
	createDialog exportWindow 370 350--135
	--AddSubRollout exportWindow.theSubrollout exportConfig


