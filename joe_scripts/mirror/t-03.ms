 --CATBone_All = for i in objects where (classof i==CATBone or classof i== HubObject ) collect i
rollout t_01 "ookk v.1"
(
    global all_child =#()
    global all_spr = #()
    global one_obj
    global col_f = 1
    /*
    fn get_child a = --获取所有子对象
    (
        if a.children.count != 0 do
        (
            for i in a.children do
            (
                if classof i == Point do --条件为对象类型 Point
                (

                    local find_n = findString i.name "_Upnode"  --条件排除 名字中有 _Upnode 的
                    if find_n == undefined do(

                        append all_child i
                    )
                )

                if i.children.count !=0 do
                (
                    get_child i
                )

            )
        )

    )
    ---------------------------------

    fn get_s_spr a =
    (
        try
        (
            local a_obj = execute("$"+ a.name + "_Spr001")
            if a_obj !=undefined do
            (
                append all_spr a_obj
            )
        )catch(print "On sele")
    )
    */
    ---------------------------------
    fn get_s_spr a =
    (
        if classof a == Point do
        (
            try
            (
                local g_name = substring a.name 1 (a.name.count-7)
                one_obj = execute("$"+g_name)
                if one_obj !=undefined do
                (
                    append all_spr a
                )
            )catch(print "On sele")
        )
    )
    ---------------------------------
    fn get_bone_spr a =
    (
        if a.children.count != 0 do
        (
            for i in a.children do
            (
                if classof i == BoneGeometry do--
                (
                    --print i.name

                    local a_obj = execute("$"+i.name + "_Spr001")

                    if a_obj !=undefined do
                    (
                        append all_spr a_obj
                    )

                )
                if i.children.count !=0 do
                (
                    get_bone_spr i
                )
            )
        )
    )
    ---------------------------------
    button btn_01 "1" across:2
    button btn_02 "2"
    group "颜色渐变" (
        button bt_gradient "添加渐变" across:2 --offset:[0,10]
        colorPicker cp_start_color "开始颜色" fieldwidth:40 color:blue--[174, 186, 203]
        colorPicker cp_end_color "结束颜色" fieldwidth:40 color:blue--[174, 186, 203]
    )
    ---------------------------------

    on btn_01 pressed do
    (
        if selection.count == 1 do (
            if classof selection[1] == Point do(
                all_spr = #()

                get_s_spr selection[1]
                get_bone_spr one_obj
            )
        )
    )
    on bt_gradient pressed do --添加颜色渐变
    (
        --undo ~UNDO_APPLY_GRADIENT_CAPTION~ on
        --(
           global level     = #()
           /*
            for i = 1 to selection.count do
            (
              local node = selection[i]
              local n    = 0
              do
              (
                n    = n + 1
                node = node.parent
              ) while (node != undefined)
              level[i] = n
            )
            */
            all_spr = #()
            get_s_spr selection[1]
            get_bone_spr one_obj
            for o=1 to all_spr.count do
            (
                level[o]=o
            )

            global minLevel = level[1]
            global maxLevel = minLevel

            for i = 1 to all_spr.count do
            (
                if ( minLevel > level[i] ) do minLevel = level[i]
                if ( maxLevel < level[i] ) do maxLevel = level[i]
            )

            local span = maxLevel - minLevel
            if ( span < 1 ) do span = 1

            local colorDiff = cp_end_color.color - cp_start_color.color
            local colorDiffDistrib = colorDiff/span
           -- global col_f = 1
            for i= 1 to all_spr.count do
            (
                all_spr[i].wirecolor = cp_start_color.color + (level[i] - minLevel) * colorDiffDistrib*col_f
                all_spr[i].size = all_spr[i].size - (level[i] - minLevel)*col_f
            )
            --start_color_cp.color  = selection[1].wirecolor
            cp_end_color.color      = cp_start_color.color + (maxLevel - minLevel) * colorDiffDistrib*col_f
        --)
    )
)
createDialog t_01 200 200
    --get_child b
   -- get_bone_spr b