/* 
 Info rollout
*/
struct InfoRollout
(
	public
	roll,
	
	-- Constructor function of InfoRollout struct. Called at object creation.
	-- @return (boolean) true
	function Constructor =
	(
		rollout roll "Info"
		(
			dotNetControl lblInfo "System.Windows.Forms.Label" height:53 width:250 align:#center
			hyperLink lblLink "Website" address:"http://josbalcaen.com/scripts/max/batch-exportimport/" color:(color 200 128 50) visitedColor:(color 200 128 50) across:2
			hyperLink lblLinkMail "contact@josbalcaen.com" address:"mailto:contact@josbalcaen.com" color:(color 200 128 50) visitedColor:(color 200 128 50)
			
			on roll open do
			(
				lblInfo.text = "Batch Export/Import is a script to export multiple objects at once. If you have questions, requests don't hesitate to contact me."
				lblInfo.text += " For more information about all options, please visit my site."
				lblInfo.backcolor = lblInfo.backcolor.fromARGB 70 70 70
				lblInfo.forecolor = lblInfo.forecolor.fromARGB 200 200 200
			)
		)
		return true
	),
	init = Constructor()
	
	
)
