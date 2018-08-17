        if selection.count != 0 do
         (
            undo on
            (
            selectObj = getCurrentSelection()
            for i in selectObj do
                (   CenterPivot i
                i.pivot.z = i.min.z
                )
            )--end undo on
        )