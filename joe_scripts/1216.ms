rollout bone_help "1214.v2" width:205 height:120
(
    button bt_do_11 "1" pos:[65,65] width:50
    button bt_do_22 "2" pos:[65,90] width:50

    on bt_do_11 pressed do (
            if selection.count != 0  then (
                all_bone_point = #()
                for i in selection do (
                    newpoint = point ()
                    newpoint.name = "point_"+i.name
                    animate On (
                        for t=0 to (animationRange.end.frame as integer) do(
                            at time t
                                newpoint.transform = i.transform

                        )
                    )
                    append all_bone_point newpoint
                )
                --max unlink
                for o in selection do (

                     point_anim = execute("$" +"point_"+o.name )
                    animate On (
                        for t=0 to (animationRange.end.frame as integer) do(
                            at time t
                                o.transform = point_anim.transform

                        )
                    )
                )
                --delete all_bone_point
            )
    )

    on bt_do_22 pressed do (
        if selection.count != 0  then (

            for o in selection do (

                 point_anim = execute("$" +"point_"+o.name )
                animate On (
                    for t=0 to (animationRange.end.frame as integer) do(
                        at time t
                            o.transform = point_anim.transform

                    )
                )
            )
        )

    )
)
createDialog bone_help