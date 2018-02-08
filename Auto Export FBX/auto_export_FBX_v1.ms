/*Macroscript Exporter
category:"Custom"
tooltip:" ExportTool "
--buttontext:"None"
*/
--savePath = (getSavePath "Save to:" initialDir:(@"C:\Users\"+sysInfo.username+"\Desktop")) as string
rollout exportWindow "Auto Export FBX v.1"
(
	global j_exp
	struct exp_test
	(
		copyType=1,
		exConfigFile="",
		pathSource,
		pathSave,
		set_ExportFBXPreset=#(),

		cust_file = "", -- 当前操作的文档
		export_file_name = #() ,--导出骨骼名单
		export_file_list = #(),-- 导出骨骼列表

		tem_file_fbx,
		tem_file_max ,
		set_Exp_settings = #(),
		--CopyPasteAniIni_name = (getdir #userScripts) + "\\joe_scripts\\"+ "CAT-Posture_Anim_2" + ".ini" ,
        CopyPasteAniIni_name,--导出配置文件
		---------------------------------------------------------------------
		fn StringIsEmpty str=
		(
			if (str==undefined or str=="" or str==" ") then
			(
				return true
			)else
			(
				return false
			)
		),
		---------------------------------------------------------------------
		fn get_end_key_time =  --获取obj 头尾帧 ，用来控制导出时间轴区间
		(
            local obj_name = getINISetting j_exp.CopyPasteAniIni_name "SaveHistory" "root_key"
            local obj = execute("$"+ obj_name)
            if obj != undefined do
            (
                try (

                    if classOf obj == Biped_Object then ()

                    else if classOf obj == CATBone then ()
                    else
                    (
            			if obj != undefined and obj[3][1].keys.count <= 1 then  --检查标记帧区间对象是否正常 ，
            			(
            				print j_exp.cust_file + obj.name +"没有设置标记区间帧"
            			)
            			else
            			(
                            try
                            (
                				kk = obj[3][1].keys.count--
                				--return #(obj[3][1].keys[1].time,obj[3][1].keys[kk].time)
                				s_t = (obj[3][1].keys[1].time.frame) as Integer
                				e_t = (obj[3][1].keys[kk].time.frame) as Integer
                				animationRange = interval s_t e_t
                            )catch()
            			)
                    )
                )catch()
            )
		),

		fn set_bt_get_root_key obj =  --写入导出区间标记骨骼名
		(
			setINISetting j_exp.CopyPasteAniIni_name "SaveHistory" "root_key" obj.name
		),

		fn get_bt_get_roo_key = --读取导出区间标记骨骼名
		(
			getINISetting j_exp.CopyPasteAniIni_name "SaveHistory" "root_key"
		),

		fn create_config = --创建配置文件 Export_config.ini
		(
			--if set_Exp_settings.count != 0 then (
				if j_exp.CopyPasteAniIni_name == undefined then
				(
					if j_exp.pathSource == undefined then
					(
						j_exp.CopyPasteAniIni_name = (getdir #userScripts) + "\\joe_scripts\\"+ "CAT-Posture_Anim_2" + ".ini" --在没有设置源路径 时，使用默认目录
					)
					else
					(
						j_exp.CopyPasteAniIni_name = j_exp.pathSource + "\\Export_config"+".ini" --设置源路径时，在源路径下新建
					)
					append j_exp.set_Exp_settings j_exp.CopyPasteAniIni_name

					j_exp.set_Exp_settings = makeUniqueArray j_exp.set_Exp_settings
					exportWindow.ddl_expoer_Preset.items = j_exp.set_Exp_settings
					exportWindow.ddl_expoer_Preset.tooltip = j_exp.set_Exp_settings[exportWindow.ddl_expoer_Preset.selection] --as string
				)
		 		else
		 		(

					append j_exp.set_Exp_settings j_exp.CopyPasteAniIni_name

					j_exp.set_Exp_settings = makeUniqueArray j_exp.set_Exp_settings
					exportWindow.ddl_expoer_Preset.items = j_exp.set_Exp_settings
					exportWindow.ddl_expoer_Preset.tooltip = j_exp.set_Exp_settings[exportWindow.ddl_expoer_Preset.selection] --as string
				)
			--)

		),
		---------------------------------------------------------------------

		fn find_file type = 	-- 找到 源 路径 文件夹里面的FBX - max 文件，忽略次级目录
		(
			local from_path = j_exp.pathSource + @"\"
			if type == 1 do (j_exp.tem_file_fbx = getFiles (from_path + "*"+".FBX"))
			if type == 2 do (j_exp.tem_file_max = getFiles (from_path + "*"+".max"))

		),
		---------------------------------------------------------------------
		fn load_fiel fpath = --导入 MAX FBX
		(
			if (getFilenameType fpath) == ".FBX" do (
				FBXImporterSetParam "Mode" #create --设置导入类型 #create (Add) #exmerge (Add and Update Animation) #merge (Update animation).
				importFile fpath #noPrompt
			)
			if (getFilenameType fpath) == ".max" do(
				try (
					loadMAXFile fpath useFileUnits:true quiet:true  -- 打开max 文件
					)
				catch(print "版本不匹配？")
			)

		),
		---------------------------------------------------------------------
		fn export_file fpath = --导出FBX
		(
			local ex_file_name = j_exp.pathSave + @"\"+ (getFilenameFile fpath)+".FBX"  -- 导出文件名 与当前操作文件同名

			FBXExporterSetParam "LoadExportPresetFile" j_exp.exConfigFile --设置FBX导出预设(导出模型或者动画) max2015 D:\Documents\3dsMax\FBX\3dsMax2014_X64\Presets\2015.1\export

			local theClasses =exporterPlugin.classes
			exportFile ex_file_name #noPrompt selectedOnly:true using:theClasses[9] --全场景导出操作，非选择导出

		),
	--------------------------------------------------------------------- 导出骨骼
		fn set_export_bone_filename_list =  -- 写入导出骨骼名单
		(
			/*
			local all_obj = objects as array --- !!!!!!!!

			--local export_file_name = #()
			if all_obj.count != 0 do (  -- 确保场景内不为空
				for i in all_obj do(
					append export_file_name i.name
				)*/
				--CopyPasteAniIni_name = (getdir #userScripts) + "\\joe_scripts\\"+ "CAT-Posture_Anim_2" + ".ini" --配置文件
				if j_exp.export_file_name.count != 0 do (
					setINISetting j_exp.CopyPasteAniIni_name "obj_num" "count" (j_exp.export_file_name.count as string)	--写入配置，导出骨骼数
					for i=1 to j_exp.export_file_name.count do(
						local name_string = i as string
						local n_name = j_exp.export_file_name[i]
						setINISetting j_exp.CopyPasteAniIni_name "SaveHistory" name_string n_name --写入导出骨骼列表

                        local se_obj
                        try (se_obj = execute("$"+n_name)) catch(se_obj = execute("$"+"'"+n_name+"'")) --特为Bib CAT 准备
                        if se_obj.boneEnable then(setINISetting j_exp.CopyPasteAniIni_name "Bone_on_0_1" n_name "1" )--写入Bone on 开关
                        else(setINISetting j_exp.CopyPasteAniIni_name "Bone_on_0_1" n_name "0")
					)
				)
		),

		---------------------------------------------------------------------
		fn get_export_bone_filename_list = --读取导出骨骼名单，bone on 值
		(
			local export_count = (getINISetting j_exp.CopyPasteAniIni_name "obj_num" "count") as integer -- 读取导出骨骼数
			--export_file_name = #()
			j_exp.export_file_list =#()

			for o=1 to export_count do (
				local bone_name = getINISetting j_exp.CopyPasteAniIni_name "SaveHistory" (o as string)
				append j_exp.export_file_name bone_name

                local g_bone_0_1 = getINISetting j_exp.CopyPasteAniIni_name "Bone_on_0_1" bone_name --读取 Bone on 值
                local objjj = execute("$"+ bone_name)
                if g_bone_0_1 == "1" then
                (
                    objjj.boneEnable = true
                )
                else
                (
                    objjj.boneEnable = false
                ) --设置 Bone on
                --if objjj == undefined do ( continue)
				append j_exp.export_file_list objjj
			)
		),
		---------------------------------------------------------------------
		fn sele_bone_name_list  =  --按名单选择
		(
			--try (
				if j_exp.export_file_name.count !=0 do (
					for i in j_exp.export_file_name do (
						if execute("$"+ i) == undefined do ( continue)--防止场景中不存在 读取到名字的对象
						local objjj = execute("$"+ i)
						--objjj.boneEnable=true
						--append export_file_list (execute("$"+ i))
						append j_exp.export_file_list objjj
					)
				)
			--)catch()
		),
	--------------------------------------------------------------------- end 导出骨骼
		fn FilesProcess fPath=
		(
			arrNameTypes=#()
			case copyType of
				(
					1:
					(
						append arrNameTypes ".max"
					)
					2:
					(
						append arrNameTypes ".max"
						append arrNameTypes ".png"
					)
					3:
					(
						append arrNameTypes ".max"
						append arrNameTypes ".tga"
					)
					4:
					(
						append arrNameTypes ".max"
						append arrNameTypes ".psd"
					)
					5:
					(
						append arrNameTypes ""
					)
				)
			for type in arrNameTypes do
			(
				theFiles=getFiles(fPath+@"/*"+type)
				if (theFiles!=undefined and theFiles.count>0) then
				(
					for f in theFiles do
					(

						fileNameType= getFilenameType  f
						newPath=replace fPath 1 (pathSource.count) pathSave
						if (doesFileExist newPath)==false do
						(
							makeDir newPath --create folder
						)
						if fileNameType==".max" then
						(

							FBXExporterSetParam "LoadExportPresetFile" j_exp.exConfigFile
							saveMaxFile f
							max select all
							fileName=getFilenameFile f
							exportFile  (newPath+@"\"+fileName+".fbx") #noPrompt selectedOnly:true using:FBXEXP
						)
						else
						(
							copyFile f (newPath+(filenameFromPath  f))
						)
					)
				)
			)

		),
		--Find Path
		fn FindFile fPath =
		(
			--print fPath
			for dir in GetDirectories (fPath+@"\*") do
			(
				--ExportFBX dir oldPath newPath
				FindFile dir
			)
			FilesProcess fPath
		)


		--try(destroyDialog exportWindow )catch()
		--rollout exportConfig "Configuration"
		--(
			/*
			radiobuttons  rad_SeType "CopyFile :" \
			labels:#("None","PNG","TGA","PSD","ALL") columns:5 align:#left  \
			offsets:#([65,-16], [5,-16], [-60,-16], [-120,-16],[-180,-16]) default:1
			on rad_SeType  changed state do
				(
					copyType=state
				)
			*/



		--)
	)
--end struct

---------------------------------------------------------------------------------
	--rollout exportWindow "Export"
	--(

		group "目标路径"--Source Path
		(
			editText sourceTxt "Imp:" fieldWidth:270 labelOnTop:false across:2 align:#left
			button sourceButton "..." width:35 height:25 offset:[65,-5]
		)
		group "保存路径"--Save Path
		(
			edittext prefix_Save "Out:" fieldWidth:270 labelOnTop:false across:2 align:#left
			button btn_Save "..."  width:35 height:25  offset:[65,-5]  --across:2 align:#right
		)
		button export_Button "自动导出"  width:200 height:30 --across:2 alingn:#cent
		--checkbutton  chk_Config  "OpenConfig"  width:100 height:25
		--button chk_Config  "OpenConfig"  width:100 height:25
		group "设置" (--Setting
					--checkbox load_fiel_type_fbx "" offset:[1,0] across:4
					--label lblInfo_fbx "FBX" offset:[-95,0] tooltip:"处理FBX文件"--align:#left
					button bt_get_root_key "帧区间标记" width:80 height:20  tooltip:"设置导出时间轴标记对象" --across:2 offset:[-1,-2]
					--label bt_get_root_key_info "" offset:[-1,0]

					--checkbox load_fiel_type_max "" checked:true offset:[1,0] across:4
					--label lblInfo_max "MAX" offset:[-94,0] tooltip:"处理MAX文件"--align:#left
				    button bt_get_exp_list "导出对象" width:80 height:20 tooltip:"设置导出骨骼，会记录下对象的Bone on属性" --across:2 offset:[-1,-2]
				    --label bt_get_exp_list_info "" offset:[-1,-2]
				    -- Group body.
				)
		group "预设"--Preset
		(
		    -- Group body.

			label exp_config "导出预设:" across:3 offset:[-30,3]
			dropdownlist ddl_expoer_Preset "" width:240 height:20 items:(j_exp.set_Exp_settings) tooltip:"" offset:[-50,0]
			button bt_config_1 "..." width:25 height:20 offset:[45,0] tooltip:"打开文件夹"

			label cbx_FBX_pre "FBX预设:" across:3 offset:[-30,3]
		     --dropdownlist ddlOutputpath width:240 height:20 items:(_data.optionOutputPath.Value()) tooltip:"" offset:[-40,0]
			dropdownlist ddlPreset "" width:240 height:20 items:(j_exp.set_ExportFBXPreset) tooltip:"" offset:[-50,0]
			button btnGetFolder "..." width:25 height:20 tooltip:"打开文件夹" offset:[45,0]
		)
		hyperlink lbl_01 "帮助" address:"https://github.com/4698to/Joetime.linetool.bar" align:#Center

		--button btn_ExConfigPath "Find Export Configuration File " width:355 \
		--tooltip:"EX: C:\Users\UserName\Documents\3dsMax\FBX\3dsMax2014_X64\Presets\2015.0\export"
---------------------------------------------------------------------------------
		on load_fiel_type_fbx changed state do (type_fbx = state ) --设置处理 FBX 文档类型
		on load_fiel_type_max changed state do (type_max = state ) --设置处理 MAX 文档类型 可同勾选两项

		on ddl_expoer_Preset selected itm do
		(
			j_exp.CopyPasteAniIni_name = exportWindow.ddl_expoer_Preset.items[itm]
			exportWindow.ddl_expoer_Preset.tooltip = j_exp.set_Exp_settings[itm] --as string
		)

		on bt_config_1 pressed do  --设置导出对象预设
		(

			local get_Export_obj_config= getOpenFileName  types:"ini(*.ini)|*.*" filename:((getdir #userScripts) + "\\joe_scripts\\") --优先路径
			if get_Export_obj_config != undefined do(

				j_exp.CopyPasteAniIni_name = get_Export_obj_config

				append j_exp.set_Exp_settings get_Export_obj_config
				j_exp.set_Exp_settings = makeUniqueArray j_exp.set_Exp_settings

				--更新 UI
				exportWindow.ddl_expoer_Preset.items = j_exp.set_Exp_settings
				--exportWindow.ddl_expoer_Preset.tooltip = set_Exp_settings[exportWindow.ddl_expoer_Preset.selection]--as string
				ddl_expoer_Preset.tooltip = j_exp.CopyPasteAniIni_name
				bt_get_root_key.text = j_exp.get_bt_get_roo_key()
				bt_get_exp_list.text = getINISetting j_exp.CopyPasteAniIni_name "obj_num" "count"
			)
		)
		on bt_get_root_key pressed do -- 选取导出时间轴区间标记对象
		(
			if selection.count != 0 then (

				j_exp.create_config()
				j_exp.set_bt_get_root_key selection[1]
				bt_get_root_key.text = selection[1].name
				)
			else (
				messagebox("Selection Is Null .")
				)
		)
		---------------------------------------------------------
		on bt_get_exp_list pressed do --选取导出对象
		(
			if selection.count != 0 then (
				j_exp.export_file_name =#()
				for i in selection do(
					append j_exp.export_file_name i.name
				)
				bt_get_exp_list.text = j_exp.export_file_name.count as string
				j_exp.create_config() --创建
				j_exp.set_export_bone_filename_list() --写入
			)
			else (
				messagebox("Selection Is Null .")
				)
		)
		on sourceTxt changed txt do
			(
				--And the name is not the empty string,
				if txt != "" do
				(
					pathSource = txt
				)

			)


		on sourceButton pressed do
			(
				local sp = getSavePath caption "Select Source Path"
				if sp!=undefined do
				(
					sourceTxt.text= sp
					j_exp.pathSource=sp
				)

			)

		on prefix_Save changed txt do
			(
				--And the name is not the empty string,
				if txt != "" do
				(
					j_exp.pathSave=txt
				)
			)

		on btn_Save pressed do
		(
			local sp_2= getSavePath caption "Select Save Path"
			if sp_2!=undefined do
			(
				prefix_Save.text= sp_2
				j_exp.pathSave=sp_2
			)
		)




		on export_Button pressed do
		(
				--print sourceTxt.text
				--print saveTxt.text

				if (j_exp.StringIsEmpty j_exp.pathSource) then
				(
					messagebox("请设置源路径")
				)

				else if (j_exp.StringIsEmpty j_exp.pathSave)then
				(
					messagebox(" Save Path Is Null .")
				)

				else if (j_exp.StringIsEmpty j_exp.exConfigFile)then
				(
					messagebox(" 请设置FBX导出预设 .\n Example C:\Users\UserName\Documents\
						\n 3dsMax\FBX\3dsMax2014_X64\Presets\2015.0\export")
				)

				else
				(
					--try
					--(
						j_exp.find_file 2
						if j_exp.tem_file_max.count != 0 do(
							for i=1 to j_exp.tem_file_max.count do
							(
								j_exp.load_fiel j_exp.tem_file_max[i] --打开导入MAX-FBX
								j_exp.cust_file = j_exp.tem_file_max[i]
	                            j_exp.get_end_key_time()--设置导出时间轴
								j_exp.get_export_bone_filename_list() --读取导出骨骼名单
								select j_exp.export_file_list --选择导出对象
								j_exp.export_file j_exp.tem_file_max[i] --导出
							)
						)
					--)
					--catch
					--(
						--format "*** % ***\n" (getCurrentException())
					--)
				)
		)

		/*
		on chk_Config changed state do
		(
				if state then
				(
					exportWindow.height=350
				)
				else
				(
					exportWindow.height=135
				)
		)
		*/
		on chk_Config pressed do
		(

		)
		/*
		on btn_ExConfigPath pressed do
		(
			f = getOpenFileName types:"Data(*.fbxexportpreset)|*.fbxexportpreset"
			if f!=undefined do
			(
				btn_ExConfigPath.text=f
				exConfigFile=btn_ExConfigPath.text
			)
		)*/

		--SubRollout theSubrollout "Configuration" height:95  --width:360 offset:[-5,0]

		on ddlPreset selected itm do
		(
			ddlPreset.tooltip = filenamefrompath (ddlPreset.items[itm] as string)
			j_exp.exConfigFile=ddlPreset.items[itm]
		)

		on btnGetFolder pressed do
		(
			local get_ExportFBXPreset = getOpenFileName filename:"D:\Documents\3dsMax\FBX\3dsMax2014_X64\Presets\2015.1\export" types:"Data(*.fbxexportpreset)|*.fbxexportpreset"
			if get_ExportFBXPreset != undefined do (
				append j_exp.set_ExportFBXPreset get_ExportFBXPreset
				j_exp.exConfigFile = get_ExportFBXPreset
				ddlPreset.items = j_exp.set_ExportFBXPreset
				ddlPreset.tooltip = filenamefrompath (j_exp.exConfigFile as string)
				--exConfigFile=ddlPreset.items[itm]
			)
			/*
			if f!=undefined do
			(
				btn_ExConfigPath.text=f
				exConfigFile=btn_ExConfigPath.text
			)
			*/
		)
)
	j_exp = exportWindow.exp_test()
	createDialog exportWindow 370 315--135
	--AddSubRollout exportWindow.theSubrollout exportConfig


