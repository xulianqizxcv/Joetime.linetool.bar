-------------------------------------------------------
-------------------AnimationTool-----------------------
------------------Time:2018-03-23----------------------
-------------------Author:����-------------------------
------------------QQ:409856476-------------------------
--2018-5-7 by Joe
--QQ: 738746223
-------------------------------------------------------

rollout Change_Weight "ChangeWeight_v1.3.2" width:162 height:205
(
	groupBox 'grp1' "CopySkin" pos:[4,7] width:154 height:99 align:#left

    --pickbutton 'source_bone' "from bone" pos:[35,26] width:93 height:21 toolTip:"ѡȡ��Ҫ���滻��Ƥ�Ĺ���" align:#left
    button btn_cp "From Bone" pos:[37,26] width:93 height:21 toolTip:"����ѡ�й���Ȩ��" align:#left

	--pickbutton 'target_bone' "to bone" pos:[40,52] width:82 height:21 toolTip:"ѡȡ�滻��Ƥ�Ĺ���" align:#left
    button btn_ps "To Bone" pos:[37,52] width:93 height:21 toolTip:"Ȩ�ؼ�����ѡ�й���" align:#left

    checkbox ckb_sele_ver "" pos:[12,42] checked:false toolTip:"ֻ������ѡ�е�ģʽ"

	--button 'replaceskin' "Replace" pos:[84,78] width:54 height:21 toolTip:"ѡȡ������ִ���滻" align:#left

	--button 'Cle_btn' "Clean" pos:[25,78] width:43 height:21 toolTip:"���ѡ��Ĺ���" align:#left

    progressBar Bar "ProgressBar" pos:[13,80] width:136 height:16 color:red--������
    -------------------------------------------------------------------------------------------------------------------------
    groupBox group_env "Envelope" pos:[4,110] width:154 height:71

    button btn_env_cp "Copy" pos:[13,129] width:64 height:21 toolTip:"���Ƶ�ǰѡ�з���"
    button btn_env_pa "Paste" pos:[84,129] width:64 height:21 toolTip:"������׵�ѡ�й���"
    button Reset_Env "ResEnv" pos:[55,153] toolTip:"ѡȡģ�����÷���"
    -------------------------------------------------------------------------------------------------------------------------
    hyperlink lbl_help "����" address:"https://www.cgjoy.com/forum.php?mod=viewthread&tid=210646" align:#center offset:[0,10]
    --button btn_cp "From"
    --button btn_ps "To"

	local aBones
	local BoneID
    global in_R
    global out_R
    global objSkin
    global id_a
    global id_b
    global skin_bone
    global objmesh


	-- FUNCTIONS -------------------------------------------------------------------
    fn get_skin_mod_ver obj_skin=  --�ռ���Ƥ��ѡ�е� ��
    (
        selectedVerts =#()
        for i = 1 to (skinOps.GetNumberVertices obj_skin) do --vertnum is number of vertices in skin object
        (
            theVert = skinOps.IsVertexSelected obj_skin i
            if theVert == 1 do (append selectedVerts i )
        )
        return selectedVerts
    )
    --------------------------------------------------
	fn returnObjectBones obj =
	(
		a = skinOps.getNumberBones obj
		for i in 1 to a collect (skinops.getBoneName obj i 1)
	)--�ռ���Ƥ���� ����
    --------------------------------------------------
    /*
	fn returnBoneIndex SkinBoneNum BoneName =
	(
		BoneID = 0

		for n = 1 to SkinBoneNum.count do
		(

			if 	SkinBoneNum[n] == BoneName do--then
            (
				BoneID = n
            )

		)

		return BoneID
	)*/
    ---���ع���ID
    --------------------------------------------------
    fn repskin fron_bone_ID to_bone_ID =
    (
        --try
       -- (
            --max modify mode  --����Ƥ�༭����
            --objSkin = obj_Skin--$.skin  --��ȡ��Ƥ�ļ�
            --objSkin = $.modifiers[#Skin]
            --if objSkin != undefined do--then
            undo "skin" on --������Ч
            (
                SkinBoneNum = returnObjectBones objSkin   --��ȡ��Ƥ����
                target_bone_ID = to_bone_ID --returnBoneIndex SkinBoneNum target_bone.text --��ȡĿ�����ID
                --target_bone_ID = findItem SkinBoneNum target_bone.text   --��ȡĿ�����ID
                --source_bone_ID = findItem SkinBoneNum source_bone.text
                source_bone_ID = fron_bone_ID  --returnBoneIndex SkinBoneNum source_bone.text --��ȡԴ����ID

                if ckb_sele_ver.state then
                (
                    skin_ver = get_skin_mod_ver objSkin
                    if skin_ver.count !=0 then
                    (
                        numSkinVerts = skin_ver
                    )
                    else
                    (
                        numSkinVerts = #{1..(skinOps.getNumberVertices objSkin)}
                    )
                )
                else (
                    numSkinVerts = #{1..(skinOps.getNumberVertices objSkin)}  --��ȡ������Ƥ�ĵ�
                )
                -- numSkinVerts =skinOps.getNumberVertices objSkin --��ȡ������Ƥ�ĵ�


                if target_bone_ID != 0 and source_bone_ID != 0 then
                (
                    -- Process Skin --------------------------------------------------------

                    --for n = 1 to numSkinVerts do
                    for n in numSkinVerts do
                    (
                        -- Find number of bones effecting curent vertex

                        numBoneWeights = skinOps.getVertexWeightCount objSkin n   --��ȡ����IDΪn�������Ƥ�� --ÿ�����м�������Ӱ��

                        -- Find all bone weights

                        aBoneID         = #()  --��������ID����
                        aVertWeights    = #()  --����Ȩ���м���
                         -- skinOps.GetSelectedBone  skin  --��ǰѡ��������
                        for b = 1 to numBoneWeights do
                        (
                            vertexWeight = skinOps.getVertexWeight objSkin n b   --��ȡ��n����Ĳ���ĵ�b������Ȩ��ֵ
                            boneID       = skinOps.getVertexWeightBoneID objSkin n b  --��ȡ��n�������ĵ�b��������ID

                            append aBoneID boneID    --�ռ�������������й���ID
                            append aVertWeights vertexWeight  ---�ռ����������ÿ������ID��Ȩ��ֵ
                        )

                        foundsource_boneIndex = 0
                        for b = 1 to aBoneID.count do   -- �������ұ��滻�����ĵĹ������к���
                        (
                            if aBoneID[b] == source_bone_ID do--then
                            (
                                foundsource_boneIndex = b
                            )
                        )

                        foundtarget_boneIndex = 0
                        for b = 1 to aBoneID.count do   -- ���������滻�����ĵĹ������к���
                        (
                            if aBoneID[b] == target_bone_ID do --then
                            (
                                foundtarget_boneIndex = b
                            )
                        )
                        if foundsource_boneIndex > 0 do --then
                        (
                            sourceWeight = aVertWeights[foundsource_boneIndex]  -- �ռ�

                            if foundtarget_boneIndex > 0 then
                            (
                                aVertWeights[foundtarget_boneIndex] += aVertWeights[foundsource_boneIndex]
                            )
                            else
                            (
                                append aVertWeights sourceWeight
                                append aBoneID target_bone_ID
                            )

                            deleteItem aVertWeights foundsource_boneIndex
                            deleteItem aBoneID foundsource_boneIndex

                            skinOps.replaceVertexWeights objSkin n aBoneID aVertWeights

                                -- End of this vertex
                            update $
                        )
                        --Change_Weight.Bar.value = 100.*n/numSkinVerts
                        Change_Weight.Bar.value = 100.*n/(numSkinVerts.count)
                    )
                    Change_Weight.Bar.value = 0
                )
                else
                (
                    messageBox "ERROR: Source Bone not found in Skin!" title:"target2source"
                )
            )
            /*
            else
            (
                messageBox "ģ��û����Ƥ,�Ƿ�ѡ����ģ��     "
            )
            */
       -- )catch (print "lllllllllllllllll")
    )

    --------------------------------------------------
	-- START OF SCRIPT -------------------------------------------------------------
    --skinOps.addbone <Skin> <Bone_node> <Update_integer>
    -----------------------------------------------------
    on btn_cp pressed do
    (
        objSkin = $.modifiers[#Skin]
        if objSkin != undefined do
        (
            id_a = skinOps.GetSelectedBone objSkin
        )
    )
    on btn_ps pressed do
    (
        objSkin = $.modifiers[#Skin]
        if objSkin != undefined then
        (
            id_b = skinOps.GetSelectedBone objSkin
            if id_a != id_b do
            (
                repskin id_a id_b
            )
        )
        else(
            messageBox "ģ��û����Ƥ,�Ƿ�ѡ����ģ��     "
        )
    )
    -----------------------------------------------------
	on btn_env_cp pressed do
	(

            objSkin =$.modifiers[#Skin]
            objmesh = $
            if objSkin != undefined do
            (
                skin_bone = returnObjectBones objSkin
                bone_id = skinOps.GetSelectedBone objSkin
                if bone_id != 0 then
                (
                    in_R =#() --��Ȧ
                    out_R = #() -- ��Ȧ
                    for i=1 to 2 do
                    (
                        in_R_a = skinOps.getInnerRadius objSkin bone_id i
                        in_R[i] = in_R_a

                        out_R_a = skinOps.getOuterRadius objSkin bone_id i
                        out_R[i] = out_R_a
                    )
                )
                else(
                    messageBox "ѡ�й�������  "
                )
            )
	)
    -----------------------------------------------------
    on btn_env_pa pressed do
    (
        if selection.count !=0 do
        (
            skinbones_name = for i in selection collect i.name
            select objmesh
            max modify mode
            --Change_Weight.Bar.color = blue
            for p= 1 to skinbones_name.count do
            (
                bone_id = findItem skin_bone skinbones_name[p]
                if bone_id != 0 do
                (

                    for o= 1 to 2 do
                    (
                        --try (
                            skinOps.setInnerRadius objSkin bone_id o in_R[o]   --��Ȧ

                            skinOps.setOuterRadius objSkin bone_id o out_R[o]  --��Ȧ
                        --)catch()
                    )
                    Change_Weight.Bar.value = 10.*p/(skinbones_name.count)
                )

            )
            Change_Weight.Bar.value = 0
        )
    )
    -----------------------------------------------------
    on Reset_Env pressed do
    (
        objSkin =$.modifiers[#Skin]
        --skin_BoneNum = returnObjectBones objSkin
        skin_BoneNum = skinOps.getNumberBones objSkin
        for i=1 to skin_BoneNum do
        (
            Bone_Name=skinOps.GetBoneName  objSkin i 1 ---��ȡID��������
            --Bone_Name = ChangeName Bone_Name
            if Bone_Name != undefined do
            (
                try (
                    boneobj = execute ("$"+Bone_Name)
                    )
                catch
                (
                    boneobj = execute ("$"+"'"+Bone_Name+"'")
                )

            )
            case (classof boneobj ) of
            (
                BoneGeometry :
                (
                    --Bone_length=execute("$" + Bone_Name + ".length") ---��ȡ��������
                    Bone_length=boneobj.length ---��ȡ��������
                    --Bone_length * 0.2
                    --skinOps.setEndPoint objSkin i [0,0,0]
                    skinOps.setEndPoint objSkin i [0,0,0]   ---���õ�ǰID�����������׵�
                    skinOps.setStartPoint objSkin i [(Bone_length),0,0]  ---���õ�ǰID������ʼ���׵�
                )
                Biped_Object :
                (
                    /*
                    bound = nodeGetBoundingBox boneobj boneobj.transform
                    selSize = ( bound[2] - bound[1] )

                    --skinOps.setEndPoint objSkin i [0,0,0]
                    skinOps.setStartPoint objSkin i [(selSize.z*0.5),0,0]
                    */
                )
            )
            Change_Weight.Bar.value = (i / skin_BoneNum) * 100
        )
        Change_Weight.Bar.value = 0
    )
)
CreateDialog Change_Weight

