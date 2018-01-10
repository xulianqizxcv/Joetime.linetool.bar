
(

	--try (cui.unRegisterDialogBar requestRollout; destroydialog requestRollout) catch()
	try (cui.unRegisterDialogBar TimeZoom) catch()
	try (destroydialog  TimeZoom) catch()

	if TimeZoom!= undefined do (try(cui.unRegisterDialogBar TimeZoom; destroydialog  TimeZoom)catch())

			rollout helpRollout "VizArt:TimeZoom v 1.0 Help" width:300 height:600
			(
				label lbl_about "About" pos:[8,8] width:288 height:80
				label lbl_help "Help" pos:[8,88] width:288 height:500
				HyperLink Hypl_homepage "www.vizartonline.com" pos:[90,540] width:144 height:15 address:"http://www.vizartonline.com" color:(color 6 105 255) hovercolor:(color 255 255 255) visitedcolor:(color 200 200 255) --color:(color 6 105 213) hovercolor:(color 6 105 213) visitedcolor:(color 78 78 177)
			)
/*
		rollout requestRollout "VizArtOnline: TimeZoom License" width:340
(
	edittext edt_req "Request: " width:310 height:20 align:#center readonly:true
	button myButton_GetLic "Buy License Code"	enabled:true

	on requestRollout open do
	(

		a=((((dotNetClass "System.Net.NetworkInformation.NetworkInterface").GetAllNetworkInterfaces())[1].getPhysicalAddress()).tostring())
			j=#()
			for i =1 to a.count do j[i]=bit.charAsInt a[i]
			sum=0
			for i=1 to j.count do sum+=j[i]
			sum+=amin j
			sum+=amax j
			k=""
			for i=1 to j.count do (k=k+((abs (cos(j[i]*i*sum)*100)) as integer) as string)

		requestRollout.edt_req.text=k

	)

	on requestRollout close do
	(
		TimeZoom.btn_PRO.enabled=true
		TimeZoom.btn_PRO.state=false
	)


	on myButton_GetLic pressed do
	(
		st="www.vizartonline.com/scripts/14-maxscripts/48-timeline-zoom-1-0.html?request="+requestRollout.edt_req.text
		ShellLaunch st ""
	)

)
*/

rollout TimeZoom "VizArt: Time Controller 1.0" width:1884 height:35
	(
	checkbutton btn_on "TZoom v1.0" pos:[380,8] width:85 height:21
    spinner spn_delta_2 "" pos:[300,8] width:68 height:16 range:[1,1e+009,10] type:#integer
	spinner spn_delta "" pos:[470,11] width:68 height:16 range:[1,1e+009,10] type:#integer --enabled:false
	slider sld_delta "" pos:[545,4] width:156 height:21 range:[1,100,10] type:#integer --enabled:false
	button btn_middle "Set Middle Here" pos:[700,8] width:150 height:21 --enabled:false
	checkbutton btn_PRO "Pro" pos:[860,8] width:31 height:21 --enabled: true
	button btn3 "X" pos:[900,8] width:21 height:21
	button btn_help "?" pos:[930,8] width:21 height:21

	local base_start,base_end, curr_time, OnOff=false,delta=10,now_start,now_end

	fn zoom_track =
	(
		if trackviews.currentTrackView!=undefined do
		(
			for i=1 to trackviews.numTrackViews() do
			(
			if (trackviews.isOpen i) then (	trackviews.setCurrent i; actionMan.executeAction 1 "2180")
			)
			)
	)

	fn delta_change =
	(
		if OnOff do
		(
			if (slidertime-base_start) <=delta then
			(
				now_start=base_start
				now_end=base_start+2*delta
			)
			else
			(
				if (base_end-slidertime) <=delta then
				(
					now_start=base_end-2*delta
					now_end=base_end
				)
				else
				(
					now_start=slidertime-delta
					now_end=slidertime+delta
				)
			)

			animationRange=interval now_start now_end

			forceCompleteRedraw
		)
	)

	fn time_p =
	(

	)

	on TimeZoom open do
	(
            TimeZoom.btn_PRO.enabled=false
			base_start=animationRange.start
				base_end=animationRange.end

				if (base_end-base_start)/2<delta do delta = ((base_end-base_start)/2)

				local delta_max=100

				if (base_end-base_start)/2<delta_max do delta_max = ((base_end-base_start)/2)

				sld_delta.range=[1,delta_max,delta]

				spn_delta_2.value=delta
				sld_delta.value=delta


				--registerTimeCallback time_p

		)

		on TimeZoom close do
	(
		animationRange=interval base_start base_end
		zoom_track()
		--unRegisterTimeCallback time_p
		--try (cui.unRegisterDialogBar requestRollout; destroydialog requestRollout) catch()
		try (cui.unRegisterDialogBar TimeZoom; destroydialog  TimeZoom	) catch()
		)

	on btn_PRO changed state do
	(


	if state then
	(
		btn_PRO.enabled=false
        --btn_PRO.enabled=true
		--createdialog requestRollout
		--cui.RegisterDialogBar requestRollout
	)

	)

	on btn_on changed state do
	(
		OnOff=not OnOff
		if OnOff then
		(

				base_start=animationRange.start
				base_end=animationRange.end

				if (base_end-base_start)/2<delta do delta = ((base_end-base_start)/2)

				local delta_max=100

				if (base_end-base_start)/2<delta_max do delta_max = ((base_end-base_start)/2)


			if (slidertime-base_start) <=delta then
			(
				now_start=base_start
				now_end=base_start+2*delta
			)
			else
			(
				if (base_end-slidertime) <=delta then
				(
					now_start=base_end-2*delta
					now_end=base_end
				)
				else
				(
					now_start=slidertime-delta
					now_end=slidertime+delta
				)
			)

			animationRange=interval now_start now_end

		)
		else
		(

			animationRange=interval base_start base_end

		)

		zoom_track()

		)
	on spn_delta changed val do
	(
			delta=val
			if delta>sld_delta.range[2] do sld_delta.range=[1,delta,delta]
			sld_delta.value=delta
			delta_change()
			--zoom_track()
		)

    on spn_delta_2 changed val do
    (
            delta=val
            if delta>sld_delta.range[2] do sld_delta.range=[1,delta,delta]
            sld_delta.value=delta
            delta_change()
            --zoom_track()
        )

	on sld_delta changed val do
	(
			delta=val
			spn_delta.value=delta
			delta_change()
			--zoom_track()
		)
	on btn_middle pressed do
	(
			delta_change()
			zoom_track()
		)

			on btn3 pressed  do
(

	--try (cui.unRegisterDialogBar requestRollout; destroydialog requestRollout) catch()
	try (cui.unRegisterDialogBar TimeZoom; destroydialog  TimeZoom	) catch()

	)

	on btn_help pressed do
	(
		createdialog helpRollout
		helpRollout.lbl_about.text="VizArt Time Zoom very usefull 3ds Max script for animators. It's way to fast 'Zoom In/Zoom Out' Timeline\r\n \r\nVersion: 1.0 Light (NOT FOR COMMERCIAL USE PLEASE)\r\n If You need commercial version - please buy Pro\r\n"
		st="Short Help: \r\n \r\nTZoom button - On/Off Script\r\n \r\nNumber and Slider: Half of active Timeline zone for Zoom (± from current Time)(Pro only)\r\n \r\n"
		append st "Set Middle Here:  Move active Timeline zone rather current time (current time will be middle of active timeline zone)(Pro only)\r\n \r\n"
		append st "Pro button: If pressed - You use Pro version of script. If not - You can press it and get request code for Your computer (based on MAC address) and buy (or ask by email :) license key from my site\r\n \r\n"
		append st "X: Close script. (You can start script when You need by drag&drop it to 3ds Max interface, or by Utilities>MAXScripr>Run Script, or place this script on 3DS MAx/Scripts/Startup folder for automatic strat Time Zoom with 3ds Max\r\n \r\n"
		append st "?: This short help. If You need, please visit site for additional information, updates, comments, etc. Have a nice animation!\r\n \r\n"
		append st "PostScriptum: Sorry, this script is not really commercial, it's one of many scripts that our team use for our work. But some animators convinced us of necessity given (and some other) scripts for users 3ds max. Use :). In case of a demand we will support and update according to your wishes and to spread other our scripts and plugins."

		helpRollout.lbl_help.text=st

	)

)

createdialog TimeZoom  style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox)
cui.RegisterDialogBar TimeZoom style:#(#cui_dock_all, #cui_floatable, #style_sysmenu)
cui.DockDialogBar TimeZoom #cui_dock_bottom

)