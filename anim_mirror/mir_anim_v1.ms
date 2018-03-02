--2018/3/2 by:4698to
--E-mail:738746223@qq.com

rollout copy_mirr "动画镜像工具v.1" width:216 height:120
(
    --button bt_p3 "P3"
    group "动画镜像" (
        radiobuttons radioAxis "镜像轴：" labels:#("X", "Y", "Z")
        button bt_copy_1 "复制" across:2 tooltip:"复制选中控制器动画"
        button bt_mirror "黏贴" tooltip:"镜像黏贴动画"
    )
    hyperlink lbl_01 "About" address:"https://github.com/4698to/Joetime.linetool.bar/tree/master/anim_mirror" align:#Center
    global c_m

    struct copy_mirror_ver (
        -- Struct body.
        get_copy_tr,
        b_transform,
        copy_for_obj,
        copy_to_obj,
        mirrorTm=scaleMatrix [-1,1,1]
    )--Struct body End .
    -------------------------------------------------------
    on radioAxis changed var do
    (
        case of(
            (var == 1 ): c_m.mirrorTm=scaleMatrix [-1,1,1]
            (var == 2 ): c_m.mirrorTm=scaleMatrix [1,-1,1]
            (var == 3 ): c_m.mirrorTm=scaleMatrix [1,1,-1]
        )
    )
    -------------------------------------------------------

    on bt_copy_1 pressed do
    (
        if selection.count == 1 then
        (
            c_m.copy_for_obj = selection[1]
            --c_m.get_copy_tr = c.transform
        )
        else (messageBox "一次只能选择一个物体 !!  \n\r .")

    )
    -------------------------------------------------------

    on bt_mirror pressed do
    (
        if selection.count == 1 then
        (
            c_m.copy_to_obj = selection[1]
            if c_m.copy_for_obj[3][1].keys.count != 0 do
            (
                for i=1 to c_m.copy_for_obj[3][1].keys.count do
                (
                    undo On
                    (
                        animate On
                        (
                                t = (c_m.copy_for_obj[3][1].keys[i].time.frame as integer)
                                (
                                    at time t
                                    (
                                        local mirroredTm = c_m.copy_for_obj.transform * c_m.mirrorTm
                                        c_m.copy_to_obj.transform = mirroredTm
                                        --c_m.copy_to_obj.transform = (scaleMatrix [1,-1,1])*mirroredTm

                                        --local mirroredTm = c_m.get_copy_tr * c_m.mirrorTm
                                        --selection.transform = mirroredTm
                                        --selection.transform = (scaleMatrix [1,-1,1])*mirroredTm
                                    )
                                )
                        )
                    )
                )
            )
        )
        else
        (
            messageBox "一次只能选择一个物体 !! \n\r ."
        )
    )
    -------------------------------------------------------

)
c_m = copy_mirr.copy_mirror_ver()
createDialog copy_mirr