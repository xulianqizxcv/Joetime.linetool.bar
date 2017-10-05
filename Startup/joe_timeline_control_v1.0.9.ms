/*
TimeLine Control v1.0.6
-------------
by Dim_Walker (dw.deedoubleu@gmail.com)
Based on Time_Controlv0.1 by Ayoub Mahmoudi.
-------------
Please visit this page:
http://www.scriptspot.com/3ds-max/scripts/timeline-control
for version history and additional info.
*/
--================================================
/*
TimeLine Control v1.0.9
-------------
2017/8/25
by Joe (738746223@qq.com)
based on JiRts_Anim_Tools_Bar_v3.0 by JiRts(Email:JiRt@qq.com)
---------------------------------------------------
之前一直用 JiRts 的这个工具栏，特别好用，占的位置也好，可惜的加密的mse 不能根据需要改。
想找JiRts 讨份源码自己改来用，但他一直没空给我。
只能自己动手现实了。
基于 TimeLine Control 这个开源框架来改的。所有希望大家改过之后也不要加密，
方便大家，方便新手！！
---------------------------------------------------


 */

(
global TC

	struct TCstructDef	(
			ver = "1.0.6",
			Autocomplete = false,
			hitTest = false,
			--ddl_range2,
			sp_start,
			sp_end,
			sp_move,
			new_name_rol,
			name_rol,
			settings,
			sel_bone_Array=#(),
			sel_biped_Array=#(),
--			tc_settings,



fn setTimeRange = (
		--stopAnimation()
		animationRange = interval sp_start.value sp_end.value
),

fn updateSp_Values = (
	sp_start.value = (animationRange.start.frame as integer)
	sp_end.value = (animationRange.end.frame as integer)

),

fn goToPrev_Key =	(
	Previous_Key = trackbar.getPreviousKeyTime()
	if selection.count != undefined and Previous_Key != undefined do sliderTime = Previous_Key
),

fn goToNext_Key =	(
	Next_Key = trackbar.getNextKeyTime()
	if selection.count != undefined and Next_Key != undefined do sliderTime = Next_Key
),

fn load_Range2 SelectedItem = (
	if SelectedItem != undefined do
	(
		rangeArray = filterString SelectedItem " "
		Start_range = rangeArray[(rangeArray.count)-1] as integer
		End_range = rangeArray[(rangeArray.count)] as integer

		if Start_range != undefined and End_range != undefined do
		(
			animationRange = interval Start_range End_range
		)
		redrawViews()
	)
)
)
-- struct end



-- =========================================================================================================================
--														ROLLOUTS
-- =========================================================================================================================

-- ==================================
--					Timeline Control Settings
-- ==================================

	rollout timerange ("TimeLine Control v.1") width:25
	(

		button bt_close "!"  width:8 tooltip:"Close" pos:[0,2]
		button bt_ret_max " R " width:22 tooltip:"..." pos:[8,2]
		button bt_009 ".." tooltip:"..." width:22 pos:[30,2] enabled:false


		button bt_012 "Save" width:30 tooltip:"Save File Path" pos:[235,2] --enabled:false
		button bt_011 "CM" width:30 tooltip:"单位CM" pos:[265,2] --enabled:false
		button bt_010 ".." width:30 tooltip:"..." pos:[295,2] enabled:false
		button bt_013 "CAT" width:30 tooltip:"CAT_Posture" pos:[325,2] --enabled:false




		button bt_008 "BipedKey" tooltip:"转移 Biped 位移工具" width:60 pos:[420,2] --enabled:false
		button bt_007 "Point" tooltip:"创建 Point 工具" width:40 pos:[480,2] --enabled:false
		button bt_006 "缩放" tooltip:"缩放世界单位,骨骼,蒙皮" width:40 pos:[520,2] --enabled:false
		button bt_005 "复制" width:40 pos:[560,2] --enabled:false --tooltip:".."
		-------------------------------------------------------------------
		button bt_004 "轴心" tooltip:"轴心居中" width:40 pos:[640,2] --enabled:false
		button bt_003 "轴底" tooltip:"轴心移动到对象底部" width:40 pos:[680,2] --enabled:false
		button bt_002 "落地" tooltip:"模型底部触原点" width:40 pos:[720,2] --enabled:false
		button bt_pos_rot "归零" tooltip:"位移旋转归零" width:40 pos:[760,2] --enabled:false
		button bt_reset_xf "XForm" tooltip:"重置模型" pos:[800,2] width:40--enabled:false
		----------------------------------------------------------------------
		label lab_length "" tooltip:"长" height:20 pos:[1580,4]
		label lab_width "" tooltip:"宽" height:20 pos:[1510,4]
		label lab_height "" tooltip:"高" height:20 pos:[1650,4]

		timer clock "" interval:6000 active:false --计时器




		button bt_box "[ Box ]" width:45 tooltip:"显示为外框" pos:[910,2] --enabled:false
		checkbutton bt_hi_bip "[ Bip ]" width:45 tooltip:"隐藏显示Bip" pos:[955,2] --enabled:false
		checkbutton bt_hi_bone "[ Bone ]" width:45 tooltip:"隐藏显示Bone" pos:[1000,2] --enabled:false
		--------------------------------------------------------------------------------------------
		label l_playSpeed "1x"  width:26 height:20 pos:[1060,4] align:#right --style_sunkenedge:true
		slider sp_playSpeed "" pos:[1096,-8] range:[1,5,3] orient:#horizontal ticks:1 type:#integer width:80 height:30
		-----------------------------------------------------------------------------------------------------------------
		spinner sp_start "Start:" range:[-99999999,99999999,(animationRange.start.frame as integer)] type:#integer fieldWidth:39 pos:[1186,4]
		spinner sp_end "End:" range:[-99999999,99999999,(animationRange.end.frame as integer)] type:#integer fieldWidth:39 pos:[1275,4]
		--------------------------------------------
		button bt_sltime_a "" pos:[1375,2] width:30
		button bt_sltime_b "" pos:[1405,2] width:30
		button bt_up_a "<" pos:[1435,2] width:30

	--  =====================================================================
		on bt_ret_max pressed do (
			ShellLaunch "https://github.com/4698to/Joetime.linetool.bar"
			)
	---------------------------------------------------------
		on bt_013 pressed do (
			try (
				filein (getdir #userScripts + "\\joe_script\\CAT_pose_v2.6.ms")
			)catch(print"no find")
		)
	------------------------------------------------------------
		on bt_012 pressed do (
			try (
				--filein (getdir #userScripts + "\\")
                j_save = getmaxsavefilename filename:(maxfilepath+maxfilename)
                    if j_save!=undefined do
                    (
                        savemaxfile j_save
                    )
			)catch(print"no find")
		)
	-------------------------------------------------------
		on bt_011 pressed do (
			try (
				--filein (getdir #userScripts + "\\")
                units.DisplayType = #metric

                units.MetricType = #centimeters

                units.SystemType = #Centimeters
			)catch(print"no find")
		)
	---------------------------------------------------
		/*on bt_010 pressed do (
			try (
				filein (getdir #userScripts + "\\")
			)catch(print"no find")
		)*/
	------------------------------------------------
		/*on bt_009 pressed do (
			try (
				filein (getdir #userScripts + "\\")
			)catch(print"no find")
		)*/
	---------------------------------------------------------------
		on bt_008 pressed do (
			try (
				filein (getdir #userScripts + "\\joe_scripts\\joe_Biped key Tool.v1.1.mse")
			)catch(print"no find")
		)
	------------------------------------------------------------
		on bt_007 pressed do (
			try(
				filein (getdir #userScripts + "\\joe_scripts\\joe_Sele_Point_v01.ms")
			)catch(print"no find")
		)
	---------------------------------------------------------------
		on bt_006 pressed do (
			try(
				filein (getdir #userScripts + "\\joe_scripts\\JiRts_RescaleWU.mse")
			)catch(print"no find")
		)
	-----------------------------------------------------------
		on bt_005 pressed do (
			try (
				filein (getdir #userScripts + "\\joe_scripts\\JiRts_Copitor.mse")
			)catch(print"no find")

		)
	-------------------------------------------------------------
		on clock tick do (
			lab_height.text = ""
			lab_width.text = ""
			lab_length.text = ""
			clock.active = false

		)
		on bt_hi_bone changed state do (
			try(
				if state == on then (
					objs = objects as array
					--sel_bone_Array = #()
					for i in objs do (
						if classof i == BoneGeometry and i.ishidden == false do (
							append TC.sel_bone_Array i
							i.ishidden = true
						)

					)
				)--隐藏bone
				else(
					for i in TC.sel_bone_Array do (
						i.ishidden =false

					)
				)--显示bone
			)catch()
		)
	---------------------------------------------------------------
        on bt_hi_bip changed state do(
        	try(
	            if state then(
	                objs = objects as array
	                --sel_biped_Array = #()

	                for i in objs do (
	                	if classof i ==	 Biped_Object and i.ishidden ==false do (
	                		append TC.sel_biped_Array i
	                		i.ishidden = true
	                	)
	                )
	            )--隐藏biped
	            else(
	                for i in TC.sel_biped_Array do (
	                	i.ishidden =false
	                )
	            )--显示biped
	        )catch()
        )
        ----------------------------------------
        on bt_box pressed do (
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

        -------------------------------------
        on bt_004 pressed do (
        	if selection.count != 0 do (CenterPivot $)

        )

        -----------------------------------------
        on bt_003 pressed do (
            try (
                for i in selection do (
                    sel=i
                    bound = nodeGetBoundingBox sel sel.transform
                    sel.pivot.z = sel.pivot.z + bound[1].z

                )
            )catch(print "Pivot - Bug")
        )

        --------------------------------------------
        on bt_002 pressed do (
            try(
                for i in selection do (
                    sel=i
                    bound_2 = nodeGetBoundingBox sel (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
                    sel.pos.z =  sel.pos.z - bound_2[1].z
                )
            )catch(print "Pos - bug")
        )

        --------------------------------------------------
        on bt_pos_rot pressed do (
        	try (
            	$.position = [0,0,0]
            	$.rotation = (quat 0 0 0 0)
            )catch()
        )
        on bt_reset_xf pressed do (

        		try (
            		resetxform selection
            		convertTo selection Editable_Poly
            		)catch()

        )
		on bt_sltime_a pressed do (
			bt_sltime_a.text = (sliderTime.frame as integer) as string
		)

		on bt_sltime_b pressed do (
			bt_sltime_b.text = (sliderTime.frame as integer) as string
		)
		on bt_up_a pressed do (
			if sliderTime == (bt_sltime_a.text as integer) then (
				sliderTime = (bt_sltime_b.text as integer)
			)
			else (
				sliderTime = (bt_sltime_a.text as integer)
			)
		)
	----------------------------------------------------------
		on bt_addrange pressed do (
			try(createdialog name_rol)catch()
			TC.name_rol = name_rol
			setFocus name_rol.edt_name
		)

	---------------------------------------------------------------
		on sp_move changed val do TC.moveListItem (sp_move.value)

		on bt_rename pressed do	(
			try(createdialog new_name_rol)catch()
			setFocus new_name_rol.edt_new_name
			TC.new_name_rol = new_name_rol
		)

		on bt_sortName pressed do TC.sortRanges false

		on bt_sortFrame pressed do TC.sortRanges true

		on bt_delete pressed do TC.deleteRange()

		on sp_end changed val do (
				if sp_end.value <= sp_start.value then sp_start.value = (sp_end.value)-1
				TC.setTimeRange()
		)

		on bt_Prevframe pressed do TC.goToPrev_Key()
		on bt_Nextframe pressed do TC.goToNext_Key()

		on sp_start changed val do (
				if sp_start.value >= sp_end.value then sp_end.value = (sp_start.value)+1
				TC.setTimeRange()
		)
		on sp_end changed val do (
				if sp_end.value <= sp_start.value then sp_start.value = (sp_end.value)-1
				TC.setTimeRange()
		)

		on sp_playSpeed changed val do (
			case of	(
				(val == 1):	(l_playSpeed.text="1/4x"; timeConfiguration.playbackSpeed = 1)
				(val == 2):	(l_playSpeed.text="1/2x"; timeConfiguration.playbackSpeed = 2)
				(val == 3):	(l_playSpeed.text="  1x"; timeConfiguration.playbackSpeed = 3)
				(val == 4):	(l_playSpeed.text="  2x"; timeConfiguration.playbackSpeed = 4)
				(val == 5):	(l_playSpeed.text="  4x"; timeConfiguration.playbackSpeed = 5)
			)
		)

		on bt_expSettings pressed do try(createdialog fbx_settings)catch()

		on cb_loop changed val do timeConfiguration.playbackLoop = val

		on bt_TCsettings pressed do try(createdialog tc_settings)catch()

		on bt_close pressed do	(
			try(cui.UnRegisterDialogBar timerange)catch()
			try(destroyDialog timerange)catch()
		)




		-- ==================================
		--			CREATE ROLLOUT
		-- ==================================

	)
		TC=TCstructDef()
		TC.sp_start = timerange.sp_start
		TC.sp_end = timerange.sp_end

		createdialog timerange
		cui.RegisterDialogBar timerange minSize:[300,20] maxSize:[3000,25] style:#(#cui_dock_bottom,#cui_dock_top, #cui_floatable, #style_toolwindow,#style_sysmenu)
		cui.DockDialogBar timerange #cui_dock_bottom

		callbacks.addScript #animationRangeChange "TC.updateSp_Values()" id:#Sp_Values



)