/*
 Struct to hold all the data
*/

fileIn "option.mse"

global _data

struct DataObject
(
	public
	
	/* License */
	optionCommercial,
	
	/* Common options */
	optionSelectedTab,
	
	/* Import options*/
	optionImportFiles,
	optionImportType,
	optionImportOptions,
	optionImportCreateFileLayers,
	optionImportRenameToFileName,
	optionImportAttachObjectsInFile,
	optionImportGroupObjectsInFile,

	/* Export options*/
	optionResetObj,
	optionResetObjAfter,
	optionPivotToOrigin,
	optionPivotToOriginAfter,
	optionDeleteTurboSmooth,
	optionMoveToOrigin,
	optionRotateObj,
	optionRotateArr,
	optionScaleObj,
	optionScaleValue,
	optionOutputPath,
	optionFormat,
	optionExportMode,
	optionChangeName,
	optionPrefixName,
	optionSuffixName,
	optionCombineCollision,
	optionCollisionString,
	optionCombineLODs,
	optionLODString,
	optionCollapseGroups,
	optionExportOptions,
	optionExportFBXUsePreset,
	optionExportFBXPreset,
	
	/* Export files options */
	optionSeparate,
	
	function Constructor =
	(
		/* Commercial */
		struct OptionCommercialStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "ExportName";base.Add value)
		)
		optionCommercial = OptionCommercialStruct(); optionCommercial.Create false
		
		/* Common options */
		struct OptionSelectedTabStruct ( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetInt,
			function Create value = (base.name = "SelectedTab";base.Add value)
		)
		optionSelectedTab = OptionSelectedTabStruct(); optionSelectedTab.Create 0
		
		/* Import options */
		struct OptionImportFilesStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetArray,
			function Create value = (base.name = "ImportFiles";base.Add value)
		)
		optionImportFiles = OptionImportFilesStruct(); optionImportFiles.Create #()
		
		struct OptionImportTypeStruct ( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetInt,
			function Create value = (base.name = "ImportType";base.Add value)
		)
		optionImportType = OptionImportTypeStruct(); optionImportType.Create 1

		struct OptionImportOptionsStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "ImportOptions";base.Add value)
		)
		optionImportOptions = OptionImportOptionsStruct(); optionImportOptions.Create true
		
		struct OptionImportAttachObjectsInFileStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "ImportAttachObjectsInFile";base.Add value)
		)
		optionImportAttachObjectsInFile = OptionImportAttachObjectsInFileStruct(); optionImportAttachObjectsInFile.Create false

		struct OptionImportGroupObjectsInFileStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "ImportGroupObjectsInFile";base.Add value)
		)
		optionImportGroupObjectsInFile = OptionImportGroupObjectsInFileStruct(); optionImportGroupObjectsInFile.Create false

		struct OptionImportRenameToFileNameStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "ImportRenameToFileName";base.Add value)
		)
		optionImportRenameToFileName = OptionImportRenameToFileNameStruct(); optionImportRenameToFileName.Create false
		
		struct OptionImportCreateFileLayersStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "ImportCreateFileLayers";base.Add value)
		)
		optionImportCreateFileLayers = OptionImportCreateFileLayersStruct(); optionImportCreateFileLayers.Create false
		
		/* Export options */
		struct OptionResetObjStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "ResetObj";base.Add value)
		)
		optionResetObj = OptionResetObjStruct(); optionResetObj.Create true
		
		struct OptionResetObjAfterStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "ResetObjAfter";base.Add value)
		)
		optionResetObjAfter = OptionResetObjAfterStruct(); optionResetObjAfter.Create false
		
		struct OptionPivotToOriginStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "PivotToOrigin";base.Add value)
		)
		optionPivotToOrigin = OptionPivotToOriginStruct(); optionPivotToOrigin.Create false
		
		struct OptionPivotToOriginAfterStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "PivotToOriginAfter";base.Add value)
		)
		optionPivotToOriginAfter = OptionPivotToOriginAfterStruct(); optionPivotToOriginAfter.Create false
		
		struct OptionDeleteTurboSmoothStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "DeleteTurboSmooth";base.Add value)
		)
		optionDeleteTurboSmooth = OptionDeleteTurboSmoothStruct(); optionDeleteTurboSmooth.Create true
		
		struct OptionMoveToOriginStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "MoveToOrigin";base.Add value)
		)
		optionMoveToOrigin = OptionMoveToOriginStruct(); optionMoveToOrigin.Create true
		
		struct OptionRotateStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "RotateObj";base.Add value)
		)
		optionRotateObj = OptionRotateStruct(); optionRotateObj.Create false
		
		struct OptionRotateArrStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetArray,
			function Create value = (base.name = "RotateArr";base.Add value)
		)
		optionRotateArr = OptionRotateArrStruct(); optionRotateArr.Create #(0,0,0)
		
		struct OptionScaleStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "ScaleObj";base.Add value)
		)
		optionScaleObj = OptionScaleStruct(); optionScaleObj.Create false
		
		struct OptionScaleValueStruct ( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetFloat,
			function Create value = (base.name = "ScaleValue";base.Add value)
		)
		optionScaleValue = OptionScaleValueStruct(); optionScaleValue.Create 1.0

		struct OptionOutputPathStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetArray,
			function Create value = (base.name = "OutputPath";base.Add value)
		)
		optionOutputPath = OptionOutputPathStruct(); optionOutputPath.Create #(GetDir #export)
		
		struct OptionFormatStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetArray,
			function Create value = (base.name = "Format";base.Add value)
		)
		optionFormat = OptionFormatStruct(); optionFormat.Create #("obj","fbx","3ds","max","ase","dwf","dwg","dxf","dae", "nif")
		
		struct OptionExportModeStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetInt,
			function Create value = (base.name = "ExportMode";base.Add value)
		)
		optionExportMode = OptionExportModeStruct(); optionExportMode.Create 1
		
		struct OptionChangeNameStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "ChangeName";base.Add value)
		)
		optionChangeName = OptionChangeNameStruct(); optionChangeName.Create false
		
		struct OptionPrefixNameStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetValue,
			function Create value = (base.name = "PrefixName";base.Add value)
		)
		optionPrefixName = OptionPrefixNameStruct(); optionPrefixName.Create ""
		
		struct OptionSuffixNameStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetValue,
			function Create value = (base.name = "SuffixName";base.Add value)
		)
		optionSuffixName = OptionSuffixNameStruct(); optionSuffixName.Create ""
		
		struct OptionCollisionStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "CombineCollision";base.Add value)
		)
		optionCombineCollision = OptionCollisionStruct(); optionCombineCollision.Create true
		
		struct OptionCollisionPrefixStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetValue,
			function Create value = (base.name = "CollisionString";base.Add value)
		)
		optionCollisionString = OptionCollisionPrefixStruct(); optionCollisionString.Create "UCX_"
		
		struct OptionCombineLODStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "CombineLODs";base.Add value)
		)
		optionCombineLODs = OptionCombineLODStruct(); optionCombineLODs.Create true
		
		struct OptionLODPostfixStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetValue,
			function Create value = (base.name = "LODString";base.Add value)
		)
		optionLODString = OptionLODPostfixStruct(); optionLODString.Create "_LOD*"
		
		struct OptionCollapseGroupsStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "CollapseGroups";base.Add value)
		)
		optionCollapseGroups = OptionCollapseGroupsStruct(); optionCollapseGroups.Create true
		
		struct OptionExportOptionsStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "ExportOptions";base.Add value)
		)
		optionExportOptions = OptionExportOptionsStruct(); optionExportOptions.Create true

		struct OptionExportFBXPresetStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetArray,
			function Create value = (base.name = "FBXPreset";base.Add value)
		)
		optionExportFBXPreset = OptionExportFBXPresetStruct(); optionExportFBXPreset.Create #()
		
		struct OptionExportFBXUsePresetStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "UseFBXPreset";base.Add value)
		)
		optionExportFBXUsePreset = OptionExportFBXUsePresetStruct(); optionExportFBXUsePreset.Create false
		
		/* Export files options */
		struct OptionSeparateStruct( -- Inherits from Option
			base = Option(), SetValue = base.SetValue, Value = base.GetBool,
			function Create value = (base.name = "SeparateObjects";base.Add value)
		)
		optionSeparate = OptionSeparateStruct(); optionSeparate.Create true
		
		return true
	),
	-- Constructor function will be executed when this struct is created.
	init = Constructor()
) -- End struct DataObject

if (_data == undefined) do	_data = DataObject()