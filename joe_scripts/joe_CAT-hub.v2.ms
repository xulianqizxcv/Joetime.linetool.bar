rollout s_CAT_transform "CAT-hub.v2" width:205 height:120
(
    --local from_cat_hub = undefined
    --global from_cat_hub = undefined
    global j_cat_hub
    struct cat_hub (
    from_cat_hub = #(),
    to_point = undefined,
    Hub_root_name = "",
    hubs_name = "",
    set_name_string = #()
    )
----------------------------------------------
    --pickbutton btn_cat_hub "Select" pos:[8,6] width:50
    button btn_cat_hub "Select" pos:[8,6] width:50
    editText edbt_cat_hub "" fieldWidth:120 height:20 pos:[65,6]
    --radiobuttons btn_fix_oringin "" labels:#("Fix","Root") pos:[8,70] offsets:#([0,0],[-37,20])
    --radiobuttons btn_key_fullkey "" labels:#("FullKey","Set Key") pos:[90,35]
    editText edbt_root_name "Root Name:" fieldWidth:120 height:20 pos:[8,35]
    button btn_do_1 "1" pos:[90,65] width:50
    button btn_do_2 "2" pos:[90,90] width:50
    -----------------------------------------

-----------------------------------------------

    on btn_cat_hub pressed do
    (
        hubs_name = ""
        set_name_string = #()

        for o in selection do(
            append from_cat_hub o
        )
        from_cat_hub = makeUniqueArray from_cat_hub

        gggg =for i in from_cat_hub where true collect i.name--+","
        --set_name_string = for i in from_cat_hub where true collect i.name+","
        set_name_string = makeUniqueArray gggg

        for i in set_name_string do
        (
            hubs_name =(i +",")+ hubs_name
        )

        edbt_cat_hub.text = hubs_name


    )

    on edbt_cat_hub entered txt do(
        if txt  !="" do (
            s_CAT_transform.set_name_string = filterString s_CAT_transform.edbt_cat_hub.text ","
        )
    )
    on edbt_root_name entered txt do (
        if txt !="" do (Hub_root_name = edbt_root_name.text)
    )

    on btn_do_1 pressed do (
         try(
                for t in s_CAT_transform.set_name_string do(
                    --from_cat_hub = execute("$"+ CAT_transform.edbt_cat_hub.text)
                    from_cat_hub = execute("$"+ t)
                    if from_cat_hub == undefined do continue--判定edbt_cat_hub.text 中的set_name_string是否有空名，如有跳过
                    to_point = point()
                    to_point.name = from_cat_hub.name + "_anim_data"
                     --to_Point.transform = from_cat_hub.transform

                     animate On(

                        for t=0 to (animationRange.end.frame as integer) do(
                            at time t

                                to_point.transform = from_cat_hub.transform-- *(( eulerangles 0 0 0  ) as matrix3 )
                                 --a.rotation = inverse c.rotation
                        )
                    )
                )       --Hub_anim_data = to_point
            )
         catch ( messageBox("请确认选择的CAT_Hub无误! ") )
     )


    on btn_do_2 pressed do(


            if queryBox "请确认 CAT Hub 已勾选 Additive To Setup Pose,且需修复添加根 Root" do
            (
                root_point = point()
                if Hub_root_name != "" then (root_point.name = Hub_root_name)
                --else( root_point.name = from_cat_hub.name + "Transform")
                else( root_point.name = "Transform")
                root_point.transform = (matrix3 [0,0,1] [-1.50996e-007,-1,0] [1,-1.50996e-007,0] [0,0,0])--CAT 根特有的旋转偏移
                try (
                    for i in s_CAT_transform.set_name_string do(
                        from_cat_hub = execute("$"+ i)
                        if from_cat_hub == undefined do continue --判定edbt_cat_hub.text 中的set_name_string是否有空名，如有跳过
                        local anim_data = execute("$"+ from_cat_hub.name + "_anim_data")
                        if from_cat_hub.parent == undefined then(
                            from_cat_hub.parent = root_point
                            animate On(
                                for t=0 to (animationRange.end.frame as integer) do(
                                    --at time t ( from_cat_hub.transform = to_point.transform )
                                    at time t ( from_cat_hub.transform = anim_data.transform )
                                )
                            )
                        --if (classof from_cat_hub == HubObject) do (
                        --from_cat_hub.pos.controller = tcb_position ()
                        --from_cat_hub.rotation.controller = tcb_rotation ()
                        --)
                        )
                        else(
                                --messageBox(from_cat_hub.text+"已有根 Root")
                                animate On(
                                    for t=0 to (animationRange.end.frame as integer) do(
                                        at time t ( from_cat_hub.transform = anim_data.transform )
                                    )
                                )
                            )
                    )
                )catch()
            )


    )
)

j_cat_hub = s_CAT_transform.cat_hub()
--createDialog s_CAT_transform