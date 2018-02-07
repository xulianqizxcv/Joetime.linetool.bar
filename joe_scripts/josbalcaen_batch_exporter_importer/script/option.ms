/* 
 Base class for an option
*/
struct Option
(
	public
	name,
	optionsFile,
	defaultSection,
	
	-- Constructor function of ExportFilesRollout struct. Called at object creation.
	-- @return (boolean) true
	function Constructor =
	(
		optionsFile = (systemTools.getEnvVariable("APPDATA") + @"\Maxscript\BatchExportImportOptions.ini")
		defaultSection = "global"
		name = "undefined"
		
		-- Create options file if it doesn't exists
		if not (doesFileExist optionsFile) do
		(
			try
			(
				makeDir (systemTools.getEnvVariable("APPDATA") + @"\Maxscript\")
				s = createFile optionsFile
				close s
			) 
			catch
			(
				print (getCurrentException())
			)
		)
		if not (doesFileExist optionsFile) do
		(
			s = "Please create this file manually\n" + optionsFile
			messageBox s title:"Failed to create file."
			throw "Failed to create file"
		)
		return true
	),
	-- Constructor function will be executed when this struct is created.
	init = Constructor(),
	
	/* Public functions */
	-- Check if this option exists in the file
	function Exists = 
	(
		return hasINISetting optionsFile defaultSection name
	),
	-- Get the value of this option
	function GetValue =
	(
		return (getINISetting optionsFile defaultSection name)
	),
	-- Set the value of this option
	-- @param value (boolean)
	function SetValue value =
	(
		if classOf value == Array do (
			to_string = "#("
			for i = 1 to value.count do
			(
				if classOf value[i] == String then to_string += "\"" + value[i] + "\""
				else to_string += (value[i] as string)
				if i < value.count do to_string += ", "
			)
			to_string += ")"
			value = to_string
		)
		setINISetting optionsFile defaultSection name (value as string)
	),
	-- Add this option to the options file if it doesn't exist
	-- @param value (boolean)
	function Add value =
	(
		if not Exists() do 
		(
			SetValue value
		)
	),
	-- Get the value of this option as a boolean
	function GetBool =
	(
		return (GetValue() as booleanClass)
	),
	-- Helper method to replace characters in a string
	-- @param s (string)
	-- @param chFrom (character) Character that needs to be replaced
	-- @param chTo (character) New character
	-- @return (string) Updated string
	function ReplaceCharacter s chFrom chTo =
	(
		offset = 0
		s = s as string
		for i = 1 to s.count do
		(
			if s[i+offset] == chFrom then
			(
				s = replace s (i+offset) 1 chTo
				offset += (chTo.count)
			)
		)
		return s
	),
	-- Get the value of this option as an array
	function GetArray =
	(
		try
		(
			s = GetValue()
			s = ReplaceCharacter s @"\" @"\\"
			return (execute s)
		)
		catch 
		(
			print (getCurrentException())
			return #()
		)
	),
	-- Get the value of this option as an integer
	function GetInt = 
	(
		return (GetValue() as integer)
	),
	-- Get the value of this option as a float
	function GetFloat =
	(
		return (GetValue() as float)
	)
) -- End struct Option
