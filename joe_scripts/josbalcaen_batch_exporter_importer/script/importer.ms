/*
 Importer class
 Contains all functionality needed to batch import
*/
struct Importer
(
	public
	function Constructor =
	(
		if (_data == undefined) do	_data = DataObject()
	),
	init = Constructor(),
	
	-- Import objects
	-- @param path (string) Path to file to import
	-- @param bShowOptions (boolean) Show import options.
	function MImportFile path bShowOptions:false=
	(
		
		objectArrayBeforeImporting = objects as array

		importType = _data.optionImportType.Value() -- 1:Import 2:Merge 3:Replace
		bCreateFileLayers = _data.optionImportCreateFileLayers.Value()
		bRenameToFileName = _data.optionImportRenameToFileName.Value()
		bAttachObjectsInFile = _data.optionImportAttachObjectsInFile.Value()
		bGroupObjectsInFile = _data.optionImportGroupObjectsInFile.Value()

		extension = getFilenameType path
		fileName = getFilenameFile path
		
		case extension of
		(
			".max": if bShowOptions then
			(
				mergeMAXFile path #prompt #promptDups #promptMtlDups #promptReparent
			)
			else
			(
				case importType of
				(
					1: mergeMAXFile path
					2: mergeMAXFile path #renameMtlDups #AutoRenameDups #useSceneMtlDups
					3: mergeMAXFile path #deleteOldDups
				)
			)
			default: if bShowOptions then
			(
				importFile path
			)
			else
			(
				importFile path #noPrompt
			)
		)
		
		local importedObjectArray = for obj in objects where findItem objectArrayBeforeImporting obj == 0 collect obj
		if (importedObjectArray.count == 0) then return()

		local geometryObjects = for obj in importedObjectArray where SuperClassOf obj == GeometryClass collect obj
		
		if (bGroupObjectsInFile) then
		(
			for obj in importedObjectArray do obj.parent = undefined
			group importedObjectArray name:fileName
		)

		if (bAttachObjectsInFile) then
		(
			geometryObjects = this.QuickAttach geometryObjects
		)

		if (bRenameToFileName) then
		(
			if (importedObjectArray.Count == 1) then
			(
				if (IsValidNode importedObjectArray[1]) then
				(
					importedObjectArray[1].name = fileName
				)
			)
			else
			(
				for i = 1 to importedObjectArray.Count do
				(
					if (IsValidNode importedObjectArray[i]) then
					(
						importedObjectArray[i].name = fileName + "_" + i as string
					)
				)
			)
		)

		if (bCreateFileLayers) then
		(
			local layer = LayerManager.getLayerFromName fileName
			if (layer == undefined) then
			(
				layer = LayerManager.newLayer()
				layer.setName fileName
			)
			for obj in importedObjectArray do 
			(
				if (IsValidNode obj) then
				(
					layer.addnode obj
				)
			)
		)
	),

	-- Attach all objects to each other
	-- Based on script created by Morozov Anton
	function QuickAttach inObjectArray =
	(
		local seq = 500 -- How many objects add to one part
		local count = 0
		meshes=#()

		with undo off with redraw off
		(
			b = Editable_Mesh()
			b.name = inObjectArray[1].name
			append meshes b
			for i = 1 to inObjectArray.count do
			(
				local obj = inObjectArray[i]
				if (IsValidNode obj) then
				(
					count += 1
					if count >= seq do (
						count = 1
						b = Editable_Mesh()
						b.name = obj.name
						append meshes b
					)
					if SuperClassOf obj == GeometryClass do
						meshop.attach b obj attachMat:#IDToMat condenseMat:true deleteSourceNode:true
				)
			)
			if meshes.count > 1 do (
				b = meshes[1]
				for i = 2 to meshes.count do
				(
					meshop.attach b meshes[i] attachMat:#IDToMat condenseMat:true deleteSourceNode:true
				)
			)

			b.pivot = b.center
		)
		return meshes
	)
)
