 --CATBone_All = for i in objects where (classof i==CATBone or classof i== HubObject ) collect i
rollout t_01 "ookk v.1"
(
    global all_child =#()
    global all_spr = #()
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
    ---------------------------------
    fn get_bone_spr a =
    (
        if a.children.count != 0 do
        (
            for i in a.children do
            (
                if classof i == BoneGeometry do
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

    ---------------------------------

    on btn_01 pressed do
    (
        all_spr = #()
        get_s_spr selection[1]
        get_bone_spr selection[1]
    )
)
createDialog t_01 100 100
    --get_child b
   -- get_bone_spr b