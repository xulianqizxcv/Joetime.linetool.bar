                undo on
                (
                    if $ != undefined then
                    (
                        for i in selection do
                        (
                            if i.parent != undefined do
                            (
                            setAppData i 1 i.parent.name
                            --setAppData i 2 ((in coordSys parent i.pos) as string)
                            --setAppData i 3 ((in coordSys parent i.rotation) as string)
                            )
                            setAppData i 2 (i.transform as string)
                            i.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
                            /*
                            i.pos.x                     =   0
                            i.pos.y                 =   0
                            i.pos.z                 =   0
                            i.rotation.x_rotation       =   0
                            i.rotation.y_rotation       =   0
                            i.rotation.z_rotation       =   0
                            */
                        )
                    )
                )