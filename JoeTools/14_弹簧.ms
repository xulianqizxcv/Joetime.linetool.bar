--20180731 by Joe
--E-mail:738746223@qq.com
--99U:199505
rollout dynamics_spring_UI "动力学弹簧v0.1.1"
(
    global my_bone =#() --骨骼链
    global my_bone_ik =#() --骨骼代理
    global my_ctrs =#() -- 控制手柄
    global my_ikchain = #() --Iksys
    global my_spring = #() --弹簧控制器
    --global my_swivel_angle = #()
    group "" (
        label lab_01 "选中添加弹簧骨骼" --
        button btn_01 "添加选中骨骼" width:100 height:24 across:2 offset:[38,0]
        label lab_02 "" offset:[25,0]
    )

    group "" (
        button btn_02 "添加弹簧控制" width:100 height:24
        --设置弹簧阻力button btn_03 "3"
    )

    group "" (
        label lab_03 " * 参数可动画"
        hyperlink bt_info "更新" address:"https://github.com/4698to/Joetime.linetool.bar/tree/master/Dynamics_Spring" align:#Center
        -- Group body.
    )

    fn c_ik_ctr = --创建骨骼控制代理
    (
        my_bone_ik = #()
        my_ctrs=#()
        for i=1 to my_bone.count do
        (
            i_k = point size:5
            i_k.transform = my_bone[i].transform
            i_k.name = "ik"+my_bone[i].name
            i_k.isHidden = true
            append my_bone_ik i_k

            my_ctr = Circle radius:10
            my_ctr.transform = my_bone[i].transform
            my_ctr.name = "ctr"+ my_bone[i].name
            append my_ctrs my_ctr
        )
    )

    fn c_ikchain = --创建IK
    (
        if my_bone_ik.count != 0 do
        (
            my_ikchain=#()
            for i=1 to my_bone_ik.count do
            (
                try
                (
                    startjoint = my_bone_ik[i]
                    endjoint = my_bone_ik[i+1]
                    ikchain = iksys.ikchain startjoint endjoint "IKHiSolver"
                    --ikchain.transform.controller.goalSize = 5
                    --ikchain.name = "IKSys_"+ (i as string)
                    ikchain.name = uniquename("IKSys_")
                    ikchain.isHidden = true
                    append my_ikchain ikchain
                )catch()
            )
            --骨骼链第一节特殊处理
            ik_a = point size:5
            ik_a.isHidden = true
            ik_a.name = uniquename("IKSys_0_")
            ik_a.transform = my_bone[1].transform
            insertItem ik_a my_ikchain 1
        )
    )
    fn c_parent a_array = --创建链接组
    (
        if a_array.count != 0 do
        (
            for i=1 to a_array.count do
            (
                try (a_array[i+1].parent = a_array[i])catch()
            )
        )
    )
    fn c_root = --链接到上级
    (
        if my_bone[1].parent !=undefined do
        (
            try
            (
                my_ctrs[1].parent = my_bone[1].parent
                my_ikchain[1].parent = my_bone[1].parent
                my_bone_ik[1].parent = my_bone[1].parent
            )catch()
        )
    )

    fn c_IK_target = --设置IK target 控制IK旋转,只设置第2个IK 第1节骨骼
    (
        local IK_target = point name:("IK_target"+(my_bone[1].name))
        local ca_che = my_bone[1].transform[4] + [20,0,0]
        IK_target.transform = (matrix3 my_bone[1].transform[1] my_bone[1].transform[2] my_bone[1].transform[3] (ca_che))
        IK_target.parent = my_ctrs[1]

        my_ikchain[2].transform.controller.VHTarget = IK_target
        my_ikchain[2].transform.controller.useVHTarget = true

    )

    fn c_IK_sw_traget = --从二节骨骼开始，
    (
        for i=3 to my_ikchain.count do --IK 从第三个开始处理。
        (
            --并联到手柄,从第二个开始
            swivel_ang = my_ctrs[(i - 1)].modifiers[#Attribute_Holder].DynAttrib_sw.sw_angtrack.controller = bezier_Float()
            my_ikchain[i].transform.controller[#Swivel_Angle].controller = Float_Expression()
            my_ikchain[i].transform.controller[#Swivel_Angle].controller.addscalartarget  "s_angle" swivel_ang
            my_ikchain[i].transform.controller[#Swivel_Angle].controller.setexpression "s_angle"
        )
    )
    fn c_myctr_iksys = --把IK名字写到第一个控制手柄属性中保存
    (
        for i in my_ikchain do
        (
            append  my_ctrs[1].modifiers[#Attribute_Holder].spring_count (i.name )
        )
    )
    fn c_orientation = --创建骨骼方向约束
    (
        global dragVal = my_ctrs[1] --参数控制器
        global OnOffVal = dragVal.modifiers[#Attribute_Holder].DynAttrib[#OnOffTrack]
        global MultiVal = my_ctrs[1].modifiers[#Attribute_Holder].DynAttrib.multiTrack.controller = bezier_Float()

        for i=1 to my_bone.count do
        (
            bone_pos_controller = position_Constraint relative:True--create controller
            bone_rot_controller = orientation_Constraint relative:True--create controller

            my_bone[i].position.controller = bone_pos_controller
            my_bone[i].rotation.controller = bone_rot_controller

            bone_pos_controller.appendTarget my_ctrs[i] 100
            bone_pos_controller.appendTarget   my_bone_ik[i] 0

            bone_rot_controller.appendTarget   my_ctrs[i] 100
            bone_rot_controller.appendTarget   my_bone_ik[i] 0


            --my_bone[1].position.controller[1].controller = Float_Expression())
            --并联设置位移旋转控制器权重
            bone_pos_w1 = (bone_pos_controller[1].controller = Float_Expression())
            bone_pos_w2 = (bone_pos_controller[2].controller = Float_Expression())

            bone_rot_w1 = (bone_rot_controller[1].controller = Float_Expression())
            bone_rot_w2 = (bone_rot_controller[2].controller = Float_Expression())

            bone_pos_w1.addscalartarget  "OnOff" OnOffVal
            bone_pos_w1.setexpression  "100 - OnOff" --"100 - OnOff*100"

            bone_pos_w2.addscalartarget  "OnOff" OnOffVal
            bone_pos_w2.setexpression  "OnOff"


            bone_rot_w1.addscalartarget  "OnOff" OnOffVal
            bone_rot_w1.setexpression  "100 - OnOff" --"100 - OnOff*100"

            bone_rot_w2.addscalartarget  "OnOff" OnOffVal
            bone_rot_w2.setexpression  "OnOff"


        )

    )

    fn c_spring =--创建弹簧
    (
        my_spring =#()
        for i=1 to my_ikchain.count do
        (
            orientation_ctr = Orientation_Constraint relative:True
            --if i != 1 do -- 第一节假IK不建弹簧
            if i > 1 then
            (
                spring_ctr = SpringPositionController()
                my_ikchain[i].controller[2][1].controller = spring_ctr
                append my_spring spring_ctr
            )
            --orientation_ctr = Orientation_Constraint relative:True
            --if i == 1 do
            else
            (
                my_ikchain[1].rotation.controller = orientation_ctr
                orientation_ctr.appendTarget my_ctrs[1] 100
                continue
            )
            my_ikchain[i].controller[2][2].controller = orientation_ctr
            --try (my_ikchain[i].controller[2][2].controller = orientation_ctr)catch(my_ikchain[i].rotation.controller = orientation_ctr)
            orientation_ctr.appendTarget my_ctrs[i] 100
            --try (orientation_ctr.appendTarget my_ctrs[i] 100)catch()
        )
    )

    fn set_spring = --设置弹簧参数
    (
        for o=1 to my_spring.count do
        (
            --#X_effect; #Y_effect ;#Z_effect
            for p=2 to 4 do
            (
                my_spring[o][p].controller = Float_Expression()
                my_spring[o][p].controller.addscalartarget  "val" MultiVal
                my_spring[o][p].controller.setexpression  "val*10"
            )
            --IKX = (my_spring[o][#X_effect].controller = Float_Expression())
            --IKY = (my_spring[o][#Y_effect].controller = Float_Expression())
            --IKZ = (my_spring[o][#Z_effect].controller = Float_Expression())

        )
    )
    fn c_sw_attrib = --在控制手柄上设置  骨骼Z 轴，IK SWivel Angle
    (

        def_sw = attributes DynAttrib_sw
        (   parameters dyn_sw_par rollout:dynroll_sw_ang
            (
                sw_angtrack type:#float UI:my_swang
            )
            rollout dynroll_sw_ang "IK旋转"--IK SWivel Angle
            (
                 spinner my_swang "*Z：" type:#float range:[-360,360,0]
            )
        )
        for i =2 to (my_ctrs.count - 1) do --第一控制手柄特需处理
        (
            hide_mod = emptyModifier()
            addModifier my_ctrs[i] hide_mod
            custAttributes.add hide_mod def_sw
        )
        --custAttributes.add my_ctrs[1] def_sw

    )
    fn c_DynAttrib = --添加参数面板
    (
        default_ctr = my_ctrs[1]
        hide_mod = emptyModifier()
        def=attributes DynAttrib --参数面板
        (
            parameters dynPar rollout:dynRoll
            (
                multiTrack type:#float UI:myMultSpinner
                OnOffTrack type:#float UI:myOnOffSpinner
                spring_count type:#stringTab  tabSizeVariable:true tabsize:0
            )
            rollout dynRoll "动力学弹簧v0.1"
            (
                spinner myMultSpinner "*强度:" Range:[0,20,10] tooltip:"建议值为 10 "
                spinner my_drag "阻力:" range:[0,10,1] type:#float
                slider myOnOffSpinner "*Off/On"  range:[0,100,0] type:#float--#integer
                --label abl_002 "by:Joe"
                --label abl_003 ""
                hyperlink bt_info "更新" address:"https://github.com/4698to/Joetime.linetool.bar/tree/master/Dynamics_Spring" align:#Center
                local lbltext = #("On", "Off")
                on dynRoll open do
                (
                    -------------设置弹簧阻力
					ik_sys = $.modifiers[#Attribute_Holder].spring_count
                    a_ik = execute ("$"+"'" + ik_sys[2]+"'")
                    s_str = a_ik[3].controller[2][1].controller.getDrag()
                    my_drag.value = s_str
                    ---------------
                )
                on my_drag changed val do
                (
                    -------------设置弹簧阻力
                    ik_sys = $.modifiers[#Attribute_Holder].spring_count
                    for i=2 to ik_sys.count do
                    (
                        a_ik = execute ("$"+"'" + ik_sys[i]+"'")
                        a_ik[3].controller[2][1].controller.setDrag val
                    )
                )
            )
        )
        addModifier default_ctr hide_mod
        custAttributes.add hide_mod def
    )

    on btn_02 pressed do
    (
        if my_bone.count != 0 do
        (
            set animate off --先关闭自动动画
            animButtonState = false

            c_ik_ctr();
            c_DynAttrib();
            c_parent my_bone_ik;

            dynamics_spring_UI.c_parent my_ctrs;

            c_ikchain();
            c_IK_target();
            c_sw_attrib();
            c_IK_sw_traget();

            c_orientation();
            dynamics_spring_UI.c_parent my_ikchain;
            c_root();
            c_spring();
            set_spring();
            c_myctr_iksys();
            my_bone = #();lab_02.text = ""
        )
    )
    on btn_01 pressed do
    (
        my_bone = #()
        for i in selection do
        (
            append my_bone i
        )
       -- my_bone.count
       lab_02.text =  (my_bone.count as string )+"根"
    )

)

createDialog dynamics_spring_UI 200 195