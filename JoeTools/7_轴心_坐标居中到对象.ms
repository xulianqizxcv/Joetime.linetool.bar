        if selection.count != 0 do
        (
            undo on
            (
             selectObj = getCurrentSelection()
             for i in selectObj do CenterPivot i
            )--end undo on
        )