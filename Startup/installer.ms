-- Installer script v0.5 by msi --

global instantRigFloater

try destroyDialog iRig_installer Catch()
rollout iRig_installer "InstantRig 1.5 Setup" width:210 height:60
(
	local isAdmin = false
	local tobat = #()
	local oldmax = (MaxVersion())[1]<16000
	local usermacros = (symbolicPaths.getPathValue "$userMacros")+"\\"
	local userscripts = (symbolicPaths.getPathValue "$userScripts")+"\\"
	local scripts = symbolicPaths.getPathValue "$scripts"+"\\"
	local tempdir = getFilenamePath (getSourceFileName())
	local scrname = "InstantRig"
	label lbl1 "Select an option:" pos:[5,5] width:200 height:13
	button install1 "Install" pos:[5,25] width:120 height:30 toolTip:("Install \""+userscripts+scrname+"\"") across:2
	button uninstall "Uninstall" pos:[130,25] width:75 height:30

	fn delDir DirPath AReq:false = (
		if doesFileExist dirPath do (
			command = "RD /S /Q \""+dirPath+"\""
			if isAdmin or not AReq then HiddenDOSCommand command startpath:".\\" else append tobat command
		)
	)
	fn delFile filePath AReq:false = (
		if doesFileExist filePath do (
			if isAdmin or not AReq then deleteFile filePath else append tobat ("DEL \""+filePath+"\" /Q /F")
		)
	)
	fn copyDir sourceDir destDir AReq:false = (
		command = "XCOPY \""+sourceDir+"*\" \""+destDir+"\" /Q /I /S /Y"	
		if isAdmin or not AReq then HiddenDOSCommand command startpath:".\\" else append tobat command
	)
	fn RunAsAdmin = (
		success=true
		if tobat.count > 0 then (
			batName = (tempdir+"batfile.bat")
			if doesFileExist batName do deleteFile batName
			batFile = createFile batName
			for i in tobat do format "%\n" i to:batFile
			close batFile
			procInfo = dotNetObject "System.Diagnostics.ProcessStartInfo" batName
			procInfo.WindowStyle = (dotNetClass "System.Diagnostics.ProcessWindowStyle").Hidden
			procInfo.Verb = "runas"
			try (
				proc = (dotNetClass "System.Diagnostics.Process").start procInfo
				setWaitCursor()
				proc.WaitForExit()
				proc.Close
			)Catch(
				success=false
				lbl1.text="Aborted!"
				MessageBox "Process is not completed properly!\nTry again."
			)
			tobat = #()
			success
		) else success
	)
	fn uninst = (
		try(cui.UnRegisterDialogBar instantRigFloater) catch()
		try(closerolloutfloater instantRigFloater) catch()
		::instantRigFloater=undefined
		gc()
		delDir (userscripts+scrname)
		for f in (getFiles (usermacros+"iRig*")) do delFile f
		for f in (getFiles (scripts+"iRig*")) do delFile f AReq:true
		RunAsAdmin()
	)
	fn checkuninst = (
		if doesFileExist(userscripts+scrname) or (getFiles (scripts+"iRig*")).count > 0 then (
			if qb = queryBox ("You have the "+scrname+" installed.  Do you want to uninstall it first?") title: "Warning" do uninst()
			qb
		) else true	
	)
	on iRig_installer open do (
		ident = (DotNetClass "System.Security.Principal.WindowsIdentity").GetCurrent()
		role = (DotNetClass "System.Security.Principal.WindowsBuiltInRole").Administrator
		isAdmin = (DotNetObject "System.Security.Principal.WindowsPrincipal" ident).IsInRole(role)
		if oldmax do (
			lbl1.text="Only 3dsmax 2014+ is supported!"
			install1.enabled = false
			uninstall.enabled = false 
		)
	)
	on install1 pressed do (
		if checkuninst() do ( 
			setWaitCursor()
			copyDir (tempdir+"scripts\\") userscripts
			copyDir (tempdir+"macros\\") usermacros
			sleep 1
			lbl1.text="Installed successfully."				
			try (filein (usermacros+"iRig_macro.mcr")) Catch()
			if queryBox "Installation complete!\n\nGo to Customize -> Customize User Interface, choose \"InstantRig\" in the Category list and assign the script wherever you want.\n\nOpen the Customize User Interface dialog now?" title: scrname do actionMan.executeAction 0 "59226"
		)
	)
	on uninstall pressed do (
		if queryBox "Are you sure?" title: "Uninstall!" do (
			lbl1.text="Started..."
			setWaitCursor()
			uninst()
			lbl1.text="Uninstalled successfully."
		)
	)
	on iRig_installer close do (
		if tempdir == symbolicPaths.getPathValue "$temp"+"\\iRig\\" do delDir tempdir
		iRig_installer = undefined
		gc()
	)
)
createDialog iRig_installer style:#(#style_toolwindow, #style_border, #style_sysmenu)