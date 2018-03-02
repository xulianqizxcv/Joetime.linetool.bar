rollout copy_mirr "Copy or Mirror" width:216 height:216
(
    --button bt_p3 "P3"
    button bt_copy_1 "copy" across:2
    button bt_mirror "mirror"
    radiobuttons radioAxis "Mirror Axis" labels:#("X", "Y", "Z")
    global c_m

    struct copy_mirror_ver (
        -- Struct body.
        get_copy_tr,
        b_transform,
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
    --return true
    -------------------------------------------------------
    /*
    on bt_p3 pressed do
    (
        p3 = point()
        p3.name = "test_01_pt"
        p3.transform = (matrix3 [0,1.62921e-007,1] [1.50996e-007,-1,1.62921e-007] [1,1.50996e-007,0] [0,0,0])
    )
    */
    -------------------------------------------------------
    on bt_copy_1 pressed do
    (
        if selection.count != 0 do
        (
            c_m.get_copy_tr = selection[1].transform
        )

    )
    -------------------------------------------------------

    on bt_mirror pressed do
    (
        if selection.count !=0 do
        (
            local mirroredTm = c_m.get_copy_tr * c_m.mirrorTm
            selection.transform = mirroredTm
            --selection.transform = (scaleMatrix [1,-1,1])*mirroredTm
        )
    )
    -------------------------------------------------------
    --b_transform = flipTm*(from_transf[sele_pose_num][y]*inverse p3.transform)*C_A_T.mirrorTm*p3.transform
    --selection[y].transform = (matrix3 b_transform[1] b_transform[2] b_transform[3] b_transform[4])
)
c_m = copy_mirr.copy_mirror_ver()
createDialog copy_mirr