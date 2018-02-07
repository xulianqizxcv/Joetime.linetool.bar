/* 
 License rollout
*/
struct LicenseRollout
(
	public
	roll,
	
	
	function CreateNonCommercial =
	(
		rollout roll "License"
		(
			hyperLink lblLink "http://creativecommons.org/licenses/by-nc-sa/4.0/" address:"http://creativecommons.org/licenses/by-nc-sa/4.0/" color:(color 200 128 50) visitedColor:(color 200 128 50)
			dotNetControl lblLicense "System.Windows.Forms.Label" height:110 width:250 align:#center--create a LABEL DotNetControl
			
			on roll open do
			(
				lblLicense.text = "This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
	http://creativecommons.org/licenses/by-nc-sa/4.0/
	If you want to use this script for commercial purposes, contact me for a paid version of the script." --set the text of the label
				lblLicense.backcolor = lblLicense.backcolor.fromARGB 70 70 70
				lblLicense.forecolor = lblLicense.forecolor.fromARGB 200 200 200
			)
		)
		
		return true
	),
	function CreateCommercial =
	(
		rollout roll "License"
		(
			hyperLink lblLink "http://creativecommons.org/licenses/by-sa/4.0/" address:"http://creativecommons.org/licenses/by-sa/4.0/" color:(color 200 128 50) visitedColor:(color 200 128 50)
			dotNetControl lblLicense "System.Windows.Forms.Label" height:110 width:250 align:#center--create a LABEL DotNetControl
			
			on roll open do
			(
				lblLicense.text = "This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
	http://creativecommons.org/licenses/by-sa/4.0/
	This script can be used for commercial purposes." --set the text of the label
				lblLicense.backcolor = lblLicense.backcolor.fromARGB 70 70 70
				lblLicense.forecolor = lblLicense.forecolor.fromARGB 200 200 200
			)
		)
		
		return true
	),
	-- Constructor function of LicenseRollout struct. Called at object creation.
	-- @return (boolean) true
	function Constructor =
	(
		-- Create the data object if doesn't exist. Saved in the global variable _data.
		if (_data == undefined) do	_data = DataObject()
		if _data.optionCommercial.Value() then CreateCommercial()
		else CreateNonCommercial()
		
		return true
	),
	init = Constructor()
)

/* 
 Commercial License rollout
*/
struct CommercialLicenseRollout
(
	public
	roll,
	
	-- Constructor function of LicenseRollout struct. Called at object creation.
	-- @return (boolean) true
	function Constructor =
	(
		rollout roll "License"
		(
			hyperLink lblLink "http://creativecommons.org/licenses/by-sa/4.0/" address:"http://creativecommons.org/licenses/by-sa/4.0/" color:(color 200 128 50) visitedColor:(color 200 128 50)
			dotNetControl lblLicense "System.Windows.Forms.Label" height:110 width:250 align:#center--create a LABEL DotNetControl
			
			on roll open do
			(
			
				lblLicense.text = "This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
	http://creativecommons.org/licenses/by-sa/4.0/
	This script can be used for commercial purposes." --set the text of the label
				lblLicense.backcolor = lblLicense.backcolor.fromARGB 70 70 70
				lblLicense.forecolor = lblLicense.forecolor.fromARGB 200 200 200
			)
		)
		
		return true
	),
	init = Constructor()
)
