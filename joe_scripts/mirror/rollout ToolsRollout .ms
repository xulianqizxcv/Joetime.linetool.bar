rollout ToolsRollout ~TOOLSROLLOUT_BONE_EDITING_CAPTION~ width:208 height:330
(
    --------------- variables ------------------------------------
    local UpdateTRUI, getEndPoint, removeIKsolvers  -- declare function as local
    local boneEditModeTurnedOnByMe = false

    -------------- Bone Pivot Position Groupbox elements --------------
    -------------------------------------------------------------------
    GroupBox grp4 ~GRP4_BONE_PIVOT_POSITION_CAPTION~ pos:~GRP4__POSITION~ width:~GRP4_WIDTH~ height:47
    checkbutton BoneEdit_btn ~BONEEDIT_BTN_MODE_CAPTION~ pos:[37,22] width:~BONEEDIT_BTN_MODE_WIDTH~ height:20 -- highlightColor:(color ((colorman.getcolor #pressedbutton).x *255) ((colorman.getcolor #pressedbutton).y *255)((colorman.getcolor #pressedbutton).z *255))
    --checkbox Affect_children_chk "Affect Children" pos:[108,177] width:91 height:16

    -------------- Bone Tools Groupbox elements -------------------------
    ---------------------------------------------------------------
    GroupBox grp31 ~GRP31_BONE_TOOLS_CAPTION~ pos:~GRP31_POSITION~    width:~GRP31_WIDTH~ height:126
    checkButton CreateBone_btn ~CREATEBONE_BTN_CAPTION~ pos:~CREATEBONE_BTN_POSITION~       width:~CREATEBONE_BTN_WIDTH~ height:20 highlightColor:(color ((colorman.getcolor #activecommand).x *255) ((colorman.getcolor #activecommand).y *255)((colorman.getcolor #activecommand).z *255))
    button CreateEnd_btn ~CREATEEND_BTN_CAPTION~          pos:~CREATEEND_BTN_POSITION~  width:~CREATEEND_BTN_WIDTH~ height:20
    button RemoveBone_btn ~REMOVEBONE_BTN_CAPTION~    pos:~REMOVEBONE_BTN_POSITION~     width:~REMOVEBONE_BTN_WIDTH~ height:20
    button ConnectBones_btn ~CONNECTBONES_BTN_CAPTION~   pos:~CONNECTBONES_BTN_POSITION~    width:~CONNECTBONES_BTN_WIDTH~ height:20
    button DeleteBone_btn ~DELETEBONE_BTN_CAPTION~    pos:~DELETEBONE_BTN_POSITION~     width:~DELETEBONE_BTN_WIDTH~ height:20
    button ReassignRoot_btn ~REASSIGNROOT_BTN_CAPTION~   pos:~REASSIGNROOT_BTN_POSITION~    width:~REASSIGNROOT_BTN_WIDTH~ height:20
    checkbutton RefineBone_btn ~REFINEBONE_BTN_CAPTION~       pos:~REFINEBONE_BTN_POSITION~     width:~REFINEBONE_BTN_WIDTH~ height:20 highlightColor:(color ((colorman.getcolor #activecommand).x *255) ((colorman.getcolor #activecommand).y *255)((colorman.getcolor #activecommand).z *255))
    button Mirror_btn ~MIRROR_BTN_CAPTION~                pos:~MIRROR_BTN_POSITION~     width:~MIRROR_BTN_WIDTH~ height:20

    -- HightLightColor:(colorMan.getColor #colorName)
    -------------- Bone Coloring Groupbox elements -------------------------
    ---------------------------------------------------------------
    GroupBox Bone_Coloring_grp ~BONE_COLORING_GRP_CAPTION~ pos:~BONE_COLORING_GRP_POSITION~ width:~BONE_COLORING_GRP_WIDTH~ height:~BONE_COLORING_GRP_HEIGHT~
    colorPicker Bone_color_cp ~BONE_COLOR_CP_SELECTED_CAPTION~ pos:~BONE_COLOR_CP_POSITION~ width:~BONE_COLOR_CP_WIDTH~ height:16 title:~BONE_COLOR_CP_TITLE~ color:[174, 186, 203]




    -------------- Gradient Coloring Groupbox elements -------------------------
    GroupBox grp11 ~GRP11_GRADIENT_COLORING_CAPTION~ pos:~GRP11_GRADIENT_COLORING_POSITION~ width:~GRP11_GRADIENT_COLORING_WIDTH~ height:~GRP11_GRADIENT_COLORING_HEIGHT~
    button Gradient_btn ~GRADIENT_BTN_APPLY_CAPTION~ pos:~GRADIENT_BTN_POSITION~ width:~GRADIENT_BTN_WIDTH~ height:20
    colorPicker start_color_cp ~START_COLOR_CP_CAPTION~ pos:~START_COLOR_CP_POSITION~ fieldwidth:~START_COLOR_CP_FIELDWIDTH~ height:16 title:~START_COLOR_CP_TITLE~ color:[174, 186, 203]
    colorPicker End_color_cp ~END_COLOR_CP_CAPTION~ pos:~END_COLOR_CP_POSITION~ fieldwidth:~END_COLOR_CP_FIEDLWIDTH~ height:16 title:~END_COLOR_CP_TITLE~ color:[174, 186, 203]


    fn getEndPoint a =
    (
        if ( classOf(a) == BoneGeometry ) then
        (
           [a.length,0,0] * a.objectTransform
        )
        else
        (
           (a.transform).translation
        )
    )

    fn removeIKsolvers a =
    (
       if ( (not IsProperty a "pos") or (not IsProperty a "rotation") ) do
       (
         HDIKSys.RemoveChain a
       )
    )

    fn putChildIntoAssembly a =
    (
        if ( (a.parent != undefined) and (a.parent.assemblyMember) ) do
        (
          a.assemblyMember     = true
          a.assemblyMemberOpen = true
        )
    )

    fn getAssemblyHead a =
    (
       b = a
       while ( b != undefined ) do
       (
            if (     b.assemblyHead   ) do return b
            if ( not b.assemblyMember ) do exit
            b = b.parent
       )
       undefined
    )

    fn copyBoneHeightWidth destination source =
    (
        if ( (source != undefined) and (classOf(source) == BoneGeometry) ) do
        (
            destination.width   = source.width
            destination.height  = source.height
        )
    )

    timer boneEditModeTimer interval:100 active:true

    on BoneEdit_btn changed state do
    (
        if (BoneEdit_btn.state == true) then
        (
            boneEditModeTurnedOnByMe = true
            maxops.affectchildren = false
            if isCreatingObject Bones do
            (
                StopCreating()
            )
        )
        else
        (
            boneEditModeTurnedOnByMe = false
            maxops.affectchildren = true
        )
    )

    on boneEditModeTimer tick do
    (
        if ( BoneEdit_btn.state == maxops.affectChildren ) do
        (
            BoneEdit_btn.state = (not maxops.affectChildren)
        )
        if ( BoneEdit_btn.enabled == animButtonState ) do
        (
          BoneEdit_btn.enabled = (not animButtonState)
        )
    )

    on Bone_color_cp changed color do
    (
        undo ~UNDO_BONE_COLOR_CHANGED_CAPTION~ on
        (
            for i= 1 to selection.count do
            (
                selection[i].wirecolor  = Bone_color_cp.color
            )
            --start_color_cp.color  = selection[1].wirecolor
            --end_color_cp.color        = selection[selection.count].wirecolor
        )

    )

    on Gradient_btn pressed do
    (
        undo ~UNDO_APPLY_GRADIENT_CAPTION~ on
        (
            local level     = #()

            for i = 1 to selection.count do
            (
              local node = selection[i]
              local n    = 0
              do
              (
                n    = n + 1
                node = node.parent
              ) while (node != undefined)
              level[i] = n
            )

            local minLevel = level[1]
            local maxLevel = minLevel

            for i = 1 to selection.count do
            (
                if ( minLevel > level[i] ) do minLevel = level[i]
                if ( maxLevel < level[i] ) do maxLevel = level[i]
            )

            local span = maxLevel - minLevel
            if ( span < 1 ) do span = 1

            local colorDiff = end_color_cp.color - start_color_cp.color
            local colorDiffDistrib = colorDiff/span
            for i= 1 to selection.count do
            (
                selection[i].wirecolor = start_color_cp.color + (level[i] - minLevel) * colorDiffDistrib
            )
            --start_color_cp.color  = selection[1].wirecolor
            end_color_cp.color      = start_color_cp.color + (maxLevel - minLevel) * colorDiffDistrib
        )
    )

    on start_color_cp changed color do
    (
        --selection[1].wirecolor = start_color_cp.color
    )
    on End_color_cp changed color do
    (
        --selection[selection.count].wirecolor = end_color_cp.color
    )

    on ReassignRoot_btn pressed do
    (
        undo ~UNDO_REASSIGNROOT_CAPTION~ on
        (
            with redraw off
            (
                with animate off
                (
                    local deleteBoneArr = #()
                    local currentBone   = selection[1]
                    local selBone       = undefined
                    local chlBone       = undefined
                    local parentBone    = currentBone.parent
                    local prevBone      = undefined
                    local newBone       = undefined
                    local newBoneArr    = #()
                    local endBone       = undefined
                    local revReset
                    local exPrevBone    = undefined
                    local i

                    fn isPosSame a b =
                    (
                        local posTol = 5
                        v1=a
                        v2=b
                        vi=0

                        if ((v1.x) <= (v2.x  + posTol)) and ((v1.x) >= (v2.x  - posTol)) then vi +=1
                        if ((v1.y) <= (v2.y  + posTol)) and ((v1.y) >= (v2.y  - posTol)) then vi +=1
                        if ((v1.z) <= (v2.z  + posTol)) and ((v1.z) >= (v2.z  - posTol)) then vi +=1

                        if vi > 1 then true else false
                    )

                    append deleteBoneArr currentBone

                    removeIKsolvers currentBone

                    if currentBone.children.count > 0 then
                    (
                        chlBone = currentBone.children
                        revReset = true
                    )


                    if (classOf(currentBone) == BoneGeometry) and (currentBone.length == 10) and (currentBone.children.count == 0) then
                    (
                        currentBone = parentBone
                        parentBone = currentBone.parent
                        append deleteBoneArr currentBone
                    )

                    if (parentBone != undefined) then
                    (
                        do   -- bone creation loop
                        (
                            removeIKsolvers currentBone

                            if ( classOf(currentBone) == BoneGeometry ) then
                            (
                                newBone = boneSys.createBone (getEndPoint currentBone) currentBone.transform.translation currentBone.dir
                                copyBoneHeightWidth newBone currentBone
                                newBone.name = currentBone.name
                                newBone.wirecolor=currentBone.wirecolor
                                newBone.parent = prevBone
                                newBone.resetBoneStretch()

                                if (parentBone.children.count > 1) and (parentBone.parent != undefined) then
                                (
                                    parentBone.children.parent =  newBone
                                )

                                if (newBone.children == 0) and (newBone.length == 10) then
                                (
                                    delete newBone
                                )

                                if chlBone != undefined then
                                (
                                    chlBone.parent=newBone
                                )

                                if prevBone == undefined then
                                (
                                    selBone = newbone
                                )


                                prevBone = newBone
                                currentBone = parentBone
                                parentBone = currentBone.parent

                                if ( classOf(currentBone) == BoneGeometry ) do append deleteBoneArr currentBone
                                append newBoneArr newBone
                            )
                            else
                            (
                                if (parentBone.children.count > 1) and (parentBone.parent != undefined) then
                                (
                                  local siblings = #()
                                  for  b in parentBone.children do
                                  (
                                    if b != currentBone then
                                    (
                                      append siblings b
                                    )
                                  )
                                  for i = 1 to siblings.count do
                                  (
                                    (siblings[i]).parent = currentBone
                                  )
                                )

                                if chlBone != undefined then
                                (
                                    chlBone.parent=currentBone
                                )

                                if prevBone == undefined then
                                (
                                    selBone = currentBone
                                )

                                exPrevBone  = prevBone
                                prevBone    = currentBone
                                currentBone = parentBone
                                parentBone  = currentBone.parent
                                prevBone.parent = exPrevBone
                                if ( classOf(currentBone) == BoneGeometry ) do append deleteBoneArr currentBone
                            )

                        ) while (parentBone != undefined) -- bone creation loop

                        --removeIKsolvers currentBone

                        if currentBone.children.count > 1 then
                        (
                            if ( classOf(currentBone) == BoneGeometry ) then
                            (
                                local chlVar = #()

                                for b in currentBone.children do
                                (
                                    --removeIKsolvers b
                                    append chlVar b
                                    b.parent = undefined
                                )

                                newBone = boneSys.createBone (getEndPoint currentBone) currentBone.transform.translation currentBone.dir
                                copyBoneHeightWidth newBone currentBone
                                newBone.name = currentBone.name
                                newBone.wirecolor=currentBone.wirecolor
                                newBone.parent = prevBone

                                chlVar.parent=newBone

                                newBone.realignBoneToChild()
                                newBone.resetBoneStretch()
                                append newBoneArr newBone
                            )
                            else
                            (
                                currentBone.parent = prevBone
                                append newBoneArr currentBone
                            )
                        )
                        else
                        (
                            if ( classOf(currentBone) == BoneGeometry ) then
                            (
                                newBone = boneSys.createBone (getEndPoint currentBone) currentBone.transform.translation currentBone.dir
                                copyBoneHeightWidth newBone currentBone
                                newBone.name = currentBone.name
                                newBone.wirecolor=currentBone.wirecolor
                                newBone.parent = prevBone
                                append newBoneArr newBone

                                parentBone = newBone

                                newBone=BoneSys.createBone parentBone.transform.translation (parentBone.transform.translation+6) parentBone.dir
                                copyBoneHeightWidth newBone parentBone
                                newBone.rotation=parentBone.rotation
                                newBone.pos=parentBone.transform.translation
                                in coordSys Local move newBone [parentBone.length,0,0]
                                newBone.parent=parentBone
                                newBone.width=parentBone.width
                                newBone.height=parentBone.height
                                newBone.taper=90
                                newBone.length=(parentBone.width+parentBone.height)/2
                                newBone.wirecolor=parentBone.wirecolor
                            )
                            else
                            (
                                currentBone.parent = prevBone
                            )
                        )

                        for b in deleteBoneArr do
                        (
                          if not isDeleted b do delete b
                        )

                        if (revReset != true) then
                        (
                            for i=1 to newBoneArr.count do
                            (
                                (newBoneArr[i]).resetBoneStretch()
                            )
                        )
                        else
                        (
                            for i=newBoneArr.count to 2 by -1 do
                            (
                                (newBoneArr[i]).resetBoneStretch()
                            )
                        )


                        select selBone
                    )
                )
            )
        )
    )


    on RemoveBone_btn pressed do
    (
        undo ~UNDO_REMOVEBONE_CAPTION~ on(
            if (selection.count == 1) do
            (
                with Animate Off -- with Animate Off bracket open
                (
                    with redraw off
                    (
                        removeIKsolvers $
                        if keyboard.shiftPressed == false then --remove bone, extend children
                        (
                            local parent = $.parent

                            if parent != undefined do
                            (
                                parent.ResetBoneStretch()
                            )

                            for i=1 to $.children.count do
                            (
                                local   chl = $.children [1]
                                removeIKsolvers chl
                                if (classOf chl == BoneGeometry) do chl.pivot = $.transform.translation
                                chl.parent=parent
                                chl.ResetBoneStretch()
                            )

                            $.parent=undefined
                            delete $
                        )
                        else --remove bone, extend parent
                        (
                            local chlArr=#()
                            local chlAsm=#()

                            for i=1 to $.children.count do
                            (
                                append chlArr $.children[i]
                                append chlAsm $.children[i].assemblyMember
                                removeIKsolvers $.children[i]
                            )

                            local chl=$.children[1]
                            local prt=$.parent

                            local asmMbr = $.assemblyMember
                            $.pivot=chl.transform.translation
                            --delete $

                            for i=1 to chlArr.count do
                            (
                                chlArr[i].parent=prt
                                if ( asmMbr and chlAsm[i] ) do
                                (
                                    putChildIntoAssembly chlArr[i]
                                )
                            )
                            delete $
                            if ( prt != undefined ) do
                            (
                                prt.realignBoneToChild()
                                prt.ResetBoneStretch()
                            )


                        )
                    )  -- with Redraw Off bracket close
                    redrawviews()
                ) -- with Animate Off bracket close
            )
        )
    )


    on CreateEnd_btn pressed do
    (
        undo ~UNDO_CREATEEND_CAPTION~ on
        (
            if (selection.count == 1) do
            (
                with Animate Off   --with Animate Off bracket open
                (
                    local parentBone  = selection[1]
                    local parentTrans = parentBone.transform
                    local parentPos   = parentTrans.translation
                    local newbone

                    with redraw off                     (
                        newBone=BoneSys.createBone parentPos (parentPos+6) parentBone.dir
                        newBone.transform = parentTrans
                        in coordSys Local move newBone [parentBone.length,0,0]

                        newBone.parent    = parentBone
                        putChildIntoAssembly newBone

                        newBone.width     = parentBone.width
                        newBone.height    = parentBone.height
                        newBone.taper     = 90
                        newBone.length    = (parentBone.width+parentBone.height)/2
                        newBone.wirecolor = parentBone.wirecolor

                        select newBone
                    )

                    redrawViews()

                ) -- with Animate Off bracket close
            )
        )
    )


    on DeleteBone_btn pressed do
    (
        undo ~UNDO_DELETEBONE_CAPTION~ on(
            if (selection.count == 1 ) do -- and $.parent != undefined) do
            (
                with Animate Off
                ( -- with Animate Off bracket open
                    local parentBone = $.parent
                    if ( parentBone != undefined ) then
                    (
                        parentBone.ResetBoneStretch()
                        if parentBone.children.count == 1 then
                        (
                            if ($.children.count > 0) and (classOf selection[1] == BoneGeometry) then
                            (
                                local selTrans = $.transform
                                local selPos   = selTrans.translation

                                newbone=BoneSys.createBone selPos (selPos+6) ($.dir)
                                newbone.transform = parentBone.transform
                                newbone.pos       = selPos
                                newbone.name      = $.name
                                newbone.wirecolor = $.wirecolor
                                newbone.parent    = parentBone
                                newBone.width     = $.width
                                newBone.height    = $.height
                                newBone.taper     = 90
                                newBone.length    = ($.width+$.height)/2
                            )
                            removeIKsolvers $
                            delete $
                        )
                        else
                        (
                            removeIKsolvers $
                            delete $
                        )
                    )
                    else
                    (
                      removeIKsolvers $
                      delete $
                    )
                ) -- with Animate Off bracket close
            )
        ) -- undo on close
    )

    on ConnectBones_btn pressed do
    (
        undo ~UNDO_CONNECTBONES_CAPTION~ on
        (
            local parentBone, childBone, newBone
            with Animate Off -- with Animate Off bracket open
            (
                parentBone = selection[1]
                parentTip  = [parentBone.length,0,0] * parentBone.objectTransform --parentBone.transform

                fn boneFilt o = Filters.Is_Bone o

                if parentbone.children.count != 0 and keyboard.shiftPressed == false then
                (
                    childBone = PickObject count:1 select:false filter:boneFilt count:1 Message:~PICKOBJECT_MSG_PICK_END_BONE_CAPTION~ Rubberband:parentTip ForceListenerFocus:False

                    if childbone != undefined then
                    (
                        zaxis   = parentBone.dir
                        newbone = BoneSys.createbone parentTip childBone.transform.translation zaxis
                    )
                )
                else
                (
                    childBone = PickObject count:1 select:false filter:boneFilt count:1 Message:~PICKOBJECT_MSG_PICK_END_BONE_CHILD_CAPTION~ Rubberband:parentTip ForceListenerFocus:False

                    if childbone != undefined then
                    (
                        zaxis   = (parentBone.dir+childBone.dir)/2
                        newbone = BoneSys.createbone parentTip childBone.transform.translation zaxis
                    )
                )

                try
                (
                    parentBone.ResetBoneStretch()
                    newbone.width    = (parentbone.width+childbone.width)/2
                    newbone.height   = (parentbone.height+childbone.height)/2
                    newbone.taper    = (parentbone.taper+childbone.taper)/2
                    newbone.name     = uniqueName ~NEWBONE_NAME_CONNECTBONE~


                    newBone.parent    = parentBone
                    if ( childBone.assemblyMember ) do
                    (
                        putChildIntoAssembly newBone
                    )
                    childBone.parent = newbone
                )
                catch()

            ) -- with Animate Off bracket close
        ) -- undo on close
    )


    ------ code to turn off "Create Bone" button once bone creation process ends
    timer createBoneTimer interval:100 active:true

    on CreateBone_btn changed state do
    (
        if state then
        (
            StartObjectCreation Bones
            createBoneTimer.active = true
        )
        else
        (
            if isCreatingObject Bones do
            (
                StopCreating()
            )
        )
    )

    on createBoneTimer tick do
    (
        if not isCreatingObject Bones then
        (
            CreateBone_btn.checked = false
            --createBoneTimer.active = false
        )
        else
        (
            CreateBone_btn.checked = true
        )
    )
    --------------------------------------------------------

    ------ code to turn off "Refine" button once bone creation process ends

    timer refineBoneTimer interval:100 active:false

    on RefineBone_btn changed state do
    (
        bonesys.RefineBone()

        if state do
        (
            refineBoneTimer.active = true
        )
    )

    on refineBoneTimer tick do
    (
        if toolmode.commandmode != #pick and toolmode.commandmode != #viewport do
        (
            RefineBone_btn.checked = false
            refineBoneTimer.active = false
        )
    )