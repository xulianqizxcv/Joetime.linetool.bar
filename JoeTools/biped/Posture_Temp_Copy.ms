
rollout copy_Paste "CopyPosture"
(
    button btn_arm "手交换"
    button btn_leg "脚交换"

    global HotKeyCopyPosture, TempCopyPostureTemp
    Struct HotKeyCopyPostureStruct
	(
		    fn DoHotKeyCopyPosture bip_noed =
			(
				if (classof(bip_noed) == biped_object) do
					(
						case ((maxversion())[1]) of
							(
								7000:	(
											TempCopyPostureTemp = biped.copyPosture bip_noed.transform.controller #posture false false false
										)

								default: (
											NumCol = biped.numCopyCollections bip_noed.transform.controller
											for x = 1 to NumCol do
												(
													if (biped.getCopyCollection bip_noed.transform.controller x).name == "HKCPT" do
														(
															biped.deleteCopyCollection bip_noed.transform.controller x
														)
												)
											biped.createCopyCollection bip_noed.transform.controller "HKCPT"

											TempCopyPostureTemp  = biped.copyPosture bip_noed.transform.controller #posture false false false
											)

							)
					)
			),
			fn DoHotKeyPastePosture bip_noed  =
			(
                animate On
                (
				    biped.pastePosture bip_noed.transform.controller #posture true TempCopyPostureTemp
                )
			)

	)
    on btn_arm pressed do
    (
        if selection.count != 0 and (classOf selection[1] == biped_object)do
        (
            local cs_Larm = #()
            local cs_Rarm = #()
            for i =1 to 4 do
            (
               a = biped.getNode $ #lArm link:i
               b = biped.getNode $ #rArm link:i
               append cs_Larm a
               append cs_Rarm b
            )
            select (cs_Larm + cs_Rarm)

            bip_hub = selection[1].transform.controller.rootNode

            HotKeyCopyPosture.DoHotKeyCopyPosture bip_hub
            undo "paste_arm" on
            (
                HotKeyCopyPosture.DoHotKeyPastePosture bip_hub
            )

        )
        clearSelection()
    )
    on btn_leg pressed do
    (
        if selection.count != 0 and (classOf selection[1] == biped_object)do
        (
            local cs_Lleg = #()
            local cs_Rleg = #()
            for i =1 to 4 do
            (
               a = biped.getNode $ #lleg link:i
               if a == undefined do exit
               b = biped.getNode $ #rleg link:i
               append cs_Lleg a
               append cs_Rleg b
            )
            select (cs_Lleg + cs_Rleg)

            bip_hub = selection[1].transform.controller.rootNode

            HotKeyCopyPosture.DoHotKeyCopyPosture bip_hub
            undo "paste_leg" on
            (
                HotKeyCopyPosture.DoHotKeyPastePosture bip_hub
            )

        )
        clearSelection()
    )

)

createdialog  copy_Paste

HotKeyCopyPosture = copy_Paste.HotKeyCopyPostureStruct()

