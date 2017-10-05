rollout revers_key_Time "反转倒放" width:100 height:120
(

	button btn_CreatPoint "反转" pos:[30,20] --align:#center
    --groupBox Display "Display" width:185 height:186
    label lb_txt3 "ND-网龙" align:#center
	on btn_CreatPoint pressed do
	(

        start_key = animationRange.start.frame as integer
        end_key = animationRange.end.frame as integer
        if selection.count != 0 do (
            for i in selection do(
                biped_obj = i
                biped_b =biped_obj.transform.controller
                animate on (
                    reverseTime biped_b start_key end_key #incLeft #incRight
                )
            )
        )
	)

)

createDialog revers_key_Time

