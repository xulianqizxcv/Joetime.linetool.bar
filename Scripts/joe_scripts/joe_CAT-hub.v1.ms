rollout CAT_transform "CAT-hub.v1" width:205 height:120
(
    --local from_cat_hub = undefined
    global from_cat_hub = undefined
    local to_point = undefined
    local Hub_root_name = ""
----------------------------------------------
    pickbutton btn_cat_hub "Select" pos:[8,6] width:50
    editText edbt_cat_hub "" fieldWidth:120 height:20 pos:[65,6]
    radiobuttons btn_fix_oringin "" labels:#("Fix","Root") pos:[8,70] offsets:#([0,0],[-37,20])
    --radiobuttons btn_key_fullkey "" labels:#("FullKey","Set Key") pos:[90,35]
    editText edbt_root_name "Root Name:" fieldWidth:120 height:20 pos:[8,35]
    button btn_do_1 "1" pos:[90,65] width:50
    button btn_do_2 "2" pos:[90,90] width:50
    -----------------------------------------
    on edbt_root_name entered txt do (
            if txt !="" do (Hub_root_name = edbt_root_name.text)
        )
----------------------------------------------
    on btn_cat_hub picked obj do (
        --btn_cat_hub.text = obj.name
        edbt_cat_hub.text = obj.name
        from_cat_hub = obj
        --from_cat_hub = execute("$"+btn_cat_hub.text)

    )
----------------------------------------------
    on edbt_cat_hub entered txt do(
        if txt !="" do ( from_cat_hub = execute("$"+ edbt_cat_hub.text) )

    )
----------------------------------------------
    on btn_do_1 pressed do (
        try(
                    from_cat_hub = execute("$"+ CAT_transform.edbt_cat_hub.text)

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
                    --Hub_anim_data = to_point
            )
        catch ( messageBox("请确认选择的CAT_Hub无误! ") )
    )
-----------------------------------------------
    on btn_do_2 pressed do (
        try
        (

                if btn_fix_oringin.state == 1 then
                (
                    if queryBox "请确认 CAT Hub 已勾选 Additive To Setup Pose,且需修复" do
                    (
                        --from_cat_hub = execute("$"+ CAT_transform.edbt_cat_hub.text)
                        animate On
                        (
                            for t=0 to (animationRange.end.frame as integer) do
                            (
                                at time t ( from_cat_hub.transform = to_point.transform )
                            )
                        )
                        --if (classof from_cat_hub == HubObject) do (
                            from_cat_hub.pos.controller = tcb_position ()
                            from_cat_hub.rotation.controller = tcb_rotation ()
                        --)
                    )
                )
                else
                (
                    if from_cat_hub.parent == undefined then
                    (
                        if queryBox "请确认 CAT Hub 已勾选 Additive To Setup Pose,且需修复添加根 Root" do
                        (
                            root_point = point()

                            if Hub_root_name != "" then (root_point.name = Hub_root_name)

                            else( root_point.name = from_cat_hub.name + "Transform")
                            root_point.transform = (matrix3 [0,0,1] [-1.50996e-007,-1,0] [1,-1.50996e-007,0] [0,0,0])
                            from_cat_hub.parent = root_point
                            animate On(
                                for t=0 to (animationRange.end.frame as integer) do(
                                    at time t ( from_cat_hub.transform = to_point.transform )
                                )
                            )
                            --if (classof from_cat_hub == HubObject) do (
                            from_cat_hub.pos.controller = tcb_position ()
                            from_cat_hub.rotation.controller = tcb_rotation ()
                            --)
                        )
                    )
                    else (messageBox(from_cat_hub.text+"已有根 Root"))
                )
        )
        catch ( messageBox("请确认选择的CAT_Hub无误或是否已有根Root!") )
    )
----------------------------------------------------------
)
createDialog CAT_transform

/*
obj = objects as array
        sel_CATParent =""
        sel=CATParent
        for i = 1 to obj.count do (
            if (classof obj[i] == sel) and obj[i].isHidden == false do (
                --join selArray #(obj[i])
                print ("find"+" "+obj[i].name)
                sel_CATParent = obj[i]
                )
            )
 */
/*
animate On(
for i=1 to (numKeys a.Position.controller) do (
    t=((getKeytime a.Position.controller i )as integer)/TicksPerFrame
    --print t
    at time t ( b.Position = a.Position )

    )
--------------------------------------------------------------------
for o=1 to (numKeys a.Rotation.controller) do (
    y=((getKeytime a.Rotation.controller o )as integer)/TicksPerFrame
    --print y
    at time y ( b.Rotation = a.Rotation )

    )
)
*/