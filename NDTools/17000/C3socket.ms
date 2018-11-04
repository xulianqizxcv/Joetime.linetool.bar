try(destroyDialog C3Scence_socket)
	catch()
global all_socket = #("v_misc","v_all","v_head","v_l_weapon","v_r_weapon","v_mantle","v_l_arm","v_r_arm","v_l_leg","v_r_leg","v_mount","v_armet","v_extend")
rollout C3Scence_socket "C3挂点工具" width:200 height:265
(
    group "根" (
	button btn_sk_01 all_socket[1] height:20 across:2 tooltip:"根挂点"
    button btn_sk_02 all_socket[2] height:20 tooltip:"手机魔域根挂点"
    )

    button btn_sk_04 all_socket[4] height:20  width:80 across:2
    button btn_sk_05 all_socket[5] height:20 width:80

    button btn_sk_07 all_socket[7] height:20 width:80 across:2
    button btn_sk_08 all_socket[8] height:20 width:80

    button btn_sk_09 all_socket[9] height:20 width:80 across:2
    button btn_sk_10 all_socket[10] height:20 width:80

    button btn_sk_06 all_socket[6] height:20 width:80 across:2
    button btn_sk_11 all_socket[11] height:20 width:80

    button btn_sk_12 all_socket[12] height:20 width:80 across:2
    button btn_sk_13 all_socket[13] height:20 width:80 tooltip:"自动命名扩展挂点"
    label lab01 "选中骨骼之后创建挂点."
	button btn_locks "锁定"   height:28 across:4 tooltip:"锁定位移旋转缩放"
	button btn_unlocks  "开锁"   height:28 tooltip:"放弃锁定"
	button btn_x_copy "复制"   height:28 tooltip:"复制选中挂点位置"
    button btn_x_paste "黏贴"   height:28 tooltip:"X轴镜像黏黏挂点位置"
    label lab02 "2018/11/03 by 熊建桥"
    fn create_mesh parent_bone num =
    (
        if parent_bone != undefined do
        (
            animate off
            (
                socket_mesh = convertTomesh(box length:5 width:5 height:5)
                socket_mesh.pos = parent_bone.transform.pos
                socket_mesh.name = all_socket[num]
                socket_mesh.parent = parent_bone
                setTransformLockFlags socket_mesh #{4,5,6,7,8,9}
                if num < 3 do
                (
                    socket_mesh.pos = [0,0,0] ; setInheritanceFlags socket_mesh #none
                )
                if num == 13 do
                (
                    for i= 1 to 13 do
                    (
                        scoket_name = "v_extend" + (i as string)
                        oldsocket = getNodeByname scoket_name
                        if oldsocket == undefined do
                        (
                            socket_mesh.name = scoket_name
                            exit
                        )
                    )
                )
                select socket_mesh

            )
        )
    )
    on btn_x_copy pressed do
    (
        if selection.count == 1 do
        (
            global socke_copy_pos = selection[1].transform.pos
        )
    )

    on btn_x_paste pressed do
    (
        if selection.count ==1 do
        (
            animate off
            (
                undo "0000101010" on
                (
                    selection[1].pos = [(socke_copy_pos[1] *(-1)),socke_copy_pos[2],socke_copy_pos[3]]
                )
            )
        )
    )
    on btn_sk_01 pressed do
    (
        if classOf selection[1] == Biped_Object do
        (
            try (
            bctr = selection[1].transform.controller
            biped_hub = bctr.rootnode
            create_mesh biped_hub 1
            )catch("尝试勾选show all in track view 之后中试")
        )
    )
    on btn_sk_02 pressed do
    (
        if classOf selection[1] == Biped_Object do
        (
            try (
            bctr = selection[1].transform.controller
            biped_hub = bctr.rootnode
            create_mesh biped_hub 2
            )catch()
        )
    )
    on btn_sk_03 pressed do
    (
        create_mesh selection[1] 3
    )
    on btn_sk_04 pressed do
    (
        create_mesh selection[1] 4
    )
    on btn_sk_05 pressed do
    (
        create_mesh selection[1] 5
    )
    on btn_sk_06 pressed do
    (
        create_mesh selection[1] 6
    )
    on btn_sk_07 pressed do
    (
        create_mesh selection[1] 7
    )
    on btn_sk_08 pressed do
    (
        create_mesh selection[1] 8
    )
    on btn_sk_09 pressed do
    (
        create_mesh selection[1] 9
    )
    on btn_sk_10 pressed do
    (
        create_mesh selection[1] 10
    )
    on btn_sk_11 pressed do
    (
        create_mesh selection[1] 11
    )
    on btn_sk_12 pressed do
    (
        create_mesh selection[1] 12
    )
    on btn_sk_13 pressed do
    (
        create_mesh selection[1] 13
    )
    on btn_locks pressed do
    (
        if selection.count != 0 do
        (
            for i in selection do
            (
                setTransformLockFlags i #all
            )
        )
    )
    on btn_unlocks pressed do
    (
        if selection.count != 0 do
        (
            for i in selection do
            (
                setTransformLockFlags i #none
            )
        )
    )
    ------------------------------------------------------------
)
--createDialog C3Scence_socket







