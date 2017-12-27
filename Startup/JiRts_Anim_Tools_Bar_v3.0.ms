/*
首先你能反编译看到我说的这些那你肯定比我屌 好用的反编译求分享
JiRts_Anim_Tools_Bar v3.0
---------------------------------------
Description:
Very Usefull to Control Your Animation 妈的中文意思就是为了方便！操！就是这么暴躁！
---------------------------------------
Patchwork By :JiRt 中文意思就是这脚本是老子东拼西凑花了点儿小心思整合到一起的，也有自己写的功能！干！
QQ:1588441
Email : JiRt@QQ.com
---------------------------------------
加密
encryptscript "C:\Program Files\Autodesk\3ds Max 2016\scripts\JiRts_Anim_Tools_Bar_v1.0.ms" version:1.0

---------------------------------------
修改时间:2015年10月10日14:35:44
增加了很多功能 不表述
去除了刷新模型
*/
---------------------------------------

/*2017-12-26
JiRts_Anim_Tools_Bar v_Joe.10
---------------------------------------



*/
(if atime != undefined do (try(cui.unRegisterDialogBar atime;destroydialog  atime)catch())

rollout roll_about "About" width:200
(
        label lab_dw "V_Joe.10 by Joe -2017/12/26"
        hyperlink lbl_01 "更新" address:"https://github.com/4698to/Joetime.linetool.bar" align:#Center
)

rollout atime "JiRts_Anim_Tools_Bar v_Joe.10" width:1800 height:34
(

	button	btn_close				"!"				pos:[0,5]		width:8		height:24   toolTip:"关闭工具栏"
	button	btn_ReStartMax			"卐"			pos:[8,5]		width:24	height:24	toolTip:"重启MAX"
	button btn_ReSet				"卍"			pos:[32,5]		width:24	height:24	toolTip:"重置MAX"
	button	btn_RunSpt				"R"			pos:[56,5]		width:24	height:24	toolTip:"Updates"

	--button	btn_PSgo				"编辑贴图"		pos:[380,5]		width:60	height:20	toolTip:"用PS打开已选择物体的贴图"
	button	btn_RescaleWU			"缩放单位"		pos:[440,5]		width:60	height:20	toolTip:"缩放世界单位以及蒙皮模型跟CS骨骼"
	button	btn_Copitor				"复制工具"		pos:[500,5]		width:60	height:20	--toolTip:"很给力"
	--button	btn_Spring				"骨骼解算"		pos:[560,5]		width:60	height:20	--toolTip:"很给力"


	button	btn_centerPivot			"轴心"			pos:[680,5]		width:40	height:20	toolTip:"坐标居中到对象"
	button	btn_bottomPivot			"轴底"			pos:[720,5]		width:40	height:20	toolTip:"坐标移到对象底部"
	button	btn_zeroMin				"落地"			pos:[760,5]		width:40	height:20	toolTip:"移到对象最低点坐标归零"
	button	btn_TransformZero		"归零"			pos:[800,5]		width:40	height:20	toolTip:"对象旋转位移全部归零"
	button	btn_XForm				"XForm"		pos:[840,5]		width:40	height:20	toolTip:"ResetXForm，并塌陷为POLY"


	--checkbox	chb_Lock			""				pos:[960,5]		width:30	height:24	checked:true	toolTip:"锁定对象"
	--label	lbl1					"锁定"			pos:[932,8]		width:28	height:24

	button btn_UHCAT	"[ CAT ]" pos:[970,5] width:50 height:20 toolTip:"隐藏显示CAT"

	button	btn_Boxmode				"[ Box ]"		pos:[1020,5]	width:50	height:20	toolTip:"显示为外框"
	checkbutton	btn_UHCS		"[ Bip ]"		pos:[1070,5]	width:50	height:20	highlightColor:	(color 214 148 25)	toolTip:"隐藏显示BIP"
	checkbutton	btn_UHBN		"[ Bone ]"		pos:[1120,5]	width:50	height:20	highlightColor:	(color 214 148 25)	toolTip:"隐藏显示Bone"

	spinner	spn1				"Start:"		pos:[1215,8]	width:50	height:20	range:[-1e+008,1e+008,0]	type:#integer scale:1
	spinner	spn2				"End:"			pos:[1298,8]	width:50	height:20	range:[-1e+008,1e+008,100]	type:#integer scale:1

	/*checkbutton	ckb_speed1		"1/4x"			pos:[1375,5]	width:30	height:20	highlightColor:	(color 102 84 204)
	checkbutton	ckb_speed2		"1/2x"			pos:[1405,5]	width:30	height:20	highlightColor:	(color 192 192 255)
	checkbutton	ckb_speed3		"1x"			pos:[1435,5]	width:30	height:20	highlightColor:	(color 255 229 8)
	checkbutton	ckb_speed4		"2x"			pos:[1465,5]	width:30	height:20	highlightColor:	(color 244 165 112)
	checkbutton	ckb_speed5		"4x"			pos:[1495,5]	width:30	height:20	highlightColor:	(color 216 34 13)
	*/
	-------------------------------
	label l_playSpeed "1x"  width:26 height:20 pos:[1375,5] align:#right --style_sunkenedge:true
	slider sp_playSpeed "" pos:[1405,-8] range:[1,5,3] orient:#horizontal ticks:1 type:#integer width:80 height:30

	-------------------------------



	----------unknow
	fn  initial =
	(
	 spn1.value = animationRange.start as time
	 spn2.value = animationRange.End as time
	 vuale = 	(spn2.value - spn1.value) as string
	 vuale1 =	(	(spn2.value - spn1.value)	+1 )as string
	)

	-----------unknow
	fn ReupDate =
	(

	oo = sliderTime = animationRange.start
	if oo != undefined do
	(
	spn1.value = animationRange.start as time
	spn2.value = animationRange.End as time
	)

	)

	----------Judge the number of selection
	fn fl_JudgeTheSelection =
	(	local type
	if selection.count == 1 then
	(	tempClass = classof (modPanel.getCurrentObject())
		if tempClass == Editable_Poly then
		(
			type = 1

			)
		else type = 0
	)
	else type = 0
	)
	fn fl_ifSelectPoly =
	(
		if fl_JudgeTheSelection() == 1 then return true
		else (
		messagebox "请选择一个EPoly物体并设置当前修改器在Editable Poly下！" title:fl_tips01 beep:off
		return false
		)
	)

	----------Get element numbers

	fn fl_getElementItem SourceOBJ =
	(
		tempSel = polyop.getFaceSelection SourceOBJ
		elementFirstFlags = #()
		faceCount = polyOp.getNumFaces SourceOBJ
		faceFlags = #{1..faceCount}
		for i in 1 to faceCount where not faceFlags.isempty do
		(	--start element count loop
			if faceFlags[i] then
			(	append elementFirstFlags i
				SourceOBJ.EditablePoly.SetSelection #Face #{i}
				SourceOBJ.selectElement()
				TargetElement = polyop.getFaceSelection SourceOBJ
				faceFlags -= TargetElement
			)
			else()
		)
		polyOp.setFaceSelection SourceOBJ tempSel
		elementFirstFlags
	)

	---------------------------------- button

	on atime open do
	(

		try(

			unregisterRedrawViewsCallback  initial

			registerRedrawViewsCallback  initial
			)catch()

	)
	fn Cet_Ly =
	(
		Sel_Obj=selection as array
		append Layer_Name Layer_N.text
		tem_Arr=#(Tools01.Layer_N.text,Sel_Obj,0)
		append Layer_All tem_Arr
	)-----隐藏显示CS

	----------spinner

	on spn1 changed val do
	(
	try (if spn1.value == spn2.value then  ( spn2.value=spn1.value+100;animationRange = interval spn1.value spn2.value)else (animationRange = interval spn1.value spn2.value)
		if spn1.value > spn2.value then  ( spn2.value=spn1.value+100;animationRange = interval spn1.value spn2.value)else (animationRange = interval spn1.value spn2.value)

	format  "Start Time:%\n"  animationRange.start
	format  "End Time:%\n"  animationRange.end)
	catch(animationRange = interval animationRange.start animationRange.End
			spn1.value = animationRange.start
			spn2.value = animationRange.End)

	)
	on spn2 changed val do
	(	try (if spn2.value == spn1.value then  ( spn1.value=spn2.value-100;animationRange = interval spn1.value spn2.value)else (animationRange = interval spn1.value spn2.value)
			                             sliderTime =spn1.value = animationRange.start
			                             format  "Start Time:%\n"  animationRange.start
										 format  "End Time:%\n"  animationRange.end)
										 catch(animationRange = interval animationRange.start animationRange.End
	  										 spn1.value = animationRange.start
											 spn2.value = animationRange.End)
	)


	---------------------------------
	on sp_playSpeed changed val do (
		case of	(
			(val == 1):	(l_playSpeed.text="1/4x"; timeConfiguration.playbackSpeed = 1)
			(val == 2):	(l_playSpeed.text="1/2x"; timeConfiguration.playbackSpeed = 2)
			(val == 3):	(l_playSpeed.text="  1x"; timeConfiguration.playbackSpeed = 3)
			(val == 4):	(l_playSpeed.text="  2x"; timeConfiguration.playbackSpeed = 4)
			(val == 5):	(l_playSpeed.text="  4x"; timeConfiguration.playbackSpeed = 5)
		)
	)
	----------checkbutton
	/*
	on ckb_speed1 changed state do
	(
		stopAnimation()
		if state then
		(
			ckb_speed2.state = false
			ckb_speed3.state = false
			ckb_speed4.state = false
			ckb_speed5.state = false
			timeConfiguration.playbackSpeed = 1
			playAnimation immediateReturn:true
		)
	)
	on ckb_speed2 changed state do
	(
		stopAnimation()
		if state then
		(
			ckb_speed1.state = false
			ckb_speed3.state = false
			ckb_speed4.state = false
			ckb_speed5.state = false
			timeConfiguration.playbackSpeed = 2
			playAnimation immediateReturn:true
		)
	)
	on ckb_speed3 changed state do
	(
		stopAnimation()
		if state then
		(
			ckb_speed1.state = false
			ckb_speed2.state = false
			ckb_speed4.state = false
			ckb_speed5.state = false
			timeConfiguration.playbackSpeed = 3
			playAnimation immediateReturn:true
		)
	)
	on ckb_speed4 changed state do
	(
		stopAnimation()
		if state then
		(
			ckb_speed1.state = false
			ckb_speed2.state = false
			ckb_speed3.state = false
			ckb_speed5.state = false
			timeConfiguration.playbackSpeed = 4
			playAnimation immediateReturn:true
		)
	)
	on ckb_speed5 changed state do
	(
		stopAnimation()
		if state then
		(
			ckb_speed1.state = false
			ckb_speed2.state = false
			ckb_speed3.state = false
			ckb_speed4.state = false
			timeConfiguration.playbackSpeed = 5
			playAnimation immediateReturn:true
		)
	)
	*/
	/*
	on chb_Lock changed theState do	----------锁定
	(
		if chb_Lock.checked == true then
			(
			for i = 1 to selection.count do
				(
				setTransformLockFlags selection[i] #{1,2,3,4,5,6,7,8,9}
				)
			)
		else
			(
			for i = 1 to selection.count do
				(
				setTransformLockFlags selection[i] #{}
				)
			)
	)
	*/
	----------button

	on btn_close pressed do	----------close bar
	 (
	 /*messagebox "
	 Thank you for using. :-)
	 Created by : JiRt
	 Email : JiRt@qq.com
	 " title:"JiRts_Anim_Tools_Bar v1.0" beep:false
     */
        try(cui.UnRegisterDialogBar atime)catch()
        try(destroyDialog atime)catch()
	 )

	on btn_ReStartMax pressed do	----------重启MAX
	 (
	 if checkForSave()
	 then (
		shellLaunch (getdir #maxroot+"\\3dsmax.exe") (maxfilepath+maxfilename)
		quitmax #noPrompt
			)
	 else ()
	 )


	on btn_RunSpt pressed do	---------- Updates
	 (
     --actionMan.executeAction 0 "40470"  -- MAX Script: Run Script
        CreateDialog roll_about
	 )

	on btn_Boxmode pressed do	----------框显
	 (
     --max box mode selected
        if selection.count == 1 then(
            try(
     	        max box mode selected
     	        sel=$
     	        bound = nodeGetBoundingBox sel sel.transform
     	        selSize = ( bound[2] - bound[1] )
     	        clock.active = true
     	        lab_height.text = "高: "+(selSize.z as string)
     	        lab_width.text = "宽: "+ (selSize.y as string)
     	        lab_length.text = "长: " + (selSize.x as string)
     	    )catch()--外框大小
        )
        else (
            max box mode selected
            )
    )


	on btn_centerPivot pressed do	----------轴心
	 (
		 if selection.count != 0 then
			(
		undo on
			(
			 selectObj = getCurrentSelection()
			 for i in selectObj do CenterPivot i
			)--end undo on
			)
	 )

	on btn_bottomPivot pressed do	----------轴底
	 (
		 if selection.count != 0 then
		 (
		undo on
			(
			selectObj = getCurrentSelection()
			for i in selectObj do
				(	CenterPivot i
				i.pivot.z = i.min.z
				)
			)--end undo on
		)
	 )

	on btn_zeroMin pressed do	----------落地
	 (
		 if selection.count != 0 then
		 (
		undo on
			(
			selectObj = getCurrentSelection()
			for i in selectObj do
				(	tempZ = i.pos.z
					tempMinZ = i.min.z
					i.pivot.z = i.min.z
					i.pos.z = 0
					i.pivot.z = tempZ - tempMinZ
				)
			)--end undo on
		)
	 )


	on btn_TransformZero pressed do	----------归零
	(
			undo on
				(
					if $ != undefined then
					(
						for i in selection do
						(
							if i.parent != undefined do
							(
							setAppData i 1 i.parent.name
							--setAppData i 2 ((in coordSys parent i.pos) as string)
							--setAppData i 3 ((in coordSys parent i.rotation) as string)
							)
							setAppData i 2 (i.transform as string)
							i.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
							/*
							i.pos.x 					=	0
							i.pos.y					=	0
							i.pos.z					=	0
							i.rotation.x_rotation 		=	0
							i.rotation.y_rotation 		=	0
							i.rotation.z_rotation 		=	0
							*/
						)
					)
				)
	)

	on btn_XForm pressed do	----------Xform & Collapse
	 (
		for theNode in selection do
		if (isValidNode(theNode)) do
			(
			ResetXForm theNode
			macros.run "Modifier Stack" "Convert_to_poly"
			)
	 )

	on btn_UHCS changed state do	----------隐藏CS
	(
		if state then
		(
			--CS_All=for i in objects where (classof i==Biped_Object or classof i == Dummy) collect i
			CS_All=for i in objects where (classof i==Biped_Object and i.ishidden ==false) collect i
			hide CS_All
		)
		else
		(
			--CS_All=for i in objects where (classof i==Biped_Object or classof i == Dummy) collect i
			CS_All=for i in objects where (classof i==Biped_Object and i.ishidden ==false) collect i
			unhide CS_All
		)
	)

	on btn_UHBN changed state do	----------隐藏BONE
	(
		if state then
		(
			Bn_All=for i in objects where (classof i==BoneGeometry and i.ishidden == false) collect i
			hide Bn_All
		)
		else
		(
			Bn_All=for i in objects where (classof i==BoneGeometry and i.ishidden == false) collect i
			unhide Bn_All
		)
	)

	on btn_RescaleWU pressed do	----------缩放单位
	(
filein (getdir #Scripts + "\JiRt_Scripts\JiRts_RescaleWU.mse")
	)

	on btn_Copitor pressed do	----------复制工具
	(
filein (getdir #Scripts + "\JiRt_Scripts\JiRts_Copitor.mse")
	)

	on btn_ReSet pressed do	----------重置max
	(
	 max reset file
	)

	on btn_PSgo pressed do	----------PS打开
		(


	(
	if selection.count == 0 then messagebox "请先选择要编辑贴图的一个或多个物体！" title:"提示："
		else
	(
maps_array = #()
for v in selection do (
for i in usedmaps (v) do (
	temp_maps = (finditem maps_array i) if temp_maps == 0 then
	(
	append maps_array i

		)
		)
	)

if maps_array.count != 0 then for i in maps_array do (try(psOLE = createOLEObject "Photoshop.Application"
	psOLE.open i)catch(messagebox "没有检测到您安装的PS!" tlele:"提示：")
	)
	else
(
		messagebox "当前物体没有贴图，或者贴图已丢失！" title:"提示："

	)
)
)
		)

	on btn_Spring pressed do	----------骨骼解算
	(
filein (getdir #Scripts + "\JiRt_Scripts\JiRts_Springmagic_0.9.mse")
	)


)
createdialog atime 1800 30 style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox)
cui.RegisterDialogBar atime style:#(#cui_dock_bottom, #cui_floatable, #style_toolwindow)
cui.DockDialogBar atime #cui_dock_bottom
--cui.getExpertMode()
--updateToolbarButtons()
)