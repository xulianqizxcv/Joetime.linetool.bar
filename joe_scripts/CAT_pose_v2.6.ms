rollout CAT_pose_tool "CAT-Posture.v1.4" width:216 height:216  --360 --155--400
(
    global C_A_T =""
    local sele_pose_num = 1 -- 选择的pose
    local list_num = #() --CAT_pose.down_list.items
    local  p3 = undefined
    local do_num = 0  --pose量，每按copy 一次 加一，每按 X 删除一个减 一
    local sele_name = #()  --选择集名字
    local pos_ft = false --是否黏贴位移
    local cat_par = #() --收集场景里的CATParent
    local cat_par_name = #() -- CATparent name  down_list_cat_char.items
    local avt_layer = 1 --当前cat 选中的层
    local IKFK = #()  -- 复制四肢poses时的 IKFK
    local num_IK_pos = #() --num Ik bones
    local from_transf = #() --pose数据
    local b_transform = undefined
    local copy_form = undefined
struct CT (
    ver =1.0,
    flipTm=scaleMatrix [1,1,-1],
    mirrorTm=scaleMatrix [1,1,-1],
    CopyPasteAniIni_name = (getdir #userScripts) + "\\joe_scripts\\"+ "CAT-Posture_Anim" + ".ini",
    Poses_Folder = (substituteString (getdir #plugcfg) @"\en-US\plugcfg" @"\plugcfg_ln\CAT\Poses\"),
    Pose_File = (substituteString (getdir #plugcfg) @"\en-US\plugcfg" @"\plugcfg_ln\CAT\Poses\" + "StorePose.pse"),
    retargeting = #(),
--)
-------------------------------------------------------------------------
    fn pick_cat_par =
    (
        for h in helpers where classOf h == CATParent do
        (
            append cat_par h
            append cat_par_name h.name

            cat_par_name = makeUniqueArray cat_par_name
            cat_par = makeUniqueArray cat_par
            CAT_pose_tool.down_list_cat_char.items = cat_par_name
            --CAT_pose.down_list_cat_char.selection
        )

    ),
    fn ck_p3 =
    (
        if p3 ==undefined do (
            p3 = point()
            p3.transform = (matrix3 [0,1.62921e-007,1] [1.50996e-007,-1,1.62921e-007] [1,1.50996e-007,0] [0,0,0])
            return true
        )
    ),

    fn ck_sele =
    (
        for i=1 to selection.count do (
            if selectionSets[do_num as string][i] == selection[i] do(

            )

        )
    ),

    fn up_num =
    (
        CAT_pose_tool.down_list.items = list_num

        sele_pose_num = CAT_pose_tool.down_list.selection
        CAT_pose_tool.lab_from_num.text = from_transf.count as string
    )
)---struct CT 结束


    fn ck_limb_l_r =
    (
        --try(
            if selection[1][3][1].name == "LimbData" then (
               if selection[1][3].limb.bones[1].limb.LMR == 1 do(
                   ikvalue = CAT_pose_tool.get_IKFk_value selection[1] 2
                    num_IKvalue = CAT_pose_tool.get_IKFk_value selection[1] 3
                    append IKFK ikvalue
                    append num_IK_pos num_IKvalue

                    return "R_"
                )

               if selection[1][3].limb.bones[1].limb.LMR == -1 do(
                    ikvalue = CAT_pose_tool.get_IKFk_value selection[1] 2
                    num_IKvalue = CAT_pose_tool.get_IKFk_value selection[1] 3
                    append IKFK ikvalue
                    append num_IK_pos num_IKvalue

                    return "L_"
                )
            )
            else(
               ikvalue = 0
               num_IKvalue = 0
                append IKFK ikvalue
                append num_IK_pos num_IKvalue
                return "M_"
            )
        --)catch("bug")

    )

    fn add_key sdtime controller value =
    (
        if controller.keys.count > 0 then (
            for i=1 to controller.keys.count do (
                if controller.keys[i].time ==sdtime then (
                    controller.keys[i].value = value
                    findkey = true
                    --return i --return true
                )else(findkey = false)
            )
            if findkey ==false do (
                addNewKey controller sdtime
                for o=1 to controller.keys.count do (
                    if controller.keys[o].time ==sdtime do (
                        controller.keys[o].value = value
                    )
                )
                    --return false
            )

        )
        else(
            addNewKey controller sdtime
            controller.keys[1].value = value
        )
    )

    fn get_IKFk_value node num =
    (
        --num = 1 limbdata weights
        --num = 2 IKFK ratio
        --num = 3 LimbIKpos
        --num = 4 Retargeting
        CAT_pose_tool.get_avt_layer()
        --if node[3][1].name == "LimbData" do (
        try (node[3][1][num][avt_layer].value)
        catch()
        --)
    )

    fn get_avt_layer =
    (
        try (avt_layer = cat_par[CAT_pose_tool.down_list_cat_char.selection].SelectedLayer)catch()
    )

    fn contr_TCB_Euler alpha =
    (
        for i in selection do (
            if i[3][1].name == "LimbData" do (
                if alpha == 1 then (
                    i[3][2][avt_layer][2].controller = tcb_rotation ()
                )
                else (
                    i[3][2][avt_layer][2].controller = Euler_XYZ ()
                )
            )
            if i[3][1].name == "LayerTrans" do (

                if alpha == 1 then (
                    try (
                        i[3][1][avt_layer][2].controller = tcb_rotation ()
                    )
                    catch(i[3][1][avt_layer][1][2].controller = tcb_rotation ())
                )
                else (
                    try (
                        i[3][1][avt_layer][2].controller = Euler_XYZ ()
                    )
                    catch(i[3][1][avt_layer][1][2].controller = Euler_XYZ ())
                )
            )
            if i[3][1].name == "CATSpineData2" do (
                if alpha == 1 then (
                    i[3][2][avt_layer][2].controller = tcb_rotation ()
                )
                else (
                    i[3][2][avt_layer][2].controller = Euler_XYZ ()
                )
            )
            --if i[3][1].name ==
        )
    )


--addNewKey <controller> <time> [#select] [#interpolate]
/*
CopyPasteAniIni_name = (getdir #userScripts) + "\\joe_scripts\\"+ CopyPasteAni_Name + ".ini";
--history_str = getINISetting CopyPasteAniIni_name "SaveHistory" "History";
setINISetting CopyPasteAniIni_name "SaveHistory" "History" "00"
setINISetting CopyPasteAniIni_name "SaveHistory" "Anim" "11"
 */
----------------------------------------------
            dropdownList down_list_cat_char "" pos:[16,8] width:152 height:22
            button btn_rest "R" pos:[176,8] width:24 height:21 tooltip:"重新加载CAT"

            pickbutton btn_cat_hub "Axis" pos:[17,55] width:50 height:21 tooltip:"选取轴对象"
            button btn_hub "" pos:[73,55] width:128 height:21
            label lab_from_num "" pos:[15,87] width:0 height:13
                --label lab_do_num "" pos:[15,70]
            dropdownList down_list "" pos:[17,86] width:152 height:22
            button del_down_list "X" pos:[176,86] width:24 height:21 tooltip:"删除当前Posture"
            button btn_do_copy "Copy" pos:[122,120] width:47 height:21 tooltip:"复制为一个Posture"
            button btn_do_pas "Paste" pos:[122,146] width:47 height:21  tooltip:"将Posture黏贴到选中对象"
            button btn_do_pas_self "Paste Self" pos:[46,146] width:70 height:21 tooltip:"将Posture黏贴给自己"
            button btn_do_pas_mirror "Paste Mirror" pos:[46,120] width:70 height:21 tooltip:"Posture镜像黏贴给自己"

            button save_pose "S" pos:[16,120] width:24 height:21 tooltip:"保存一个pose"

            button open_pose "O" pos:[16,146] width:24 height:21 tooltip:"加载一个pose"--enabled:false
            GroupBox grp1 "Posture" pos:[8,37] width:200 height:171

            checkbutton btn_pos "P" pos:[175,120] width:24 height:21 tooltip:"是否黏贴位移"
            button btn_baout "?" pos:[175,146] width:24 height:21
            button btn_tcb "TCB" pos:[72,176] width:40 height:21 tooltip:"选中的旋转值转为TCB"
            button btn_euler "Euler" pos:[112,176] width:40 height:21 tooltip:"旋转值转为Euler"
            button btn14 "S" pos:[152,176] width:24 height:21 enabled:false
            button btn15 "S" pos:[176,176] width:24 height:21 enabled:false
            checkbox loadpose_mirr "" pos:[17,176] width:16 height:24 tooltip:"加载pose是否镜像"
            label lbl4 "Mirror" pos:[35,181] width:32 height:16
        /*
        combobox cbx1 "ComboBox" pos:[8,189] width:200 height:9
        edittext edt3 "" pos:[98,334] width:0 height:0
        button btn19 "Button" pos:[8,338] width:80 height:21
        button btn20 "Button" pos:[96,338] width:80 height:21
        checkbox mirror "Checkbox" pos:[8,373] width:16 height:16
        label lbl3 "Mirror" pos:[26,373] width:56 height:16
        button btn21 "Button" pos:[184,333] width:24 height:21


        */
--------------------------------------------------------
        on btn_tcb pressed do (
            CAT_pose_tool.contr_TCB_Euler 1
        )
        on btn_euler pressed do(
            CAT_pose_tool.contr_TCB_Euler 2
        )

--------------------------------------------------------
       on down_list_cat_char selected itm do (
            format "You selected %\n" cat_par_name[itm]
            --cat_par[itm].catrignodes[2] --获取质心
            --cat_par[itm].numlayers  --获取层数
            avt_layer = cat_par[itm].SelectedLayer --当前选择层
            --$[3][1][3]

        )
--------------------------------------------------------
    on btn_rest pressed do (
        C_A_T = CAT_pose_tool.CT()

        C_A_T.pick_cat_par()

        cat_par_name = makeUniqueArray cat_par_name
        cat_par = makeUniqueArray cat_par
        CAT_pose_tool.down_list_cat_char.items = cat_par_name
        CAT_pose_tool.get_avt_layer()
    )
-------------------------------------------------------
    on btn_pos changed state do (
        if state == on then ( pos_ft = true)
        else( pos_ft = false)
    )
--------------------------------------------------------

    on save_pose pressed do (
        cat_par[CAT_pose_tool.down_list_cat_char.selection].SavePose C_A_T.Pose_File  --保存一个pose
        /*
        setINISetting CopyPasteAniIni_name "SaveHistory" "from_transf" (from_transf as string )
        setINISetting CopyPasteAniIni_name "SaveHistory" "fb_transform" (b_transform as string )
        setINISetting CopyPasteAniIni_name "SaveHistory" "copy_form" (copy_form as string )
        setINISetting CopyPasteAniIni_name "SaveHistory" "p3" (p3.name as string )
        setINISetting CopyPasteAniIni_name "SaveHistory" "do_num" (do_num as string )
        setINISetting CopyPasteAniIni_name "SaveHistory" "list_num" (list_num as string )
        setINISetting CopyPasteAniIni_name "SaveHistory" "sele_pose_num" (sele_pose_num as string )
        setINISetting CopyPasteAniIni_name "SaveHistory" "sele_name" (sele_name as string )
        */

    )
--------------------------------------------------------
    on open_pose pressed do (
        if loadpose_mirr.checked then(
            cat_par[CAT_pose_tool.down_list_cat_char.selection].LoadPose C_A_T.Pose_File sliderTime scaledata:true transformdata:true mirrordata:true
        )
        else(
            cat_par[CAT_pose_tool.down_list_cat_char.selection].LoadPose C_A_T.Pose_File sliderTime scaledata:true transformdata:true --mirrordata:true
            )
        /*
        from_transf = execute (getINISetting CopyPasteAniIni_name "SaveHistory" "from_transf")
        b_transform = execute (getINISetting CopyPasteAniIni_name "SaveHistory" "b_transform")
        --pp =(getINISetting CopyPasteAniIni_name "SaveHistory" "p3")
        --p3 =  execute ("$"+pp)
        do_num = execute (getINISetting CopyPasteAniIni_name "SaveHistory" "do_num")
        list_num = execute (getINISetting CopyPasteAniIni_name "SaveHistory" "list_num")
        --sele_pose_num = execute (getINISetting CopyPasteAniIni_name "SaveHistory" "sele_pose_num")
        sele_name = execute (getINISetting CopyPasteAniIni_name "SaveHistory" "sele_name")
        */
        --up_num()
        --CAT_pose.btn_hub.text = p3.name
    )
    ---------------------------- -------------
    on del_down_list pressed do (
        if do_num > 0 do (
            C_A_T.up_num()
            try (deleteItem from_transf (sele_pose_num)) catch()
            try (

                deleteItem list_num (sele_pose_num)
            ) catch()

            try (
                apbas_a=sele_name[sele_pose_num]
                deleteItem selectionsets selectionSets[apbas_a]
            ) catch("选择集名字有误")

            try (
                --deleteItem sele_name do_num
                deleteItem sele_name (sele_pose_num)
            )catch()
            try (deleteItem IKFK (sele_pose_num))catch()
            try (deleteItem num_IK_pos (sele_pose_num))catch()

            try(CAT_pose_tool.down_list.selection = from_transf.count)catch(print (from_transf.count)as string )
            C_A_T.up_num()
            do_num -=1
        )
    )
------------------------------------------------------------
    on down_list selected itm do (
        format "You selected %\n" itm
        --if itm != undefined do (
        --sele_pose_num = itm as integer
        --catch()
            --)
        --sele_pose_num = CAT_pose.down_list.selection = from_transf.count
        C_A_T.up_num()

    )
----------------------------------------------
    on btn_cat_hub picked obj do (

        btn_hub.text = obj.name
        p3 = obj


    )
----------------------------------------------

    on btn_do_copy pressed do (
        if selection.count != 0 do (
            --from_transf = #()
            do_num +=1


            local a_one = #()
            for i in selection do (

                append a_one i.transform
            )
            append from_transf a_one

            --lab_from_num.text = from_transf.count as string
            --lab_do_num.text = do_num as string

            append sele_name ((do_num as string) +"_"+ CAT_pose_tool.ck_limb_l_r() + (sliderTime as string ))
            append list_num sele_name[do_num]
            selectionSets[(sele_name[do_num])] = selection
            --down_list.items = list_num
            CAT_pose_tool.down_list.selection = from_transf.count
            C_A_T.up_num()
            --setINISetting CopyPasteAniIni_name "SaveHistory" "from_transf" (from_transf as string )

        )

    )
-----------------------------------------------
    on btn_do_pas pressed do (
        try(
            for o=1 to selection.count do (
                    if classOf selection[o] == CATBone then (
                        if selection[1][3][1].name == "LimbData" do(
                                CAT_pose_tool.get_avt_layer()
                                CAT_pose_tool.add_key sliderTime selection[1][3][1][3][avt_layer] num_IK_pos[sele_pose_num]
                                CAT_pose_tool.add_key sliderTime selection[1][3][1][2][avt_layer] IKFK[sele_pose_num]
                        )
                        b_transform = C_A_T.flipTm*(from_transf[sele_pose_num][o]*inverse p3.transform)*C_A_T.mirrorTm*p3.transform
                        selection[o].transform = (matrix3 b_transform[1] b_transform[2] b_transform[3] selection[o].transform[4])
                    )
                    --if classOf o == IKTarget do (
                    else(
                        b_transform=C_A_T.flipTm*(from_transf[sele_pose_num][o]*inverse p3.transform)*C_A_T.mirrorTm*p3.transform
                        selection[o].transform = (matrix3 b_transform[1] b_transform[2] b_transform[3] b_transform[4])
                    )

            )
            --from_transf = #()
        )catch()
    )
----------------------------------------------------------
    on btn_do_pas_self pressed do (
        try (
            for p=1 to selection.count do (
                if selection[1][3][1].name == "LimbData" do(
                        CAT_pose_tool.get_avt_layer()
                        CAT_pose_tool.add_key sliderTime selection[1][3][1][3][avt_layer] num_IK_pos[sele_pose_num]
                        CAT_pose_tool.add_key sliderTime selection[1][3][1][2][avt_layer] IKFK[sele_pose_num]
                )
                if CAT_pose_tool.pos_ft then (
                    selection[p].transform =  from_transf[sele_pose_num][p]
                )
                else(
                    selection[p].transform = (matrix3 from_transf[sele_pose_num][p][1] from_transf[sele_pose_num][p][2] from_transf[sele_pose_num][p][3] selection[p].transform[4])
                )
            )
            --from_transf = #()
        )catch()
    )
------------------------------------------------------------
    on btn_do_pas_mirror pressed do (
        --try (
            for y=1 to selection.count do (
                C_A_T.ck_p3()
                if selection[1][3][1].name == "LimbData" do(
                        CAT_pose_tool.get_avt_layer()
                        CAT_pose_tool.add_key sliderTime selection[1][3][1][3][avt_layer] num_IK_pos[sele_pose_num]
                        CAT_pose_tool.add_key sliderTime selection[1][3][1][2][avt_layer] IKFK[sele_pose_num]
                )

                if CAT_pose_tool.pos_ft then (
                     b_transform=C_A_T.flipTm*(from_transf[sele_pose_num][y]*inverse p3.transform)*C_A_T.mirrorTm*p3.transform
                    selection[y].transform = (matrix3 b_transform[1] b_transform[2] b_transform[3] b_transform[4])
                )
                else(
                     b_transform=C_A_T.flipTm*(from_transf[sele_pose_num][y]*inverse p3.transform)*C_A_T.mirrorTm*p3.transform
                    selection[y].transform = (matrix3 b_transform[1] b_transform[2] b_transform[3] selection[y].transform[4])
                )
            )
            --from_transf = #()
        --)catch()
    )
------------------------------------------------------------
    on btn_baout pressed do (
        messageBox (
                "局部姿势为 Posture. 整体姿势为 Pose.没有标记Posture来源,要根据所选中的对象来选择不同的按钮黏贴。选择的 Axis 不同镜像效果也会不一样,一般选择为Hub或Root. BUG反馈：99U-199505. E-Mail:738746223@qq.com"
            )
    )
--------------------------------------------------------------
    on CAT_pose_tool open do (
        --print "open"
        C_A_T = CAT_pose_tool.CT()
        C_A_T.pick_cat_par()


    )
--------------------------------------------------------------

    on CAT_pose_tool close do (
        try(
            for i=1 to sele_name.count do (
                deleteItem selectionsets selectionSets[sele_name[i]]

            )
        )catch()
    )

)


createDialog CAT_pose_tool