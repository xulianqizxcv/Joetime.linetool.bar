
try (destroyDialog RTSRO )
	catch()

--20180803 by:Joe 增加手动和计算权重混和
--E-mail:738746223@qq.com
/*
--增加恢复界面的按钮
*/

--macroScript BoneSpring
--category:"BBTools"
--tooltip:"Bone Spring1.5"
--buttonText:"Bone Spring1.5"
--(
	--------------------BB
	Group_Spr =#()
	Group_Spr_N = #()
	Group_Spr_Upnode = #()
	TestIndex = 0
    my_weight = #()
    my_weight_ctrs = #()
    my_bone = #()
	--------------------BB
	mapped fn freezeTM obj mode:#{1..2} = --冻结变换
	(
			if mode[1] then
			(
				local lstCnt = position_List()
				obj.position.controller = lstCnt
				lstCnt[1].controller = position_xyz()
				lstCnt[2].controller = position_xyz()
				lstCnt.active = 2
				lstCnt.setName 1 "Frozen Position"
				lstCnt.setName 2 "Zero Position"
			)
			if mode[2] then
			(
				local lstCnt = rotation_List()
				obj.rotation.controller = lstCnt
				lstCnt[1].controller = euler_xyz()
				lstCnt[2].controller = euler_xyz()
				lstCnt.active = 2
				lstCnt.setName 1 "Frozen Rotation"
				lstCnt.setName 2 "Zero Rotation"
			)
			if mode[3] then
			(
				local lstCnt = scale_List()
				obj.scale.controller = lstCnt
				lstCnt[1].controller = bezier_scale()
				lstCnt[2].controller = bezier_scale()
				lstCnt.active = 2
				lstCnt.setName 1 "Frozen Scale"
				lstCnt.setName 2 "Zero Scale"
			)
			return true
	)
	fn makepoint mode pname pcolor psize father=
	(
		local tempoint
		case mode of
		(
					"axis": (tempoint=Point pos:[0,0,0] isSelected:off box:off cross:off axisTripod:on centerMarker:off;)
					"boxcrossaxis": (tempoint=Point pos:[0,0,0] isSelected:off box:on cross:on axisTripod:on centerMarker:off;)
					"cross":	(tempoint=Point pos:[0,0,0] isSelected:off box:off cross:on axisTripod:off centerMarker:off;)
					"marker":	(tempoint=Point pos:[0,0,0] isSelected:off box:off cross:off axisTripod:off centerMarker:on;)
					"markerbox":	(tempoint=Point pos:[0,0,0] isSelected:off box:on cross:off axisTripod:off centerMarker:on;)
					"box":	(tempoint=Point pos:[0,0,0] isSelected:off box:on cross:off axisTripod:off centerMarker:off;)
		)
		if tempoint!=undefined do
		(
				tempoint.name=pname
				tempoint.wirecolor=pcolor
				tempoint.size=psize
				if father!=undefined do tempoint.parent=father
		)
		return tempoint
	)

	RTSpringCA = attributes RTSpring
	(
		parameters main
		(
			seageoRTS	type:#integer default:1
			sf 			type:#float	default:0.5
			df 			type:#float default:0.1
			v 			type:#point3 default:[0,0,0]
			cValue		type:#point3 default:[0,0,0]
			oldTime 	type:#float default:0.0
			comment		type:#string default:"no Comment ..."
			enabled		type:#boolean default:true
		)
	)
	rollout RTSRO "Realtime Spring V1.5.3 by Harrison Yu" width:720 height:350
	(
		dotNetControl SpringList "System.Windows.Forms.ListView" pos:[8,66] width:704 height:200
		--ActiveXControl SpringList "MSComctlLib.ListViewCtrl" pos:[8,66] width:704 height:200
		button btnAddPos "Make" pos:[16,16] width:80 height:20
		edittext edtComment "" pos:[287,16] width:113 height:16
		spinner spnSprFac "" pos:[148,16] width:42 height:16 range:[0,10,4] scale:0.01 --Spring
		spinner spnDmpFac "" pos:[148,40] width:42 height:16 range:[0,1,0.1] scale:0.01
		spinner spnHelperSize "" pos:[48,40] width:48 height:16 range:[0.1,100,15] scale:0.1
		GroupBox grp1 "Make Spring At First Selected Node Position" pos:[8,0] width:400 height:64
		label lbl2 "Comment" pos:[239,16] width:48 height:16
		label lbl3 "Spring" pos:[101,16] width:40 height:16
		label lbl4 "Damping" pos:[101,40] width:48 height:16
		label lbl5 "Size" pos:[16,40] width:32 height:16
		checkbox chklink "link" pos:[196,17] width:40 height:16 checked:true
		checkbox chkBoneOnly "BoneOnly" pos:[196,40] width:65 height:16 checked:true tooltip:"只处理骨骼类型"
		button btnRescan "Rescan" pos:[624,40] width:88 height:20
		button btnMakeChain "*Build Chain" pos:[269,39] width:80 height:20
		checkbox chkDriver "Driv" pos:[359,40] width:40 height:16 checked:false
		button btnSelDrv "Select Driver" pos:[400,296] width:80 height:20
		button btnSelBone "Select Bone" pos:[488,296] width:64 height:20
		button btnSelSpr "Select Spring" pos:[400,272] width:80 height:20
		spinner spnIncV "" pos:[208,272] width:40 height:16 range:[0.01,1,0.1] scale:0.01
		button btnDecSpr "-" pos:[88,272] width:16 height:20
		button btnIncSpr "+" pos:[104,272] width:16 height:20
		button btnDecDmp "-" pos:[168,272] width:16 height:20
		button btnIncDmp "+" pos:[184,272] width:16 height:20
		label lbl65 "Spring" pos:[40,272] width:40 height:16
		label lbl66 "Damping" pos:[120,272] width:48 height:16
		spinner spnSprValue "" pos:[40,296] width:56 height:16 range:[0.01,10,0]
		spinner spnDmpValue "" pos:[120,296] width:56 height:16 range:[0.01,1,0] scale:0.1
		button btnOn "ON" pos:[8,272] width:24 height:20
		button btnOff "OFF" pos:[8,296] width:24 height:20
		button btnBakeAni "烘培动画" pos:[624,272] width:88 height:20
		button btnUseBaked "Use Baked" pos:[560,272] width:64 height:20
		button btnUseSpr "Use Spring" pos:[560,296] width:64 height:20
		edittext edtNewComment "Comment" pos:[184,296] width:208 height:16
		button btnselall "Select All" pos:[488,272] width:64 height:20
		edittext edtSelNode "" pos:[256,272] width:136 height:16 enabled:false
		button btnDelAni "Delete Animation" pos:[624,296] width:88 height:20
		checkbutton ckbForceUpd "Force Update" pos:[624,8] width:88 height:20
		Timer tmr25fps "Timer" pos:[256,40] width:24 height:24 interval:40 active:false
		spinner spnXTime "Bake speed:1/" pos:[75,328] width:40 height:16 range:[1,100,1] type:#integer scale:1 tooltip:"塌陷动画速度"
		spinner spnloop "Loops" pos:[155,328] width:40 height:16 range:[0,9,2] type:#integer scale:1
		spinner spnSubF "Subsample" pos:[250,328] width:40 height:16 range:[1,100,1] type:#integer scale:1
		hyperlink lbl_help "帮助" address:"https://github.com/4698to/Joetime.linetool.bar/tree/master/Realtime_Spring_V1.5" pos:[345,328]
		checkbox chk_000 "X-Up" pos:[300,328] tooltip:"改变Spr001_Upnode链接结构"
		GroupBox grp11 "" pos:[3,264] width:397 height:56
		button btnABake "Bake With Subsample Frame" pos:[485,328] width:155 height:16
		button btnACollapse "塌陷动画" pos:[642,328] width:70 height:16 		--BB
		dropdownList ddlComm "" pos:[424,24] width:128 height:22
		button btnfilter "Filter" pos:[560,24] width:48 height:20
		GroupBox grp9 "Filter List By Comment" pos:[416,0] width:200 height:64
		label lbl25 "ESC to exit" pos:[424,48] width:60 height:16
		button resetUI_btn "恢复界面" pos:[424,328] width:56 height:16




		local nodeTab=#()
		local lastselitem
		local commList=#()

		persistent global spr_group_nu = 0 --计数器

		fn getherComm comm=
		(
			local newcomm=true
			for c in commList do if comm==c then (newcomm=false;exit;)
			if newcomm then
			(
			append commList comm
			ddlComm.items=commList
			)
		)
		fn initListView lv =
		(

			--lv.backcolor = color 50 120 60
		--	lv.forecolor = color 255 255 255
			lv.BackColor = (dotnetclass "System.Drawing.Color").fromARGB 50 120 60
			lv.foreColor = (dotnetclass "System.Drawing.Color").fromARGB 255 255 255
			lv.gridLines = true

			lv.View = (dotNetClass "System.Windows.Forms.View").Details
			lv.MultiSelect =true
			lv.fullRowSelect = true
			lv.HideSelection = false
			--lv.sorted = false --true
			--lv.LabelEdit=  #lvwManual
			--lv.AllowColumnReorder =false
			--lv.Checkboxes = false --true
			--lv.HideSelection = false

				layout_def = #(#("-",28),#("Comment",60), #("Spring Node",120),#("Driver Node",120),#("Bone Upnode",150), #("Spring",50), #("Damp",50), #("Enabled",54),#("weight",54), #("Keys",50), #("Weight",50),#("Motion Parent",100),#("Value",160), #("Speed",160), #("-",32))
				for i in layout_def do
				lv.Columns.add i[1] i[2]

		)
		fn fillInSpreadSheet_RW lv = --刷新选择函数
		(
			try
			(
				for i = 0 to lv.items.count - 1 do
				(
					--try
					--(
						drv = lv.Items.item[i].SubItems.Item[3].Text
						drv = execute( "$" +"'"+ drv+"'")
						if drv.isselected == true then lv.Items.item[i].Selected = true
						else lv.Items.item[i].Selected = false
					--)
					--catch(print "因骨骼名中有(mirrored)字符，所以此功能无法使用")
				)
			)
			catch()
		)

		fn fillInSpreadSheet lv cleanselected filter:false=
		(
				--------------------BB
				Group_Spr =#()
				Group_Spr_N = #()

				--------------------BB
				if filter==false  then (ddlComm.items=#();commList=#())
				lv.Items.Clear()
			 	--lv.ListItems.clear()
				nodeTab =#()
				lastselitem=undefined
				edtSelNode.text=""
				edtNewComment.text=""
				spnSprValue.value=0
				spnDmpValue.value=0
				theRange = #()
				local index=1
				for o in objects do
				(
					if classof  o.controller ==  prs do--then --would cause problem on max8
					(
							if classof o.position.controller==position_list do
							(
								local con=o.position.controller[1].controller
								if (isProperty  con "seageoRTS")  do
								(
									if filter and con.comment!=ddlComm.selected then
									(
									--do nothing
									)
									else
									(
										if filter==false do
										(
											getherComm con.comment
										)
										append nodeTab o
										li = dotNetObject "System.Windows.Forms.ListViewItem"  (index as string)
										--备注
										sub_li = li.SubItems.add (con.comment as string	)
										sub_li = li.SubItems.add (o.name as string)
										--蓝色虚拟体
										local drvnode=con.GetNode "DrvNode"
										sub_li = li.SubItems.add (drvnode.name as string)
										--红色虚拟体
										local bonenode=con.GetNode "BoneNode"
										local BoneUpnode = con.GetNode "UpNode" --Sky
										sub_li = li.SubItems.add (BoneUpnode.name as string)
										sub_li = li.SubItems.add (con.sf as string)
										sub_li = li.SubItems.add (con.df as string)
										sub_li = li.SubItems.add (con.enabled as string)
										sub_li = li.SubItems.add (o.position.controller.weight[1] as string)
										sub_li = li.SubItems.add (o.position.controller[3].controller.keys.count as string)
										sub_li = li.SubItems.add (o.position.controller.weight[3] as string)
										local parName=""
										if  drvnode.parent!=undefined do
										(
											parName=drvnode.parent.name
										)
										sub_li = li.SubItems.add (parName)
										sub_li = li.SubItems.add (con.cValue as string)
										sub_li = li.SubItems.add (con.v as string)
										if cleanselected do--then
										(
											li.selected=false
										)
										index+=1
										if (findItem (selection as array) drvnode > 0) do--then
										(
											li.Selected = true
										)
										append theRange li
									)--end check filter

								)--end if
								if drvnode != undefined do (append Group_Spr drvnode)
								if o != undefined do (append Group_Spr_N o)
								if BoneUpnode != undefined do (append Group_Spr_Upnode BoneUpnode)
							)--end if 	position_list
					)

				)--end for o
					------------------BB
					/*
					if Group_Spr[1] !=undefined do
					(
						selectionSets["Group_Spr"] = Group_Spr
					)
					if Group_Spr_N[1] !=undefined do
					(
						selectionSets["Group_Spr_N"] = Group_Spr_N
						hide Group_Spr_N
					)
					--print Group_Spr_Upnode

					if Group_Spr_Upnode[1] !=undefined do
					(
						selectionSets["Group_Spr_Upnode"] = Group_Spr_Upnode
						hide Group_Spr_Upnode
					)
					*/
			        ------------------BB
			        ---------------------------------------------------- 2018-3-6 选择集区分
			    if Group_Spr[1] !=undefined do
			    (
			        selectionSets["Group_Spr_"+(spr_group_nu as string)] = Group_Spr
			    )
			    if Group_Spr_N[1] !=undefined do
			    (
			        selectionSets["Group_Spr_N_"+(spr_group_nu as string)] = Group_Spr_N
			        hide Group_Spr_N
			    )
			        --print Group_Spr_Upnode
			    if Group_Spr_Upnode[1] !=undefined do
			    (
			        selectionSets["Group_Spr_Upnode_"+(spr_group_nu as string)] = Group_Spr_Upnode
			        hide Group_Spr_Upnode
			    )
			    ----------------------------------------------------
				lv.Items.AddRange theRange
				spr_group_nu += 1
			)--end fn fillInSpreadSheet

		fn getFirstSelected =
		(
			if selection.count<=0 then return undefined
			else return selection[1]
		)
		          --控制手柄 ;弹簧计算point ; Z轴侧向控制手柄 ；骨骼对象
		fn makeSpring drvnode springnode Up_node bonenode enabled:true =  --wb --Sky 添加 UP_node 参数输入
		(
				springnode.transform = drvnode.transform
				freezeTM springnode mode:#{1,2} --冻结变换位移旋转

				springnode.position.controller[3].controller= Position_XYZ()
				springnode.position.controller.weight[3]=0

				local newScriptController = position_script ()
				springnode.position.controller[1].controller = newScriptController
				custAttributes.add springnode.position.controller[1].controller RTSpringCA
				newScriptController.AddNode "DrvNode" drvnode
				newScriptController.AddNode "BoneNode" bonenode	 --wb
				newScriptController.AddNode "UpNode" Up_node	      --Sky

				newScriptController.cValue.controller = bezier_point3 ()

				newScriptController.cValue.controller.keyable = false
				newScriptController.v.controller = bezier_point3 ()
				newScriptController.v.controller.keyable = false

				newScriptController.cValue = drvnode.pos

				newScriptController.oldTime.controller=bezier_float ()
				newScriptController.oldTime.controller.keyable=false
				newScriptController.oldTime = timestamp()/320 as float --添加创建控制时的系统时间
				newScriptController.sf = spnSprFac.value --弹力
				newScriptController.df = spnDmpFac.value * spnSprFac.value --阻力damp值不要超过spring值
				newScriptController.enabled = enabled
				newScriptController.comment = edtComment.text
				local	sscript="animate off(\n"
						sscript+="if this.enabled then (\n"
						sscript+="this.v=-this.v*this.df+(DrvNode.pos-this.cValue)*this.sf\n"
						sscript+="if abs(this.cValue.x)>=10000 do\n"
						sscript+="(\nthis.v=[0,0,0]\n"
						sscript+="this.cValue=[0,0,0]\n)\n"
						sscript+="cTime=timestamp()/320 as float\n"
						sscript+="diff=cTime-this.oldTime\n"
						sscript+="this.oldTime=cTime\n"
						sscript+="if diff>0.1 do diff=0.1\n"
						--sscript+="if diff>0.1 then diff=0.1\n"
						sscript+="if diff<0 then this.cValue\n"
						sscript+="else this.cValue+=this.v*diff\n"
						sscript+=")else(DrvNode.pos))"
				newScriptController.script = sscript
					/*
					print sscript
					animate off
					(
						if this.enabled then
						(
							this.v =- this.v * this.df + (DrvNode.pos-this.cValue) * this.sf
							if abs(this.cValue.x) >= 10000 do  --then --一个运动距离限制，
							(
								this.v = [0,0,0]
								this.cValue =[0,0,0]
							)

							cTime = (timestamp()/320) as float --当前时间
							diff = cTime - this.oldTime --上一帧和当前帧时间
							this.oldTime = cTime -- 更新时间

							--if diff > 0.1 then (diff = 0.1)

							if diff > 0.1 do (diff = 0.1)
							if diff < 0 then ( this.cValue ) --- 不知道他怎么想的，diff是不可能小于零的，
							else
							(
								this.cValue += this.v * diff
							)
						)else
						(
							DrvNode.pos
						)
					)
					*/

		)
		fn QuickLookAtUpAxis target Up taxis saxis uaxis =
		(
			local mycontroller
					mycontroller=LookAt_Constraint()
					if	target!=undefined then	mycontroller.appendTarget target 50
					mycontroller.viewline_Length_abs = off
					mycontroller.lookat_vector_length = 0
					if Up!=undefined then
					(
					mycontroller.upnode_world = off
					mycontroller.pickUpnode = Up
					)
					mycontroller.target_axis =taxis
					mycontroller.StoUp_axis =saxis
					mycontroller.upnode_axis =uaxis
					--mycontroller.relative = true		--WB
			return mycontroller
		)
		fn menus_bake =
		(
			max create mode
			boneArr=#()
			sprArr=#()
			drvArr=#()
			dataArr=#()
			upnodeArr = #() --Sky

			struct animData
			(
				time,obj,rota
			)
			/* AX
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local bonenode = nodeTab[idx].position.controller[1].controller.GetNode "BoneNode"
				--append UpnodeArr bonenode
				if (findItem boneArr bonenode) == 0 then append boneArr bonenode
				append sprArr nodeTab[idx]
				local drvnode = nodeTab[idx].position.controller[1].controller.GetNode "DrvNode"
				append drvArr drvnode
				local upnode  = nodeTab[idx].position.controller[1].controller.GetNode "UpNode" --Sky
				append upnodeArr upnode
			)
			*/
			for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected then
			(
				local bonenode = nodeTab[i + 1].position.controller[1].controller.GetNode "BoneNode"
				--append UpnodeArr bonenode
				if (findItem boneArr bonenode) == 0 do append boneArr bonenode
				append sprArr nodeTab[i + 1]
				local drvnode = nodeTab[i + 1].position.controller[1].controller.GetNode "DrvNode"
				append drvArr drvnode
				local upnode  = nodeTab[i + 1].position.controller[1].controller.GetNode "UpNode" --Sky
				append upnodeArr upnode
				)

			for t = animationRange.start to animationRange.end do
			(
				for Bobj in boneArr do
				(
					tempData =  animData()
					tempData.time = t
					tempData.obj = Bobj
					at time t tempData.rota = Bobj.transform
					append dataArr tempData
				)
			)
			select sprArr
			max delete
			delete drvArr
			delete UpnodeArr --Sky

			--for tempbone in boneArr do tempbone.rotation.controller = Euler_XYZ () --Sky

			/*
			for tempbone in boneArr do
			(
				tempbone.rotation.controller = Euler_XYZ ()
				tempParent = tempbone.parent
				tempbone.parent =tempParent.parent
				delete tempParent

			)
			*/ --Sky
			--with animate on
			animate on
			(
				for d in dataArr do
				(
					--d.obj.pos.controller = Position_Expression()
					--d.obj.scale.controller = Scale_Expression ()

					d.obj.pos.controller = position_xyz()
					--d.obj.rotation.controller = Euler_XYZ ()
					d.obj.rotation.controller = tcb_rotation ()
					d.obj.scale.controller = bezier_scale ()
					at time d.time d.obj.transform=d.rota
					deletekeys d.obj.pos.controller.keys #allKeys
					deletekeys d.obj.scale.controller.keys #allKeys

					)
				)
			Group_Spr =#()
			Group_Spr_N = #()
			Group_Spr_Upnode = #()	--Sky
			fillInSpreadSheet SpringList  true
		)
		------------------------------------------------------------------------------
		fn c_lineShape n = --控制手柄实体
		(
			c = 1.2
			new_spline =splineShape ()
			new_spline.pos = [0,0,0]
			addNewSpline new_spline

			addKnot new_spline 1 #corner #curve [-(n*c),-n,0]
			addKnot new_spline 1 #corner #curve [(-n*c),n,0]
			addKnot new_spline 1 #corner #curve [(n*c),n,0]
			addKnot new_spline 1 #corner #curve [(n*c),-(n),0]
			addKnot new_spline 1 #corner #curve [-(n*c),-n,0]

			close new_spline 1
			updateshape new_spline
			return new_spline
		)
		fn c_bone_to_ctrs N = --手动控制器匹配到骨骼
		(
			animate on
			(
				for NC in N.children do
				(
					if NC != undefined do
					(
						ctr = execute ("$"+"'"+"weight_ctr" + N.name +"'")
						if ctr !=undefined do
						(
							ctr.transform = N.transform
						)
						c_bone_to_ctrs NC
					)
				)
			)
		)
		fn c_children N = --复制骨骼链接的Point链
		(
			animate off
			(
				NP = N.parent
				--n_point= Circle radius:10--point()
				n_point = c_lineShape 5
				n_point.name = ("weight_ctr" + N.name)
				n_point.transform = N.transform
				n_point.rotation.controller = tcb_rotation ()
				append my_weight_ctrs n_point
				for NC in N.children do
				(
					if NC !=undefined do
					(
						weight_point = c_lineShape 5
						--weight_point = Circle radius:10--point size:5 axistripod:true
						--weight_point.name = uniqueName ("weight_ctr" + N.name )
						weight_point.name =("weight_ctr" + NC.name )
						weight_point.transform = NC.transform
						weight_point.rotation.controller = tcb_rotation ()

						--NP_p = execute ("$"+"'"+"weight_ctr" + NP.name +"'")
						NP_y = execute ("$"+"'"+"weight_ctr" + N.name +"'")
						if NP_y != undefined do (weight_point.parent = NP_y) --else weight_point.parent = NP_y

						append my_weight_ctrs weight_point
						c_children NC
					)
				)
			)
		)
		fn c_delete =
		(
			if my_weight_ctrs.count != 0 do
			(
					ff = my_weight_ctrs.count
					for i=1 to ff do
					(
						try
						(
							if (my_weight_ctrs[i].children.count == 0) and (my_weight_ctrs[i].parent ==undefined )do
							(
								delete my_weight_ctrs[i]
								deleteItem my_weight_ctrs i
								--bb[i].name ="dele_" +bb[i].name
							)
						)catch()
					)
			)
			append my_weight my_weight_ctrs
		)

		fn c_parent n_bone = --创建链接组
	    (	/*
	        if a_array.count != 0 do
	        (
	            for i=1 to a_array.count do
	            (
	                try (a_array[i+1].parent = a_array[i])catch()
	            )
	        )
	        */
	       	one = execute ("$"+"'"+"weight_ctr" + n_bone.name +"'")
	       	if one != undefined do (one.parent = n_bone.parent)
	    )
		fn c_rotation_weight b_bone = --滑块权重控制面板
		(
			weight_default_ctr = b_bone
			def = attributes weight_attrib --参数面板
        	(
	            parameters weight_Par rollout:weight_roll
	            (
	                weightTrack type:#float UI:OnOffSpinner
	            )
	            rollout weight_roll "混合开关v0.1"
	            (
	                --spinner myMultSpinner "*强度:" Range:[0,20,10] tooltip:"建议值为 10 "
	                --spinner my_drag "阻力:" range:[0,10,1] type:#float
	                group "混合权重" (
	                	slider OnOffSpinner "*计算/手动"  range:[0,100,0] type:#float--#integer
	                	label lab_01 "00"
	                )
	                group "" (
	                	button btn_pose "*匹配到骨骼" tooltip:"手动控制器匹配到骨骼"
	                )
	                --hyperlink bt_info "更新" address:"https://github.com/4698to/Joetime.linetool.bar/tree/master/Dynamics_Spring" align:#Center
	                --local lbltext = #("On", "Off")
	                on weight_roll open do
	                (
	                	lab_01.text = OnOffSpinner.value as string
	                )
	                on OnOffSpinner changed val do
	                (
	                	lab_01.text = val as string
	                )
	                on btn_pose pressed do
	                (
	                	c_bone_to_ctrs $
	                )
	            )
        	)
        	--碰到骨骼上原来就有Attribute_Holder 修改器的情况
        	if weight_default_ctr.modifiers[#Attribute_Holder] != undefined then
        	(
        		for i=1 to (custAttributes.count weight_default_ctr.modifiers[#Attribute_Holder]) do
        		(
        			try(
                    if (custAttributes.get weight_default_ctr.modifiers[#Attribute_Holder] i).name =="weight_attrib" do
                    	(
                        custAttributes.delete weight_default_ctr.modifiers[#Attribute_Holder] i
                    	)
                	)catch()
        		)
        		--deleteModifier weight_default_ctr 1 --这个语句不保险,可能会删错
        		custAttributes.add weight_default_ctr.modifiers[#Attribute_Holder] def
        	)
        	else
        	(
        		hide_m = emptyModifier()
        		addModifier weight_default_ctr hide_m
        		custAttributes.add hide_m def
        	    --append my_weight weight_default_ctr
        	)
		)
		fn c_bone_weight N_bone = --创建滑块权重控制
		(
			weigth_track = N_bone.modifiers[#Attribute_Holder].weight_attrib[#weightTrack]
			if (my_weight_ctrs.count !=0 )and (my_bone.count !=0 )do
			(
				for i=1 to (my_bone.count) do
				(
					tem = execute ("$"+"'"+"weight_ctr" +(my_bone[i].children[1].name)+"'")
					if tem != undefined do
					(
						my_bone[i].rotation.controller.appendTarget tem 0
						my_bone[i].rotation.controller.setWeight 1 100

						a_weight = my_bone[i].rotation.controller[1].controller = Float_Expression()
						b_weight = my_bone[i].rotation.controller[2].controller = Float_Expression()

						a_weight.addscalartarget "of_weight" weigth_track
						a_weight.setexpression "100 - of_weight "

						b_weight.addscalartarget "of_weight" weigth_track
						b_weight.setexpression "of_weight "
					)
				)
			)
		)

		fn dele_weight_ctr = --塌陷动画时清理
		(
			--delete my_weight
			--my_weight_ctrs = #()

		)
		-----------------------------------------------------------------------------
		fn makeChain_fn  N  =
		(
			animate off
			(
				NP = N.parent
				for NC in N.children do
				(
					if chkBoneOnly.checked do --只处理骨骼类型
					(
						if classof NC != BoneGeometry do continue
						print ("Skip "+ NC.name)
					)
					if NC !=undefined then
					(
						--weight_point = point size:5
						--weight_point.name = uniqueName ("weight_ctr" + NC.name )
						--weight_point.transform = NC.transform
						--append my_weight_ctrs weight_point

						append my_bone N

						local pointname = uniqueName (N.name+"_Spr")
						local pointsize = spnHelperSize.value
						local springParent = NP

						local drvpoint = makepoint "markerbox" pointname blue pointsize springParent--控制手柄

						local newpoint = makepoint "cross" (pointname+"N") green (pointsize+8) undefined -- 主要弹簧计算对象
						newpoint.isHidden = true

						MP = execute ("$"+"'"+"weight_ctr" + N.name +"'")
						if (chk_000.checked )and( MP != undefined) then
						(
							local temppoint = makepoint "box" (pointname+"_Upnode") red (pointsize-5) MP
						)
						else
						(
							local temppoint = makepoint "box" (pointname+"_Upnode") red (pointsize-5) NP  -- z 轴侧向旋转控制器
						)
						temppoint.transform = N.transform
						temppoint.isHidden = true
						/*
						--if (classof N.rotation.controller) != LookAt_Constraint then
						--(
							local temppoint= makepoint "box" (pointname+"_Upnode") red (pointsize-5) NP

							temppoint.transform = N.transform
							temppoint.isHidden = true
							--N.parent = temppoint --Sky 解除LookAT控制器 Upnode与bone的连接关系
						--)
						--*/ --Sky

						drvpoint.transform = NC.transform
						makeSpring drvpoint newpoint temppoint N enabled:false --turn off first fix for max8	--Sky 添加 temppoint 参数输入
						--append sprnode newpoint --fix for max8
						--N.rotation.controller= Euler_XYZ ()
						if (classof N.rotation.controller) == LookAt_Constraint then
						(
						)
						--else N.rotation.controller= QuickLookAtUpAxis newpoint N.parent 0 1 1
						else
						(
							N.rotation.controller= QuickLookAtUpAxis newpoint temppoint 0 1 1 --Sky 将LookAT控制器的Upnode指向临时点 而不是父物体
						)
						newpoint.position.controller[1].enabled=true
						makeChain_fn NC

					)
				)
			)
		)


		fn updateRoll =
		(
			fillInSpreadSheet_RW SpringList
			--print "UpDataRoll OK!!!!"
		)
		on RTSRO open do
		(
			initListView SpringList
			fillInSpreadSheet SpringList  true
			registerRedrawViewsCallback updateRoll
		)
		on RTSRO close do
		(
			unRegisterRedrawViewsCallback updateRoll
		)
		/* ActiveX控件
		on SpringList ItemClick Item do
		(
			lastselitem=Item
			idx=item.text as integer
			local con=nodeTab[idx].position.controller[1].controller
			edtSelNode.text=nodeTab[idx].name
			edtNewComment.text=item.listSubItems[1].text
			spnSprValue.value=con.sf
			spnDmpValue.value=con.df
			clearselection()
			tempNode = #()
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local drvnode=nodeTab[idx].position.controller[1].controller.GetNode "DrvNode"
				append tempNode drvnode
			)
			select tempNode
		)
		*/
		-- dotNet 控件测试
		--on SpringList ItemSelectionChanged do
		--on SpringList Click do



/*
			on SpringList DragEnter item do
		(
			print "aa"
			showProperties item

			--SpringList.Items.item[TestIndex].selected = true
		print ("StartTestIndex =  "+ TestIndex as string)

			)
		on SpringList DragOver do
		(
					print ("StopTestIndex =  "+ TestIndex as string)
			)
		on SpringList ItemDrag item do --鼠标拖动选择
		(
			--print item.
			showProperties  item
			StartIndex = TestIndex
			print ("StartIndex =  "+ StartIndex as string)

			for i = StartIndex to TestIndex do SpringList.Items.item[i].selected = true
			print ("StartTestIndex =  "+ TestIndex as string)
			)


		--on SpringList Click do

		on SpringList MouseMove Item do
		(
			showProperties item.Empty
			print item.clicks
			--TestIndex = item.index
			print ("StartIndex =  "+ TestIndex as string)
			)


		on SpringList ItemMouseHover item do
		(
			--showProperties item.Location

			--print item.Location.y

			--TestIndex = item.item.Index
			--print SpringList.MouseButtons.value__
			--showProperties SpringList.MouseButtons.Left
			if SpringList.MouseButtons.value__ == 1048576 do
			(
				Item.item.Selected = true
				)
			)
			*/
		--改为 dotNet控件
		on SpringList Click do
		(
			try
			(
				idx=SpringList.SelectedIndices.item[0] as integer + 1
				local con=nodeTab[idx].position.controller[1].controller
				edtSelNode.text=nodeTab[idx].name
				edtNewComment.text = SpringList.Items.item[1].SubItems.Item[1].Text
				spnSprValue.value=con.sf
				spnDmpValue.value=con.df
			)
			catch()
			clearselection()
			tempNode = #()
			for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
			(
				--showProperties SpringList.Items.item[i]
				--print SpringList.Items.item[i].text
				--print  SpringList.Items.item[1].SubItems.Item[3].Text
				--ShowProperties SpringList.Items.item[1].SubItems
				idx = SpringList.Items.item[i].Index + 1
				local drvnode=nodeTab[idx].position.controller[1].controller.GetNode "DrvNode"
				append tempNode drvnode
			)
		   	select tempNode
		)

		on SpringList MouseEnter do -- 解决按Shift多选时 控件窗口选择范围出错的问题
		(
			unRegisterRedrawViewsCallback updateRoll
		)
		on SpringList MouseLeave do
		(
			RegisterRedrawViewsCallback updateRoll
		)


		on btnAddPos pressed do
		(
			local selnode= getFirstSelected ()
			if selnode!=undefined do
			(
				local pointname=uniqueName (selnode.name+"_Spr")
				local pointsize=spnHelperSize.value
				local springParent=undefined
				if chklink.checked then springParent=selnode
				local drvpoint= makepoint "markerbox" pointname blue pointsize springParent
				local newpoint= makepoint "cross" (pointname+"N") green pointsize undefined
				local temppoint= makepoint "box" (pointname+"_Upnode") red (pointsize-5) NP --Sky
				drvpoint.transform=selnode.transform
				makeSpring drvpoint newpoint temppoint selnode --Sky 添加 temppoint 参数输入
				fillInSpreadSheet SpringList  true
			)
		)
		on btnRescan pressed do
		(
			fillInSpreadSheet SpringList true
		)
		on btnMakeChain pressed do
		(
			with undo label: "make chain" on
			(
				--my_weight = #()

				max create mode
				tempArr = selection as array
				for i in tempArr do
				(
					my_weight_ctrs = #();my_bone=#()

					c_children i;c_delete() --创建等样链手柄
				 	makeChain_fn i

				 	c_rotation_weight i --创建手柄权重控制属性面板

					c_bone_weight i --链接控制属性
					c_parent i --将手动控制器链接上去
				)
				fillInSpreadSheet SpringList  true


			)
		)
		on btnSelDrv pressed do
		(
			/* AX
			clearselection()
			for item in SpringList.listItems do if item.selected then (
				idx=item.text as integer
				local drvnode=nodeTab[idx].position.controller[1].controller.GetNode "DrvNode"
				selectmore drvnode
			)*/
			/*-- 20160225 改为从骨骼选中结算器
			animate off
			(
				clearselection()
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					idx =  SpringList.Items.item[i].text as integer
					local drvnode=nodeTab[idx].position.controller[1].controller.GetNode "DrvNode"
					selectmore drvnode
					)
				)
			*/
			animate off
			(
				BoneSelction = selection as array
				clearselection()
				for o in BoneSelction do
				(
					for i = 0 to SpringList.items.count - 1 do
					(
						idx =  SpringList.Items.item[i].text as integer
						if o == nodeTab[idx].position.controller[1].controller.GetNode "BoneNode" do
						(
							local drvnode=nodeTab[idx].position.controller[1].controller.GetNode "DrvNode"
							selectmore drvnode
						)
					)
				)
			)
		)
		on btnSelBone pressed do
		(--
			/* AX
			clearselection()
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local bonenode = nodeTab[idx].position.controller[1].controller.GetNode "BoneNode"
				selectmore bonenode
			)*/
			animate off
			(
				clearselection()
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					idx =  SpringList.Items.item[i].text as integer
					local bonenode = nodeTab[idx].position.controller[1].controller.GetNode "BoneNode"
					selectmore bonenode
				)
			)
		)
		on btnSelSpr pressed do
		(
			/* AX
			clearselection()
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				selectmore nodeTab[idx]
			)*/
			animate off
			(
				clearselection()
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					idx =  SpringList.Items.item[i].text as integer
					selectmore nodeTab[i+1]
				)
			)
		)
		on btnDecSpr pressed do
		(
			/* AX
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local con=nodeTab[idx].position.controller[1].controller
				con.sf-=spnIncV.value
				item.listSubItems[4].text=con.sf as string
			)*/
			animate off
			(
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					local con=nodeTab[i+1].position.controller[1].controller
					con.sf -= spnIncV.value
					SpringList.Items.item[i].SubItems.Item[5].Text =con.sf as string
				)
			)
		)
		on btnIncSpr pressed do
		(
			/* AX
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local con=nodeTab[idx].position.controller[1].controller
				con.sf+=spnIncV.value
				item.listSubItems[4].text=con.sf as string
			)*/
			animate off
			(
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					local con=nodeTab[i+1].position.controller[1].controller
					con.sf += spnIncV.value
					SpringList.Items.item[i].SubItems.Item[5].Text =con.sf as string
				)
			)
		)
		on btnDecDmp pressed do
		(
			/* AX
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local con=nodeTab[idx].position.controller[1].controller
				con.df-=spnIncV.value
				item.listSubItems[5].text=con.df as string
			)*/
			animate off
			(
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					local con=nodeTab[i+1].position.controller[1].controller
					con.df -= spnIncV.value
					SpringList.Items.item[i].SubItems.Item[6].Text =con.df as string
				)
			)
		)
		on btnIncDmp pressed do
		(
			/* AX
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local con=nodeTab[idx].position.controller[1].controller
				con.df+=spnIncV.value
				item.listSubItems[5].text=con.df as string
			)*/
			animate off
			(
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					local con=nodeTab[i+1].position.controller[1].controller
					con.df += spnIncV.value
					SpringList.Items.item[i].SubItems.Item[6].Text =con.df as string
				)
			)
		)
		on spnSprValue changed val do
		(
			/* AX
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local con=nodeTab[idx].position.controller[1].controller
				con.sf=val
				item.listSubItems[5].text=val as string
			)*/
			animate off
			(
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					local con=nodeTab[i+1].position.controller[1].controller
					con.sf=val
					SpringList.Items.item[i].SubItems.Item[5].Text=val as string
				)
			)

		)
		on spnDmpValue changed val do
		(
			/* AX
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local con=nodeTab[idx].position.controller[1].controller
				con.df=val
				item.listSubItems[6].text=val as string
			)*/
			animate off
			(
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					local con=nodeTab[i+1].position.controller[1].controller
					con.df=val
					SpringList.Items.item[i].SubItems.Item[6].Text=val as string
				)
			)
		)
		on btnOn pressed do
		(
			/* AX控件
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local drvnode=nodeTab[idx].position.controller[1].controller.GetNode "DrvNode"

				local con=nodeTab[idx].position.controller[1].controller
				con.enabled=true
				item.listSubItems[7].text=con.enabled as string
			)
			*/
			animate off
			(
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					local drvnode = nodeTab[i+1].position.controller[1].controller.GetNode "DrvNode"
					local con=nodeTab[I+1].position.controller[1].controller
					con.enabled=true
					--item.listSubItems[7].text=con.enabled as string
					SpringList.Items.item[i].SubItems.Item[7].Text = con.enabled as string
					)
			)
		)
		on btnOff pressed do
		(
			/* AX控件
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local con=nodeTab[idx].position.controller[1].controller
				con.enabled=false
				item.listSubItems[7].text=con.enabled as string
			)*/
			animate off
			(
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					local drvnode = nodeTab[i+1].position.controller[1].controller.GetNode "DrvNode"
					local con=nodeTab[I+1].position.controller[1].controller
					con.enabled=false
					SpringList.Items.item[i].SubItems.Item[7].Text = con.enabled as string
				)
			)
		)
		on btnBakeAni pressed do --塌陷动画
		(
			animate off
			(
				timeSlider.setVisible false
				disableSceneRedraw();
				actionMan.executeAction 0 "407"

				--local fps=4800.0/ticksPerFrame
				local tps=1000.0/frameRate
				local diff=tps/320.0
				--设置初始位置
				/* AX
				for item in SpringList.listItems do if item.selected do
				(
					idx=item.text as integer
					local obj=nodeTab[idx]
					local con=nodeTab[idx].position.controller[1].controller
					local anicon=nodeTab[idx].position.controller[3].controller
					obj.position.controller.weight[1]=0
					obj.position.controller.weight[3]=100
					anicon.value=con.value
				    --con.v=[0,0,0]
					con.cValue=anicon.value
				)
				*/
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					local obj=nodeTab[i + 1]
					local con=nodeTab[i + 1].position.controller[1].controller
					local anicon=nodeTab[i + 1].position.controller[3].controller
					obj.position.controller.weight[1]=0
					obj.position.controller.weight[3]=100
					anicon.value=con.value
					con.cValue=anicon.value
				)

				for loop=1 to spnloop.value do --空运行，寻找稳定状态
				(
					for currFrame = animationRange.start to animationRange.end do
					(
						if keyboard.escPressed then exit
						for l=1 to spnXTime.value do --多计算几次
						/* AX
						for item in SpringList.listItems do if item.selected then
						(
							idx=item.text as integer
							local obj=nodeTab[idx]
							local con=nodeTab[idx].position.controller[1].controller
							local anicon=nodeTab[idx].position.controller[3].controller
							slidertime=currFrame
							DrvNode=con.GetNode "DrvNode"
							con.v=-con.v*con.df+(DrvNode.pos-con.cValue)*con.sf
							if abs(con.cValue.x)>=10000 then
							(
								con.v=[0,0,0]
								con.cValue=[0,0,0]
								)
							con.cValue+=con.v*diff
							anicon.value=con.cValue --不记录
						)
						*/
						for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
						(
							local obj=nodeTab[i + 1]
							local con=nodeTab[i + 1].position.controller[1].controller
							local anicon=nodeTab[i + 1].position.controller[3].controller
							slidertime = currFrame
							DrvNode = con.GetNode "DrvNode"
							con.v =- con.v*con.df+(DrvNode.pos-con.cValue)*con.sf
							if abs(con.cValue.x)>=10000 then
							(
								con.v=[0,0,0]
								con.cValue=[0,0,0]
							)
							con.cValue+=con.v*diff
							anicon.value=con.cValue --不记录
						)

					)
				)
				for currFrame=animationRange.start to animationRange.end do
				(
					if keyboard.escPressed then exit
					for l=1 to spnXTime.value do --多计算几次
					/* AX
					for item in SpringList.listItems do if item.selected then (
						idx=item.text as integer
						local obj=nodeTab[idx]
						local con=nodeTab[idx].position.controller[1].controller
						local anicon=nodeTab[idx].position.controller[3].controller
						slidertime=currFrame
							DrvNode=con.GetNode "DrvNode"
							con.v=-con.v*con.df+(DrvNode.pos-con.cValue)*con.sf
							if abs(con.cValue.x)>=10000 then
							(
							con.v=[0,0,0]
							con.cValue=[0,0,0]
							)
							con.cValue+=con.v*diff
						with animate on (
							anicon.value=con.cValue

						)
					*/
					for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
					(
						local obj=nodeTab[i + 1]
						local con=nodeTab[i + 1].position.controller[1].controller
						local anicon=nodeTab[i + 1].position.controller[3].controller
						slidertime=currFrame
						DrvNode=con.GetNode "DrvNode"
						con.v=-con.v*con.df+(DrvNode.pos-con.cValue)*con.sf
						if abs(con.cValue.x)>=10000 then
						(
							con.v=[0,0,0]
							con.cValue=[0,0,0]
							)
							con.cValue+=con.v*diff
						with animate on
						(
							anicon.value=con.cValue

						)
					)
				)
				timeSlider.setVisible true
				enableSceneRedraw()
				completeRedraw()
				actionMan.executeAction 0 "407"

				fillInSpreadSheet SpringList  false
			)
		)
		on btnUseBaked pressed do
		(
		/* AX
			for item in SpringList.listItems do if item.selected then (
				idx=item.text as integer
				local con=nodeTab[idx].position.controller[1].controller
				local obj=nodeTab[idx]
				local listcon=obj.position.controller
				listcon.weight[1]=0
				listcon.weight[3]=100
				item.listSubItems[8].text=listcon.weight[1] as string
				item.listSubItems[10].text=listcon.weight[3] as string
			)
			*/
			animate off
			(
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					idx =  SpringList.Items.item[i].text as integer
					local con=nodeTab[idx].position.controller[1].controller
					local obj=nodeTab[idx]
					local listcon=obj.position.controller
					listcon.weight[1]=0
					listcon.weight[3]=100
					SpringList.Items.item[i].SubItems.Item[8].Text = listcon.weight[1] as string
					SpringList.Items.item[i].SubItems.Item[10].Text = listcon.weight[3] as string
					)
				)
			)
		on btnUseSpr pressed do
		(
			/* AX
			for item in SpringList.listItems do if item.selected then (
				idx=item.text as integer
				local con=nodeTab[idx].position.controller[1].controller
				local obj=nodeTab[idx]
				local listcon=obj.position.controller
				listcon.weight[1]=100
				listcon.weight[3]=0
				item.listSubItems[8].text=listcon.weight[1] as string
				item.listSubItems[10].text=listcon.weight[3] as string
				)*/
			animate off
			(
				for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
				(
					idx =  SpringList.Items.item[i].text as integer
					local con=nodeTab[idx].position.controller[1].controller
					local obj=nodeTab[idx]
					local listcon=obj.position.controller
					listcon.weight[1]=100
					listcon.weight[3]=0
					SpringList.Items.item[i].SubItems.Item[8].Text = listcon.weight[1] as string
					SpringList.Items.item[i].SubItems.Item[10].Text = listcon.weight[3] as string
					)
				)
			)
		on edtNewComment entered text do
		(
			if	lastselitem!=undefined then
			(
				idx=lastselitem.text as integer
				local con=nodeTab[idx].position.controller[1].controller
				con.Comment=text
				lastselitem.listSubItems[1].text=text
			)
		)
		on btnselall pressed do
		(
			/* ActiveX控件
			for item in SpringList.listItems do item.selected=true
			clearselection()
				tempNode = #()
				for item in SpringList.listItems do if item.selected then
				(
				idx=item.text as integer
				local drvnode=nodeTab[idx].position.controller[1].controller.GetNode "DrvNode"
				append tempNode drvnode
				)
				select tempNode
			*/
			SpringList.selectedItems.Clear()
			clearselection()
			tempNode = #()
			for i = 0 to SpringList.items.count - 1 do
			(
				--try
				--(
					SpringList.Items.item[i].selected = true
					drv = SpringList.Items.item[i].SubItems.Item[3].Text
					drv = execute( "$" +"'"+ drv+"'")
					--drv.isselected == true
					append tempNode drv
				--)catch(print "因骨骼名中有(mirrored)字符，所以此功能无法使用")
			)
			select tempNode



		)
		on btnDelAni pressed do
		(
			/* AX
			for item in SpringList.listItems do if item.selected then (
				idx=item.text as integer
				local obj=nodeTab[idx]
			    local con=nodeTab[idx].position.controller[1].controller
				local anicon=nodeTab[idx].position.controller[3].controller
				deleteKeys anicon #allKeys
			)
			*/
			for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
			(
				local obj=nodeTab[i + 1]
				local anicon=nodeTab[i + 1].position.controller[3].controller
				deleteKeys anicon #allKeys
			)
			fillInSpreadSheet SpringList  true
		)
		on ckbForceUpd changed state do
		(
			tmr25fps.active=state
		)
		on tmr25fps tick do
		(
			for o in nodeTab do o.pos.controller[1].Update()
		)
		on btnABake pressed do
		(
			local tps=1000.0/frameRate
			local diff=tps/320.0
			/* AX
			for item in SpringList.listItems do if item.selected then
			(
				idx=item.text as integer
				local obj=nodeTab[idx]
				local con=nodeTab[idx].position.controller[1].controller
				local anicon=nodeTab[idx].position.controller[3].controller
				obj.position.controller.weight[1]=0
				obj.position.controller.weight[3]=100
				anicon.value=con.value
				con.cValue=anicon.value
			)
			*/
			for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
			(
				local obj=nodeTab[i + 1]
				local con=nodeTab[i + 1].position.controller[1].controller
				local anicon=nodeTab[i + 1].position.controller[3].controller
				obj.position.controller.weight[1]=0
				obj.position.controller.weight[3]=100
				anicon.value=con.value
				con.cValue=anicon.value
			)
			for loop=1 to spnloop.value do --空运行，寻找稳定状态
			(
				for currFrame=animationRange.start to animationRange.end do
				(
						if keyboard.escPressed then exit
					for l=1 to spnXTime.value do --多计算几次
					(
					/* AX
					for item in SpringList.listItems do if item.selected then (
						idx=item.text as integer
						local obj=nodeTab[idx]
						local con=nodeTab[idx].position.controller[1].controller
						local anicon=nodeTab[idx].position.controller[3].controller
						slidertime=currFrame
							DrvNode=con.GetNode "DrvNode"
							con.v=-con.v*con.df+(DrvNode.pos-con.cValue)*con.sf
							if abs(con.cValue.x)>=10000 then
							(
							con.v=[0,0,0]
							con.cValue=[0,0,0]
							)
							con.cValue+=con.v*diff
							anicon.value=con.cValue --不记录
						)
						*/
						for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
						(
							local obj=nodeTab[i + 1]
							local con=nodeTab[i + 1].position.controller[1].controller
							local anicon=nodeTab[i + 1].position.controller[3].controller
							slidertime=currFrame
							DrvNode=con.GetNode "DrvNode"
							con.v=-con.v*con.df+(DrvNode.pos-con.cValue)*con.sf
							if abs(con.cValue.x)>=10000 then
							(
								con.v=[0,0,0]
								con.cValue=[0,0,0]
								)
							con.cValue+=con.v*diff
							anicon.value=con.cValue --不记录
							)

						)
					)
				)
			local subframe=1/spnSubF.value as time
			local diff=diff/spnSubF.value as float
			for currFrame=animationRange.start to animationRange.end do
			(
				if keyboard.escPressed then exit
				/* ax
				for l=1 to spnXTime.value do --多计算几次
				for sl=0 to (spnSubF.value-1) do --subframe
				for item in SpringList.listItems do if item.selected then (
					idx=item.text as integer
					local obj=nodeTab[idx]
					local con=nodeTab[idx].position.controller[1].controller
					local anicon=nodeTab[idx].position.controller[3].controller
					slidertime=currFrame
						DrvNode=con.GetNode "DrvNode"
						DrvNodepos=at time (currFrame+subframe*sl as time) DrvNode.pos
						con.v=-con.v*con.df+(DrvNodepos-con.cValue)*con.sf
						if abs(con.cValue.x)>=10000 then
						(
						con.v=[0,0,0]
						con.cValue=[0,0,0]
						)
						con.cValue+=con.v*diff
					with animate on (	anicon.value=con.cValue		)
				)
				*/
				for l=1 to spnXTime.value do --多计算几次
				(
					for sl=0 to (spnSubF.value-1) do --subframe
					(
						for i = 0 to SpringList.items.count - 1 do if SpringList.Items.item[i].selected do
						(
						local obj=nodeTab[i + 1]
						local con=nodeTab[i + 1].position.controller[1].controller
						local anicon=nodeTab[i + 1].position.controller[3].controller
						slidertime=currFrame
						DrvNode=con.GetNode "DrvNode"
						DrvNodepos=at time (currFrame+subframe*sl as time) DrvNode.pos
						con.v=-con.v*con.df+(DrvNodepos-con.cValue)*con.sf
						if abs(con.cValue.x)>=10000 then
						(
							con.v=[0,0,0]
							con.cValue=[0,0,0]
							)
						con.cValue+=con.v*diff
						with animate on
							(
								anicon.value=con.cValue
								)
							)
						)
				)
			)
			fillInSpreadSheet SpringList  false
		)
		on btnACollapse pressed do
		(
			undo on
			(
				menus_Bake()
				--dele_weight_ctr()--my_weight_ctrs = #() --应该是不可撤销的
			)
		)--BB
		on btnfilter pressed do
		(
			fillInSpreadSheet SpringList  true filter:true
		)
		on resetUI_btn pressed do
		(
			timeSlider.setVisible true
			enableSceneRedraw();
			actionMan.executeAction 0 "407"
		)




	)

	--20150429 BUG 当动画记录开启的时候 改变参数会被动画记录下来










	createdialog RTSRO

--)
