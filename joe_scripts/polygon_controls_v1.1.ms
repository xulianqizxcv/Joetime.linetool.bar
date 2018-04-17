
--try DestroyDialog AttachToVertex catch()

rollout AttachToface "模型面驱动 v0.1.1"
(

	--local baseGeo
    global numSel_ver=#() --Editable_Poly 点
    global numSel_face =#()  --Editable_Poly 面
    global numSel_mesh_ver =#() --Editable_Mesh  点
    --global numSel_mesh_face =#() --Editable_Mesh  面
    global at_f
    struct att_face
    (
        ------------------------------------------------
        /*
        fn get_mesh_ver mesh num = --传入mesh 和 一个整数，获取到这个整数个 的vertex
        (
            local mesh_ver = PolyOp.getVertSelection mesh
            --mesh_ver.count / num
            numsel = #()
            local a=1
            for i=1 to num do
            (
                a +=(mesh_ver.count / num)
                append numsel a
            )
            return numsel
        )
        */
       fn bake_anim_sele_bone bake_obj =
        (
            struct tem_anim (
                time,trans_form--,obj
            )
            tem_anim_datas =#()
            for t = animationRange.start to animationRange.end do
            (
                tem_data = tem_anim()
                tem_data.time = t
                --tem_data.obj = bake_obj
                at time t
                (
                    tem_data.trans_form = bake_obj.transform
                )
                append tem_anim_datas tem_data
            )

            bake_obj.pos.controller = Position_XYZ()
            bake_obj.rotation.controller = tcb_rotation ()
            bake_obj.scale.controller = bezier_scale ()

            animate on
            (
                for i in tem_anim_datas do
                (
                    at time i.time
                    (
                        bake_obj.transform = i.trans_form
                    )
                )
            )
            deletekeys bake_obj.scale.controller.keys #allKeys

        ),
        ------------------------------------------------
        fn create_bones obj_1 obj_2 = --创建骨骼 根据传入的两对象的 位置创建骨骼
        (
            newbone = boneSys.createBone obj_1.pos obj_2.pos [0,0,1]
            newbone.frontfin = true
            newbone.frontfinsize = 5
            newbone.realignBoneToChild()
            newbone.resetBoneStretch()
            if obj_1.parent != undefined and classOf obj_1 == BoneGeometry do
            (
                newbone.parent = obj_1.parent
                if AttachToface.ch_bone_del.state do
                (
                    delete obj_1 ---!!!!!!!!!
                )
            )
            --at_f.create_LookAt_Constraint newbone obj_2

            endbone_1pos = [newbone.length,0,0] * newbone.objectTransform
            endbone = boneSys.createBone endbone_1pos (endbone_1pos+6) newbone.dir
            endbone.frontfin = true
            endbone.frontfinsize = 5
            endbone.rotation=newbone.rotation
            endbone.pos=newbone.transform.translation
            in coordSys Local move endbone [newbone.length,0,0]
            endbone.taper=90
            endbone.parent = newbone
            endbone.length=(newbone.width+newbone.height)/2
            endbone.wirecolor=newbone.wirecolor
            endbone.realignBoneToChild()
            endbone.resetBoneStretch()
            --clearSelection()
        ),

        ------------------------------------------------

        fn set_point_mesh_ver mesh  =  --传入Editable_Poly ,在选中的每个点上创建一个point
        (
            for i = 1 to numSel_ver.count do
            (
                p = point box:false centermarker:false cross:true wirecolor:red size:AttachToface.spn_size.value --生成 point
                p.name = uniquename("Marker_" +mesh.name+"_Point")
                --p.ishidden = true
                at_f.create_sets_group p ("Marker_"+mesh.name)
                p.position.controller = position_script()
                --p.pos.controller.script = ("dependsOn "+"$"+mesh.name+"\n"+"PolyOp.getVert "+"$"+mesh.name+" "+(arra_y[i] as string))
                p.pos.controller.script = ("dependsOn "+"$"+mesh.name+"\n"+"PolyOp.getVert "+"$"+mesh.name+" "+(numSel_ver[i] as string))
                --p.rotation.controller = rotation_script ()
                --p.rotation.controller.script = ("dependsOn "+"$"+mesh.name+"\n"+"matrixFromNormal "+"("+"polyOp.getFaceNormal "+"$"+mesh.name+" "+(numSel_ver[i] as string))+")"
                --p.rotation.controller.script = ("dependsOn "+"$"+mesh.name+"\n"+"getNormal "+"$"+mesh.name+" "+(arra_y[i] as string))

            )
        ),
        ------------------------------------------------

        fn create_mesh_ver_point mesh =  --Editable_Mesh  点
        (
            for i = 1 to numSel_mesh_ver.count do
            (
                p = point box:false centermarker:false cross:true wirecolor:red size:AttachToface.spn_size.value  --生成 point
                p.name = uniquename("Marker_" +mesh.name+"_Point")
                --p.ishidden = true
                p.position.controller = position_script()
                p.pos.controller.script = ("dependsOn "+"$"+mesh.name+"\n"+"MeshOp.getVert "+"$"+mesh.name+" "+(numSel_mesh_ver[i] as string))

                at_f.create_sets_group p ("Marker_"+mesh.name)
            )

        ),
        ------------------------------------------------
        fn create_sets_group group_imt group_name =  --group_name :Face_Point  |传入对象 和选择集名字
        (
            if selectionSets[(group_name)] != undefined then
            (
                local d_group = #()
                append d_group group_imt
                for i in selectionSets[group_name] do
                (
                    append d_group i
                )
                selectionSets[(group_name)] = d_group
            )
            else
            (
                selectionSets[(group_name)] = group_imt

            )
        ),
        ------------------------------------------------
        --red green blue white black orange yellow brown gray
        fn create_mesh_point mesh  = --传入Editable_Poly 在选中的每个面上创建一个point
        (
            for o=1 to numSel_face.count do
            (
                s = point box:false cross:true centermarker:false wirecolor:red size:AttachToface.spn_size.value
                s.name = uniquename("Marker_" +mesh.name+"_Point")
                --point_d_c = copy s --point box:true centermarker:true cross:false wirecolor:green size:AttachToface.spn_size.value
                --s.ishidden = true
                actrls = Attachment()--create an Attachment controller
                s.position.controller = actrls--assign to the position of the geosphere
                actrls.node = mesh--set the cylinder as the node to attach to
                addNewKey actrls 0f--add a key at frame 0
                theAKey = AttachCtrl.getKey actrls 1--get the first key
                if classof mesh == Editable_Poly do
                (
                    theAKey.face = numSel_face[o] * 2 - 1  -- Attachment()认的面的序号是三角面序号
                    theAkey.coord = [0.5,0]
                )

                if classof mesh == Editable_mesh do
                (
                    theAKey.face = (numSel_face[o])-1
                    theAkey.coord = [0.33,0.33]
                )
                at_f.create_sets_group s ("Marker_" +mesh.name)
            )
        ),
        ------------------------------------------------
        fn create_LookAt_Constraint for_obj tar_obj =
        (
            /*
            sele_up = point name:(for_obj.name+"_t_up")
            sele_up.transform = for_obj.transform
            if for_obj.parent != undefined do
            (
                sele_up.parent = for_obj.parent
            )
            */
            new_p = point()
            --new_p.parent = for_obj
            new_p.box = true
            new_p.centermarker = true
            new_p.cross = false
            new_p.wirecolor = green
            new_p.size = AttachToface.spn_size.value

            new_p.transform = for_obj.transform
            new_p.name = for_obj.name + "_UseCtr"

            at_f.create_sets_group new_p ("UseCtr")

            new_tar = copy new_p
            new_tar.name = for_obj.name +"_UpCtr"
            new_tar.wirecolor = blue
            new_tar.size = new_p.size /2

            at_f.create_sets_group new_tar ("Up_Ctr")
            if for_obj.parent != undefined do (new_tar.parent = for_obj.parent)

            in coordSys Local move new_p [selection[1].length,0,0]
            new_p.parent = tar_obj
            contr =LookAt_Constraint()
            for_obj.rotation.controller = contr
            --contr.appendTarget tar_obj 50
            contr.appendTarget new_p 50
            contr.relative = true
            contr.viewline_Length_abs = off
            contr.lookat_vector_length = 0

            contr.upnode_world = false
            contr.pickUpnode = new_tar

            contr.target_axis =0 -- 0:X axis ;1: Y axis ; 2 : Z axis
            contr.StoUp_axis =1
            contr.upnode_axis =1


        )
        ------------------------------------------------
        /*
        fn create_lookat_upobj lookat_obj up_obj =
        (
            try (
                lookat_obj.rotation.controller.upnode_world = false
                lookat_obj.rotation.controller.pickUpnode = up_obj
                lookat_obj.rotation.controller.StoUp_axis =2
                lookat_obj.rotation.controller.upnode_axis =2
            )catch()
        )
        */
    )
    ------------------------------------------------

	--button ATC "添加" width:120 height:30 tooltip:"选择面新建Point"
    --button btn_lookat "注视约束" width:120 height:30 tooltip:"先选骨骼，后选目标Point"
    --button btn_lookat_up "方向控制" width:120 height:30 tooltip:"自转方向控制，先选骨骼后选控制器Point"
	--button Help "帮助" tooltip:"Help" width:120 height:30
    spinner spn_size "" pos:[16,40] width:48 height:16 range:[0,100,10]
    label size "Size:" pos:[18,24] width:40 height:16

    button ATC "添加" pos:[72,27] width:73 height:30 toolTip:"选择面或点新建Point"
    button btn_lookat "注视约束" pos:[17,100] width:128 height:60 toolTip:"先选骨骼，后选目标Point"
    --button btn_lookat_up "方向控制" pos:[81,100] width:64 height:60 toolTip:"自转方向控制，先选骨骼后选控制器Point"
    --button help "How To Use :)" pos:[24,240] width:120 height:30 toolTip:"Help"
    hyperlink lbl_help "帮助" address:"https://github.com/4698to/Joetime.linetool.bar/tree/master/polygon_controls" pos:[70,240]
    groupBox grp1 "Point" pos:[6,7] width:151 height:66
    --groupBox grp2 "约束" pos:[7,72] width:0 height:0


    groupBox grp3 "约束" pos:[6,79] width:151 height:89
    --button btn5 "2" pos:[17,135] width:56 height:25 toolTip:"LookAt Constraint"
    groupBox grp5 "骨骼" pos:[6,176] width:151 height:56
    button btn_bone "创建骨骼" pos:[18,194] width:56 height:25 toolTip:""
    button btn_bake "Bake" pos:[101,194] width:45 height:25 toolTip:"塌陷选中骨骼动画"
    checkbox ch_bone_del "" pos:[78,200] checked:false toolTip:"清除尾骨"

    --label lab_01 "清尾骨" pos:[101,200]

    ------------------------------------------------
    on btn_bake pressed do
    (
        if selection.count > 0 do
        (
            for i in selection do
            (
                if (classof Selection[1] == BoneGeometry or (classof Selection[1] == Bone ) or (classof Selection[1] == Point)) do
                (
                    at_f.bake_anim_sele_bone i
                )
            )
        )
    )
    ------------------------------------------------
    on btn_bone pressed do
    (
        if Selection.count == 2 do
        (
            at_f.create_bones Selection[1] Selection[2]
        )
    )
    ------------------------------------------------
    on btn_lookat pressed do
    (
        if Selection.count == 2 do
        (
            if (classof Selection[1] == BoneGeometry or (classof Selection[1] == Bone )) and (classof Selection[2] == Point) do
            (
                try (at_f.create_LookAt_Constraint Selection[1] Selection[2])catch()
            )
        )
    )
    ------------------------------------------------
    /*
    on btn_lookat_up pressed do
    (
        if Selection.count == 2 do
        (
            if (classof Selection[1] == BoneGeometry or (classof Selection[1] == Bone )) and (classof Selection[2] == Point) do
            (
                try (at_f.create_lookat_upobj Selection[1] Selection[2]) catch()
            )
        )
    )
    */
    ------------------------------------------------

	------------------------------------------------
	       on ATC pressed do
            (
	            undo on
                (
					if selection.count==1 then
                    (
										if classof selection[1] == Editable_Poly do--then
                                        (

											if subobjectLevel == 1 do--then 选中点层级
                                            (
												numSel_ver = PolyOp.getVertSelection $ as array -- 获取选中的点
												if numSel_ver.count>0 then
                                                (

                                                    at_f.set_point_mesh_ver $

												)
                                                else
                                                (
                                                    messagebox "Select Vertices!" beep:true title:"Vertex Selection"
                                                )
											)

                                            if subobjectLevel == 4 do --选中面层级
                                            (
                                                numSel_face = polyop.getFaceSelection $ as array
                                                if numSel_face.count>0 then
                                                (
                                                    at_f.create_mesh_point $ --numSel_face
                                                )
                                                else
                                                (
                                                    messagebox "Select Polygon !" beep:true title:"Polygon Selection"
                                                )
                                            )
										)

										if classof $ == Editable_Mesh do--then
                                        (
											if subobjectLevel == 1 do--then --选择点层级
                                            (
												local nv = $.selectedVerts.count
												numSel_mesh_ver = #()
												for i = 1 to nv do
                                                (
                                                    numSel_mesh_ver[i] = $.selectedVerts[i].index
                                                )

												if numSel_mesh_ver.count>0 then
                                                (
                                                    at_f.create_mesh_ver_point $
												)
                                                else
                                                (
                                                    messagebox "Select Vertices!" beep:true title:"Vertex Selection"
                                                )
											)
                                            if subobjectLevel == 3 do
                                            (
                                                local nf = $.selectedFaces.count
                                                numSel_face=#()
                                                for i=1 to nf do
                                                (
                                                    numSel_face[i] = $.selectedFaces[i].index
                                                )

                                                if numSel_face.count > 0 do
                                                (
                                                    at_f.create_mesh_point $
                                                )
                                            )
                                            if subobjectLevel == 4 do
                                            (
                                                messageBox "选择三角面 \n\r" beep:true title:"Selection"
                                            )
										)


					)
                    else
                    (
                        messagebox "Select one object!" beep:false title:"Selection"
                    )
				)
	       )
    ------------------------------------------------
)
at_f = AttachToface.att_face()
CreateDialog AttachToface
