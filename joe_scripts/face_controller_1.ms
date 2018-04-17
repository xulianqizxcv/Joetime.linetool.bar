/*macroScript AttachToVertices
category: "GregoryMaxScript"
buttonText:"AttachToVertices"
icon: #("SW_DynInt", 1)
tooltip: "Attact To Selected Vertices"
*/


--try DestroyDialog AttachToVertex catch()

rollout AttachToface "模型面驱动 v0.1"
(

	--local baseGeo
    global numSel_ver=#()
    global numSel_face =#()
    ------------------------------------------------

    ------------------------------------------------

    fn set_point_mesh_ver mesh  =  --传入mesh ,在选中的每个点上创建一个point
    (
        for i = 1 to numSel_ver.count do
        (
            p = point box:on wirecolor:red --生成 point
            p.position.controller = position_script()
            --p.pos.controller.script = ("dependsOn "+"$"+mesh.name+"\n"+"PolyOp.getVert "+"$"+mesh.name+" "+(arra_y[i] as string))
            p.pos.controller.script = ("dependsOn "+"$"+mesh.name+"\n"+"PolyOp.getVert "+"$"+mesh.name+" "+(numSel_ver[i] as string))
            --p.rotation.controller = rotation_script ()
            --p.rotation.controller.script = ("dependsOn "+"$"+mesh.name+"\n"+"matrixFromNormal "+"("+"polyOp.getFaceNormal "+"$"+mesh.name+" "+(numSel_ver[i] as string))+")"

        )
    )

     ------------------------------------------------

    fn create_mesh_point mesh  = --传入mesh 在选中的每个面上创建一个point
    (
        for o=1 to numSel_face.count do
        (
            s = point box:on cross:on wirecolor:red --geosphere()--create a default geosphere
            actrls = Attachment()--create an Attachment controller
            s.position.controller = actrls--assign to the position of the geosphere
            actrls.node = mesh--set the cylinder as the node to attach to
            addNewKey actrls 0f--add a key at frame 0
            theAKey = AttachCtrl.getKey actrls 1--get the first key
            --if classof mesh == Editable_Poly do
            --(
            theAKey.face = numSel_face[o] * 2 - 1  -- Attachment()认的面的序号是三角面序号
            theAkey.coord = [0.5,0]
            --)
            /*
            if classof mesh == Editable_mesh do
            (
                theAKey.face = numSel_face[o]
            )
            */
        )
    )
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
        contr =LookAt_Constraint()
        for_obj.rotation.controller = contr
        contr.appendTarget tar_obj 50
        contr.relative = true
        contr.viewline_Length_abs = off
        contr.lookat_vector_length = 0

        --contr.upnode_world = false
        --contr.pickUpnode = sele_up

        contr.target_axis =0 -- 0:X axis ;1: Y axis ; 2 : Z axis
        contr.StoUp_axis =1
        contr.upnode_axis =1


    )
    ------------------------------------------------
    fn create_lookat_upobj lookat_obj up_obj =
    (
        try (
            lookat_obj.rotation.controller.upnode_world = false
            lookat_obj.rotation.controller.pickUpnode = up_obj
            lookat_obj.rotation.controller.StoUp_axis =2
            lookat_obj.rotation.controller.upnode_axis =2
        )catch()
    )
    ------------------------------------------------

	button ATC "添加" width:120 height:30 tooltip:"选择面新建Point"
    button btn_lookat "注视约束" width:120 height:30 tooltip:"先选骨骼，后选目标Point"
    button btn_lookat_up "方向控制" width:120 height:30 tooltip:"自转方向控制，先选骨骼后选控制器Point"
    HyperLink lbl_01 "帮助"  width:24 height:15 align:#Center address:"https://4698to.github.io/Animation-time-line/?file=001-3ds%20Max/04-%E7%94%A8%E5%B8%83%E6%96%99%E9%A9%B1%E5%8A%A8%E9%AA%A8%E9%AA%BC"

    ------------------------------------------------
    on btn_lookat pressed do
    (
        if Selection.count == 2 do
        (
            if (classof Selection[1] == BoneGeometry) and (classof Selection[2] == Point) do
            (
                create_LookAt_Constraint Selection[1] Selection[2]
            )
        )
    )
    ------------------------------------------------
    on btn_lookat_up pressed do
    (
        if Selection.count == 2 do
        (
            if (classof Selection[1] == BoneGeometry) and (classof Selection[2] == Point) do
            (
                create_lookat_upobj Selection[1] Selection[2]
            )
        )
    )

    ------------------------------------------------

	------------------------------------------------
	on ATC pressed do
    (
	    undo on (
					if selection.count==1 then
                    (
										if classof selection[1] == Editable_Poly do--then
                                        (
                                            /*
											if subobjectLevel == 1 do--then 选中点模式
                                            (
												numSel_ver = PolyOp.getVertSelection $ as array -- 获取选中的点
												if numSel_ver.count>0 then
                                                (

                                                    set_point_mesh_ver $

												)
                                                else
                                                (
                                                    messagebox "Select Vertices!" beep:true title:"Vertex Selection"
                                                )
											)
                                            */
                                            if subobjectLevel == 4 do --选中面模式
                                            (
                                                numSel_face = polyop.getFaceSelection $ as array
                                                if numSel_face.count>0 then
                                                (
                                                     create_mesh_point $ --numSel_face
                                                )
                                                else
                                                (
                                                    messagebox "Select Polygon !" beep:true title:"Polygon Selection"
                                                )
                                            )
										)
                                        /*
										if classof $ == Editable_Mesh do--then
                                        (
											if baseGeo!=undefined do--then
                                            (
												nv = $.selectedVerts.count
												numSel = #()
												for i = 1 to nv do
                                                (
                                                    numSel[i] = $.selectedVerts[i].index
                                                )

												if numSel.count>0 then
                                                (

												)
                                                else
                                                (
                                                    messagebox "Select Vertices!" beep:true title:"Vertex Selection"
                                                )
											)
										)
                                        */

					)
                    else
                    (
                        messagebox "Select one object!" beep:false title:"Selection"
                    )
				)
	)
)

CreateDialog AttachToface
