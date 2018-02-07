/*
 Exporter class
 Contains all functionality needed to batch export
*/
struct Exporter
(
	public

	errors = #(),
	successes = #(),

	-- Constructor function of Exporter struct. Called at object creation.
	-- @return (boolean) true
	function Constructor =
	(
		-- Create the data object if doesn't exist. Saved in the global variable _data.
		if (_data == undefined) do	_data = DataObject()
	),
	init = Constructor(),
	visited_additional_objects = #(),
	
	function ResetObject = (), -- Function declaration to avoid undefined function calls
	function ResetObjects = (),
	function DeleteTurbo = (),
	
	-- Helper function to insert an item in an array
	-- @param array (array) Array where the item will be inserted
	-- @param item (string) Item to be inserted
	-- @return (array) Updated array
	function InsertItemInArray array item =
	(
		-- Move all the items one index further an place the given item at the first index
		c = array.count
		for i = 0 to c do
		(
			if (i!=c) do
			(
				array[c - (i-1)] = array[c - i]
			)
		)
		array[1] = item
		return (makeUniqueArray array)
	),
	-- Delete TurboSmooth modifiers on an object
	-- @param (object)
	function DeleteTurboSmoothOnObject obj =
	(
		if IsValidNode obj == false do return obj
		for m in obj.modifiers do
		(
			if classOf m == turboSmooth do deleteModifier obj m
		)
		return obj
	),
	
	fn getAllChildren obj =
	(
		all_children = #()
		for obj in obj.children do
		(
			append all_children obj
			all_children += (getAllChildren obj)
		)
		return all_children
	),
	-- Get the members of a given group head
	-- @param (object) Head of a group
	function GetGroupMembers groupHead =
	(
		members = #()
		for c in (getAllChildren groupHead) do
		(
			if isGroupMember c do append members c
		)
		return members
	),
	-- Reset a group
	-- @param groupHead (object) Head of a group
	function ResetGroup groupHead = 
	(
		--if __debug do (print ("Reset group " + (obj as string)))
		if IsValidNode groupHead == false do return groupHead
		groupPivot = groupHead.pivot
		groupName = groupHead.name
		groupMembers = GetGroupMembers groupHead
		explodeGroup groupHead
		for i=1 to groupMembers.count do
		(
			groupMembers[i] = ResetObject groupMembers[i]
		)
		group groupMembers name:groupName
		groupHead = getNodeByName groupName exact:true ignoreCase:false all:false
		groupHead.pivot = groupPivot
		return groupHead
	),
	-- Reset an object
	-- @param obj (object)
	function ResetObject obj =
	(
		--if __debug do (print ("Reset object " + (obj as string)))
		if IsValidNode obj == false do return obj
		if isGroupMember obj == true do return obj
		if isGroupHead obj == true do
		(
			return ResetGroup obj
		)
		originalPivot = obj.pivot
		originalName = obj.name
		originalWireColor = obj.wirecolor
		originalChildren = #(); for c in obj.children do append originalChildren c
		originalParent = obj.parent
		resetObj = Box()
		resetObj = convertTo resetObj PolyMeshObject
		resetObj.EditablePoly.attach obj resetObj
		resetObj.EditablePoly.SetSelection #Face #{1..6}
		resetObj.EditablePoly.delete #Face
		resetObj.name = originalName
		resetObj.wirecolor = originalWireColor
		-- Restore children
		for child in originalChildren do child.parent = resetObj
		-- Restore parent
		resetObj.parent = originalParent
		if (_data.optionPivotToOrigin.Value() == false) do resetObj.pivot = originalPivot
		
		return resetObj
	),
	-- Move an object to the origin [0,0,0]
	-- @param obj (object)
	function MoveObjectToOrigin obj =
	(
		if IsValidNode obj == false do return obj
		obj.pos = [0,0,0]
		return obj
	),
	-- Rotate an object
	-- @param obj (object)
	function RotateObject obj =
	(
		if IsValidNode obj == false do return obj
		rotArr = _data.optionRotateArr.Value()
		rotationValue = eulerangles rotArr[1] rotArr[2] rotArr[3]
		rotate obj rotationValue
		return obj
	),
	-- Scale an object
	-- @param obj (object)
	function ScaleObject obj =
	(
		if IsValidNode obj == false do return obj
		scaleValue = _data.optionScaleValue.Value()
		scale obj [scaleValue,scaleValue,scaleValue]
		return obj
	),
	-- Edit an object
	-- @param obj (object)
	function EditObject obj =
	(
		--if __debug do (print ("Edit object " + (obj as string)))
		if IsValidNode obj == false do return obj

		if (_data.optionDeleteTurboSmooth.Value()) do (obj = DeleteTurboSmoothOnObject obj)
		if (_data.optionResetObj.Value()) do (obj = ResetObject obj)
		if (_data.optionMoveToOrigin.Value()) do (obj = MoveObjectToOrigin obj)
		if (_data.optionRotateObj.Value()) do (obj = RotateObject obj)
		if (_data.optionScaleObj.Value()) do (obj = ScaleObject obj)
		if (_data.optionResetObjAfter.Value()) do (obj = ResetObject obj)
				
		return obj
	),
	-- Check if a string begins or ends with a given string
	-- @param s (string)
	-- @param matchString (string)
	function MatchPrefixOrPostfix s matchString numAfter:0 =
	(
		index = findString s matchString
		-- Check if found at beginning or end
		if ((index == (s.count - matchString.count + 1 - numAfter)) or (index == 1)) then
		(
			return true
		) else return false
	),
	-- Check if object is a lod
	-- @param obj (object)
	-- @return (boolean)
	function IsObjectFirstLOD obj =
	(
		bCombineLODs = _data.optionCombineLODs.Value()
		sLODString = _data.optionLODString.Value()
		if bCombineLODs do
		(
			-- Check if object is first LOD
			matchString = substituteString sLODString "*" "0"
			if (MatchPrefixOrPostfix obj.name matchString) do return true
		)
		return false 
	),
	-- Get the basename from a lod name
	-- @param obj (object)
	-- @return (string)
	function GetBaseNameFromLOD obj =
	(
		sLODString = _data.optionLODString.Value()
		matchString = substituteString sLODString "*" "0"
		return substituteString obj.name matchString ""
	),
	-- Get extra objects that belong together with the given object
	-- @param obj (object)
	-- @return ([object]) Additional objects
	function GetAdditionalObjects obj =
	(
		--if __debug do (print ("Get additional objects " + (obj as string)))
		aditionalObjectArr = #()
		if IsValidNode obj == false do return aditionalObjectArr
		
		bCombineCollision = _data.optionCombineCollision.Value()
		sCollisionString = _data.optionCollisionString.Value()
		bCombineLODs = _data.optionCombineLODs.Value()
		sLODString = _data.optionLODString.Value()
		
		-- Collision
		if bCombineCollision do
		(
			-- Check if there's an object that matches the collision string
			collisionNodes = getNodeByName (sCollisionString + obj.name) exact:true ignoreCase:true all:true
			if collisionNodes.count == 0 do (collisionNodes = getNodeByName (obj.name + sCollisionString) exact:true ignoreCase:true all:true)
			if collisionNodes.count != 0 do 
			(
				for collisionNode in collisionNodes do
				(
					-- Move the pivot of the collision mesh to the original object
					collisionNode.pivot = obj.pivot
					append aditionalObjectArr collisionNode
				)
			)
		)
		-- Group
		if isGroupHead obj then
		(
			members = getGroupMembers obj
			
			setGroupOpen obj false
			explodeGroup obj
			clearSelection()
			aditionalObjectArr += members
		) 
		else
		(
			-- LOD
			-- Check if object is first LOD
			if (IsObjectFirstLOD obj) do
			(
				-- Get all other lods
				matchString = substituteString sLODString "*" "0"
				index = findString obj.name matchString
				start = index + sLODString.count - 1
				for i=1 to 10 do
				(
					lodName = replace obj.name start 1 (i as string)
					-- Replace the LOD number
					lodObject = getNodeByName lodName
					if lodObject == undefined then exit
					else (append aditionalObjectArr  lodObject)
				)
			)
		)
		-- Save the nodes to help out the isAdditionalObject method
		join visited_additional_objects aditionalObjectArr
		
		--if __debug do (print ("Get additional objects result " + (aditionalObjectArr as string)))
		return aditionalObjectArr
	),
	-- Check if given object is an additional object
	-- @param obj (object)
	-- @return (boolean)
	function isAdditionalObject obj = 
	(
		--if __debug do (print ("Is additional object " + (obj as string)))
		if (IsValidNode obj) == false do return false
		
		for o in visited_additional_objects do
		(
			if o == obj do return true
		)
		
		bCombineCollision = _data.optionCombineCollision.Value()
		sCollisionString = _data.optionCollisionString.Value()
		bCombineLODs = _data.optionCombineLODs.Value()
		sLODString = _data.optionLODString.Value()
		
		-- Don't export group members
		if (isGroupMember obj == true) do return true
		
		-- Skip collisions. Collision objects are exported with the corresponding object
		if bCombineCollision do
		(
			if (MatchPrefixOrPostfix obj.name sCollisionString) do return true
		)
		
		-- Skip LODs > first lod
		if bCombineLODs do
		(
			matchString = substituteString sLODString "*" ""
			-- Check if found at beginning or end
			if (MatchPrefixOrPostfix obj.name matchString numAfter:1) do
			(
				-- Check if first LOD
				-- First lod is not an additional object
				if (MatchPrefixOrPostfix obj.name (substituteString sLODString "*" "0")) do 
				(
					return false
				)
				return true
			)
		)
		return false
	),-- End function isAdditionalObject
	-- Collapse all the groups in the given object array
	-- Select the groups
	-- @param objectArr ([object])
	-- @return updated objectArr
	function CollapseGroups objectArr = 
	(
		--if __debug do (print ("Collapse groups " + (objectArr as string)))
		newArr = #()
		for obj in objectArr do
		(
			if IsValidNode obj == false do continue
			if isGroupMember obj == true do continue
			if isGroupHead obj then
			(
				originalName = obj.name
				originalPivot = obj.pivot
				members = GetGroupMembers obj
				setGroupOpen obj false
				explodeGroup obj
				convertTo members[1] PolyMeshObject

				for i = 2 to members.count do
				(
					if IsValidNode members[i] == true then
					(
						members[1].attach members[i] members[1]
					)
				)
				members[1].name = originalName
				members[1].pivot = originalPivot
				append newArr members[1]

			) else append newArr obj
		)
		return newArr
	),-- End function CollapseGroups
	
	function ExportToOneFile objectArr fileName =
	(
		outputPath = _data.optionOutputPath.Value(); outputPath = outputPath[1] -- Folder to export to
		extension = _data.optionFormat.Value(); extension = extension[1]
		bChangeName = _data.optionChangeName.Value()
		prefix = _data.optionPrefixName.Value()
		suffix = _data.optionSuffixName.Value()
		
		for i=1 to objectArr.count do
		(	
			if IsValidNode objectArr[i] == false do continue
			-- Don't edit group members
			if (isGroupMember objectArr[i] == true) do continue
			-- Prepare the object
			objectArr[i] = EditObject objectArr[i]
			if objectArr[i] == undefined do continue
		)

		select objectArr
		
		if bChangeName do (maxFile = prefix + fileName + suffix)
		filename = outputPath + "\\" + fileName + "." + extension

		if extension == "max" then
		(
			saveNodes objectArr filename quiet:true
		)
		else
		(
			exportfile filename #noPrompt selectedOnly:true
		)
	),
	
	-- Export objects
	-- @param objectArr ([object]) Objects to be exported
	-- @param maxFile (string) Scene name (will be added to the name).
	function ExportObjects objectArr maxFile: =
	(
		--if __debug do (print ("Export objects " + (objectArr as string)))
		-- Get all the needed data from the data object
		outputPath = _data.optionOutputPath.Value(); outputPath = outputPath[1] -- Folder to export to
		extension = _data.optionFormat.Value(); extension = extension[1]
		bChangeName = _data.optionChangeName.Value()
		prefix = _data.optionPrefixName.Value()
		suffix = _data.optionSuffixName.Value()
		bExportOptions = _data.optionExportOptions.Value()
		bExportFBXPreset = _data.optionExportFBXUsePreset.Value()
		
		-- Options exporting files
		bMultipleMaxFiles = true; if maxFile == unsupplied then bMultipleMaxFiles = false
		bSeparate = _data.optionSeparate.Value()
		
		this.errors = #()
		this.successes = #()
		
		-- Save scene state
		holdMaxFile()
		
		-- Collapse groups if specified
		if (_data.optionCollapseGroups.Value()) do objectArr = CollapseGroups objectArr
		
		-- Export all objects to one file
		if bMultipleMaxFiles and bSeparate == false then
		(
			for i=1 to objectArr.count do
			(	
				if IsValidNode objectArr[i] == false do continue
				-- Don't export group members
				if (isGroupMember objectArr[i] == true) do continue
				-- Prepare the object
				objectArr[i] = EditObject objectArr[i]
			)

			-- Filter out invalid objects (group members that got collapsed)
			objectArr = for obj in objectArr where (IsValidNode obj == true) collect obj
			select objectArr
			
			if bChangeName do (maxFile = prefix + maxFile + suffix)
			filename = outputPath + "\\" + maxFile + "." + extension

			if extension == "max" then
			(
				saveNodes objectArr filename quiet:true 
			) 
			else
			(
				exportfile filename #noPrompt
			)

			-- Check if the exported file has modified
			if ((doesFileExist filename) and (modDate != getFileModDate filename)) then (append this.successes ("Exported " + filename))
			else (append this.errors ("File not modified " + filename))
		) -- End export to one file
		-- Export all objects to different files
		else
		(
			for i=1 to objectArr.count do
			(	
				if IsValidNode objectArr[i] == false do continue
				
				-- Skip additional objects, these will be exported with the main object
				if (isAdditionalObject objectArr[i] == true) do continue

				objectName = objectArr[i].name
				
				-- If object is a lod, strip of the _LOD0
				if (IsObjectFirstLOD objectArr[i]) do
				(
					objectName = GetBaseNameFromLOD objectArr[i]
				)
				if bChangeName do (objectName = prefix + objectName + suffix)
				-- If user exports multiple max files, add the name of the max file in the name of the exported object
				if bMultipleMaxFiles then filename = outputPath + "\\" + maxFile + "_" + objectName + "." + extension
				else (filename = outputPath + "\\" + objectName + "." + extension)
				
				-- Get additional nodes 
				-- (needs to be before editing the main object because it sets the pivot to the main object)
				additionObjectArr = GetAdditionalObjects objectArr[i]

				-- Prepare the object
				objectArr[i] = EditObject objectArr[i]
				
				-- Check again to be sure
				if IsValidNode objectArr[i] == true do 				
				(	-- Select the object's we want to export
					select objectArr[i]
				)
				-- Edit the additional objects
				for a=1 to additionObjectArr.count do
				(
					-- Prepare the object
					additionObjectArr[a] = EditObject additionObjectArr[a]
				)
				selectMore additionObjectArr

				-- Check if we have a valid selection
				if selection.count == 0 do
				(
					append this.errors ("Failed to export " + objectName)
				)
				
				-- Save the modification date so we can check if the exported file got modified after exporting
				modDate = undefined
				if (doesFileExist filename) do (modDate = getFileModDate filename)
				
				if extension == "max" then
				(
					saveNodes $ filename quiet:false 
				) 
				else 
				(
					-- Don't export fbx with options, they don't get saved anyway
					if (extension == "fbx") then
					(
						if bExportFBXPreset then
						(
							-- Set the fbxpreset
							FBXExporterSetParam "LoadExportPresetFile" ((_data.optionExportFBXPreset.Value())[1])
						)
						exportFile filename #noPrompt selectedOnly:true
					)
					else
					(
						if bExportOptions then 
						(
							exportFile filename selectedOnly:true
							bExportOptions = false
						)
						else 
						(
							exportFile filename #noPrompt selectedOnly:true
						)
					)
				)
				
				-- Check if the exported file has modified
				if ((doesFileExist filename) and (modDate != getFileModDate filename)) then (append this.successes ("Exported " + filename))
				else (append this.errors ("File not modified " + filename))
				
				-- Add the objects to the additional objects to make sure they're not exported again
				join visited_additional_objects (getCurrentSelection()) 
				
			) -- End for i=1 to objectArr.count do
			-- Restore scene state
			fetchMaxFile quiet:true
		) -- End export to different files
	), -- End function ExportObjects
	-- Reset objects
	-- @param objectArr (array) Array of objects to reset
	-- @return (array) Updated array
	function ResetObjects objectArr =
	(
		for i = 1 to objectArr.count do
		(
			objectArr[i] = ResetObject objectArr[i]
		)
		return objectArr
	),
	-- Delete TurboSmooth modifier on objects
	-- @param objectArr (array) Array of objects to reset
	-- @return (array) Updated array
	function DeleteTurboSmoothOnObjects objectArr =
	(	
		for i = 1 to objectArr.count do
		(
			objectArr[i] = DeleteTurboSmoothOnObject objectArr[i]
		)
		return objectArr
	),
	-- Delete TurboSmooth modifier on selected objects
	function DeleteTurboSmoothOnSelected =
	(
		if selection.count != 0 then
		(
			for obj in selection do DeleteTurboSmoothOnObject obj
		)
		else messageBox "No selected objects found."
	),
	-- Reset selected objects
	function ResetObjectOnSelected =
	(
		if selection.count != 0 then
		(
			newSelection = #()
			for obj in selection do 
			(
				if (isValidNode obj) and (isGroupMember obj == false) do
				(
					r = ResetObject obj
					append newSelection r
				)
			)
			select newSelection
		)
		else messageBox "No selected objects found."
		
	),
	-- Move selected objects to the origin
	function MoveObjectToOriginOnSelected =
	(
		if selection.count != 0 then
		(
			for obj in selection do 
			(
				MoveObjectToOrigin obj
			)
		)
		else messageBox "No selected objects found."
	),
	-- Rotate selected objects
	function RotateObjectOnSelected =
	(
		if selection.count != 0 then
		(
			for obj in selection do 
			(
				RotateObject obj
			)
		)
		else messageBox "No selected objects found."
	),
	-- Scale selected objects
	function ScaleObjectOnSelected =
	(
		if selection.count != 0 then
		(
			for obj in selection do 
			(
				ScaleObject obj
			)
		)
		else messageBox "No selected objects found."
	),
	-- Export the selected objects
	function ExportSelectedObjects = 
	(
		selectedObjs = selection as array
		if selectedObjs.count != 0 then
		(
			ExportObjects selectedObjs
		)
		else messageBox "No selected objects found."
	),
	-- Export all the objects in the scene
	function ExportAllObjects =
	(
		allObjs = ($* as array)
		if allObjs.count != 0 then
		(
			ExportObjects allObjs
		)
		else messageBox "No objects found."
	),
	
	function ExportAllLayers = 
	(
		-- Save scene state
		holdMaxFile()

		for i=1 to LayerManager.count-1 do
		(
			layer = LayerManager.getLayer i
			layer_name = layer.name
			layer_obj = ILayerManager.getLayerObject i
			local objs
			layer.nodes &objs
			
			ExportToOneFile objs layer_name
		)

		-- Restore scene state
		fetchMaxFile quiet:true
	)
)
