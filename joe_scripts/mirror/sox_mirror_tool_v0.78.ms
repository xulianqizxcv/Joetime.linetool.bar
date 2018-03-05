plugin modifier 'SoxMirrorTool'
	name:"SoxMirrorTool"
	classID:#(0x6defb01d, 0x58506c06)
	version:1
(
		
	parameters params rollout:MirrorToolRoll
	(
		varDefaultTransform type:#matrix3 animatable:false								-- Default Pose ���� ����
		varDefaultEmpty type:#boolean default:true animatable:false				-- ������ Default Pose�� ��������� �ִ��� �˻��ϴ� �÷���
		
		varAxisNode type:#node ui:pickAxis animatable:false
		varAxis type:#integer animatable:false ui:radioAxis
		varOptSyncMirroredChieldren type:#boolean default:true animatable:false ui:chkOptSyncMirroredChildren		-- �ڽ��߿� �̷� ����� �͵��� ���ÿ� ������� �ɼ�
		
		varOppositeNodeName type:#string animatable:false							-- �ݴ��� ������Ʈ �̸�
		varCopyTransform type:#matrix3 animatable:false								-- Copy Current Transform ����
		varOptPos type:#boolean animatable:false default:true	 ui:chkObjPos						-- Pos �ɼ�
		varOptRot type:#boolean animatable:false default:true ui:chkObjRot							-- Rot �ɼ�
		varOptScale type:#boolean animatable:false default:false ui:chkObjScale				-- Scale �ɼ�
		
		varSyncCount type:#integer animatable:false default:0		-- Sync �ϰ�ó�� �÷��׸� ���� �Ķ����. ���� �Ѿƿ��� �ϰ�ó���� �� ��° ó�������� ī��Ʈ �ϴ� �Ķ����
		
		varBipedFigureScale type:#point3 animatable:false		-- �����е� �ǱԾ��常�� ������ ���� Copy & Paste ������ ����ϴ� �Ķ����. Copy �� �� �����е������ ���ÿ� �����������
		-- ������ ������ ���������� �ϴ��� Mirror ���� �ǱԾ��� �������� �ݿ��ϵ��� �Ͽ� ������ �� ������ ������ ����. (����� �۾��ϴ� ������)
	)
	
	rollout MirrorToolRoll "SOX Mirror Tool v0.78"
	(
		group "Opposite Setup"
		(
			pickbutton pickOpposite "Pick Opposite Object" width:138 align:#center
			button selectOpposite "Select Object" align:#left width:92 across:2
			button clearOpposite "Clear" align:#right backcolor:blue
		)
		
		group "Mirror Setup"
		(
			radiobuttons radioAxis "Mirror Axis" labels:#("X", "Y", "Z") default:3
			pickbutton pickAxis "Pick Axis Object" width:138 align:#center
			button selectCenterObj "Select Object" align:#left width:92 across:2
			button clearCenterObj "Clear" align:#right
			checkBox chkOptSyncMirroredChildren "Sync Mirrored Children"
		)

-- 		edittext textTransform "Saved Local Transform Info" height:60 labelOnTop:true readOnly:true
		
		group "Default Pose"
		(
			button btnSaveDefaultPose "Save Default" align:#left width:76 across:2
			button btnRestoreDefaultPose "Restore" align:#right width:58 
		)
		
		
		group "Copy, Paste"
		(
			button btnCopyTransform "Copy Current Transform" align:#center width:138
			button btnPasteTransform "Paste" align:#left width:52 across:2
			button btnPasteTransformTarget "Paste Target" align:#right width:82
		)
		
		group "Mirror"
		(
			button btnMirrorMe "Mirror Me" width:60 align:#left across:2
			button btnMirrorTarget "Mirror Target" width:74 align:#right
		)
		
		button btnAddKey "Add Key Now" align:#center width:136
		
		group "Add Key Option"
		(
			checkbox chkObjPos "Pos" checked:true across:3
			checkbox chkObjRot "Rot" checked:true
			checkbox chkObjScale "Scale" checked:false
		)
		
		group "Add Key Option (Biped Root)"
		(
			checkbox chkBipHor "Hor" checked:true across:3
			checkbox chkBipVer "Ver" checked:true
			checkbox chkBipTurn "Turn" checked:true
		)
		
		button site "Homepage" width:100
		
		local locBipedFigureScale		-- �����е尡 Figure Mode �� ���� ������ Scale ���� �߿��ϴ�. Rotation �� Position ���� �Ϲ� Ʈ���������� ���ͼ� Mirror ���������� Figure ��忡������ �����е��� Scale ���� ���ͼ� ����ϱ� ���� �����е��� Ʈ�������� ó���� �� �׻� �� ���� ���� �ٷ��ش�.
		
		function fnFindSMTModifier obj = -- SoxMirrorTool ������̾ ã�Ƽ� �ش� �ε��� ��ȣ�� �����Ѵ� ��ã���� 0 ����
		(
			if obj == undefined do return false
			if obj.modifiers.count == 0 do return 0
			for o = 1 to obj.modifiers.count do
			(
				if obj.modifiers[o].name == "SoxMirrorTool" do return o
			)
			
			return 0
		)
		
		-- locSMTTreeArray �� ������ �ſ� �߿��� �����̴�.
		-- Sync Mirrored Children �ɼǿ� ���� ���� ��忡 �Ѳ����� �۾��ϱ� ���ؼ� �׻� ��� ������ �����ѵδ� �迭.
		local locSMTTreeArray = #()		-- ��� �ڽ� ���� �߿��� �̷� ���� ����� ����� �迭 ���� ����. �ڱ� �ڽ��� �������� �ʴ´�.
		
		local arrGetChildren = #()		-- fnGetChildren �Լ��� ���� �ڽĵ��� ��� �����ϴ� ��� �Լ��ε� ���⼭ ���忡 ����ϴ� arrGetChildren �迭�� �Լ� �ٱ����� �̸� �����ؾ���
		function fnGetChildren obj = (		-- �� �Լ��� ����� ���� ������ arrGetChildren�� �Լ� �ٷ� �տ��� �ʱ�ȭ �������
			if obj.children.count != 0 do (
				for o = 1 to obj.children.count do (
					append arrGetChildren obj.children[o]
					fnGetChildren obj.children[o]
				)
			)
		)
		
		function fnGetSMTChildren = (		-- locSMTTreeArray ���� ������ �����ϴ� �Լ�. �̷��� ����� ��带 ��� locSMTTreeArray �迭�� �����Ѵ�.
			locSMTTreeArray = #()		-- �ϴ� �ʱ�ȭ
			
			arrGetChildren = #()		-- fnGetChildren �Լ��� �� ������ ������ �� ���� ������ �ʱ�ȭ���ְ� �����
			fnGetChildren selection[1]		-- arrGetChildren ���� ����. �ϴ� �ڽĳ��� ��� ���� ��� �ִ´�.
			
			for o in arrGetChildren do (
				if (fnFindSMTModifier o) != 0 do (append locSMTTreeArray o)		-- �̷� ������̾ ������ locSMTTreeArray�� �߰�
			)
			
			-- locSMTTreeArray ������ ���ú����̹Ƿ� ���� ���� �׳� ����
		)
		
		function fnSetSMTTreeSyncCount var = (		-- locSMTTreeArray ����� varSyncCount �÷��� �Ķ���͸� �ϰ� �����Ѵ�. �ϳ��� ���õȰ� ������ ���� ����. ������ 0 ����
			if locSMTTreeArray.count == 0 do return 0
			
			tCount = 1
			for o in locSMTTreeArray do (
				if var then (
					o.modifiers[#SoxMirrorTool].varSyncCount = tCount
					tCount += 1
				)
				else (
					o.modifiers[#SoxMirrorTool].varSyncCount = 0
				)
			)
			return tCount
		)
		
		-- trParent �κ��� trChild �� ���� ��ġ�� �����̼ǰ� ������ ���� �� �����Ѵ�.
		fn getLocalTransform trParent trChild = -- �Է� ���� matrix3, ���� ���� matrix3,
		(
			tempVar = trChild*(inverse trParent)
		)

		-- trParent �� �������� trLocal �� ��ŭ�� �̵��� ���� Ʈ������ ���� �����Ѵ�
		fn setLocalTransform trParent trLocal = -- �Է� ���� matrix3, ���� ���� matrix3
		(
			tempVar = trLocal*trParent
		)
		
-- 		fn infoTransform val = --transform ���� �޾Ƶ鿩�� textTransform �� ������ pos �� rotation ���� ���� ���� �־��ش�.
-- 		(
-- 			textTransform.text = ""
-- 			textTransform.text += "[Position]\n"
-- 			textTransform.text += (val.pos as string) + "\n"
-- 			textTransform.text += "[Rotation]\n"
-- 			textTransform.text += ((val.rotation as eulerAngles) as string) + "\n"
-- 		)

		
		--�Է��� ��� ����� ��� transform matrix3
	
	-- Ʈ�������� Ʈ������ �����ϴ� ���� : scale > rotation > position �̷��� �ؾ� �ٸ� Ʈ������ ������ �ǵ帮�� �ʴ´�.
	fn mirrorX trCenter trBefore =
	(
		tempTr = getLocalTransform trCenter trBefore
		posTr = transMatrix [tempTr.pos.x * -1, tempTr.pos.y, tempTr.pos.z]
		tempQuat = tempTr.rotation
		tempQuat.y = tempQuat.y * -1
		tempQuat.z = tempQuat.z * -1
		rotTr = tempQuat as matrix3
		FV = matrix3 1 --�ӽ� ���� �ʱ�ȭ
		FV = FV * (scaleMatrix trBefore.scale)
		FV = FV * rotTr
		FV = FV * posTr
		
		FV = FV* trCenter		-- ���� ������Ʈ�� ���� ��ȯ
		FV = ((eulerAngles 0 0 180) as matrix3)*FV
		
		-- ��������� FV�� ���� ������Ʈ�� �ݿ��� ��ġ�� ȸ������ ������ ������ ���� ������Ʈ�� �����ϱ����� ������ �Ǿ �������� ���� rMat�� �ʿ�����
		
		rMat = matrix3 1		-- ���� ����
		rMat = rMat * (scaleMatrix trBefore.scale)
		rotate rMat FV.rotation
		translate rMat FV.pos
		return rMat
		
	)

	fn mirrorY trCenter trBefore =
	(
		tempTr = getLocalTransform trCenter trBefore
		posTr = transMatrix [tempTr.pos.x, tempTr.pos.y * -1, tempTr.pos.z]
		tempQuat = tempTr.rotation
		tempQuat.x = tempQuat.x * -1
		tempQuat.z = tempQuat.z * -1
		rotTr = tempQuat as matrix3
		FV = matrix3 1 --�ӽ� ���� �ʱ�ȭ
		FV = FV * (scaleMatrix trBefore.scale)
		FV = FV * rotTr
		FV = FV * posTr
		
		FV = FV* trCenter		-- ���� ������Ʈ�� ���� ��ȯ
	-- 	FV = ((eulerAngles 0 0 0) as matrix3)*FV
		
		-- ��������� FV�� ���� ������Ʈ�� �ݿ��� ��ġ�� ȸ������ ������ ������ ���� ������Ʈ�� �����ϱ����� ������ �Ǿ �������� ���� rMat�� �ʿ�����
		
		rMat = matrix3 1		-- ���� ����
		rMat = rMat * (scaleMatrix trBefore.scale)
		rotate rMat FV.rotation
		translate rMat FV.pos
		return rMat
	)

	fn mirrorZ trCenter trBefore =
	(
		tempTr = getLocalTransform trCenter trBefore
		posTr = transMatrix [tempTr.pos.x, tempTr.pos.y, tempTr.pos.z * -1]
		tempQuat = tempTr.rotation
		tempQuat.y = tempQuat.y * -1
		tempQuat.x = tempQuat.x * -1
		rotTr = tempQuat as matrix3
		FV = matrix3 1 --�ӽ� ���� �ʱ�ȭ
		FV = FV * (scaleMatrix trBefore.scale)
		FV = FV * rotTr
		FV = FV * posTr
		
		FV = FV* trCenter		-- ���� ������Ʈ�� ���� ��ȯ
		FV = ((eulerAngles 180 0 0) as matrix3)*FV
		
		-- ��������� FV�� ���� ������Ʈ�� �ݿ��� ��ġ�� ȸ������ ������ ������ ���� ������Ʈ�� �����ϱ����� ������ �Ǿ �������� ���� rMat�� �ʿ�����
		
		rMat = matrix3 1		-- ���� ����
		rMat = rMat * (scaleMatrix trBefore.scale)
		rotate rMat FV.rotation
		translate rMat FV.pos
		return rMat
	)
	
	function fnApplyTransByOpt obj trans =
	(
		-- Add Key Option�� ���ؼ� Pos, Rot, Scale Ʈ���� ���������� Ű�� �߰��ǰ� �Ϸ��� ���� ������Ʈ���� �߰��� �̵���Ű�ų� ������ ������ ����� �Ѵ�.
		
		if varOptScale == true do (scale obj (trans.scale / obj.transform.scale))
		if varOptRot == true do (rotate obj (obj.transform.rotation - trans.rotation))
		if varOptPos == true do (move obj (trans.pos - obj.transform.pos))
	)

	function fnApplyMirror transformMe objTarget = -- �̷� ���� �Լ�. �̷� �߽��� varAxisNode �Ķ���� ������ ������ ����. �Է� ������ �̷��� ����� Ÿ�ٰ� ����� transformMe �� matrix3
	(
		tempPoint = matrix3 1
		
		if varAxisNode != undefined do tempPoint = varAxisNode.transform -- �� ������Ʈ�� ������ Ʈ�������� �ӽ� ����Ʈ�� ������
			
		case of
		(
			(varAxis == 1) : tempTransform = mirrorX tempPoint transformMe
			(varAxis == 2) : tempTransform = mirrorY tempPoint transformMe
			(varAxis == 3) : tempTransform = mirrorZ tempPoint transformMe
			default : ()
		)
		
		case (classof objTarget.baseobject) of
		(
			Biped_Object:(
				case of
				(
					(varAxis == 1) : tempTransform = ((eulerAngles 0 0 180) as matrix3) * tempTransform
					(varAxis == 3) : tempTransform = ((eulerAngles 180 0 0) as matrix3) * tempTransform
					default : ()
				)
				
				if ((biped.getNode objTarget #horizontal link:1).controller.figuremode == false) then (		-- �ǱԾ��尡 �ƴ� ���
					objTarget.transform = tempTransform
				)
				else (		--�ǱԾ� ����� ��� (�ǱԾ���� �ִϸ��̼� �����ϸ� �ȵ�)
					if (locBipedFigureScale != undefined) do (biped.setTransform objTarget #scale locBipedFigureScale false)		-- �ǰܸ������� ���� ���� �����ϰ� ����
					biped.setTransform objTarget #pos tempTransform.pos false
					biped.setTransform objTarget #rotation tempTransform.rotation false
				)
			)
			CATBone:(
				case of
				(
					(varAxis == 1) : tempTransform = ((eulerAngles 0 0 180) as matrix3) * tempTransform
					(varAxis == 3) : tempTransform = ((eulerAngles 180 0 0) as matrix3) * tempTransform
					default : ()
				)
				fnApplyTransByOpt objTarget tempTransform
			)
			default:(fnApplyTransByOpt objTarget tempTransform)
		)
	)

	function fnFindClosestParent objA objB = -- �� ������Ʈ�� �θ�� �߿� ����� �θ� ã�µ� ���� ������Ʈ�� ����� �θ� ã�´�. ����� �θ� ������ undefined ����
	(
		if objA == undefined or objB == undefined do return undefined
			
		tArrParentA = #()
		tArrParentB = #()
		
		tObj = objA.parent
		exitTrigger = false
		while exitTrigger == false do
		(
			if tObj == undefined then exitTrigger = true else
			(
				append tArrParentA tObj
				tObj = tObj.parent
			)
		)
		
		tObj = objB.parent
		exitTrigger = false
		while exitTrigger == false do
		(
			if tObj == undefined then exitTrigger = true else
			(
				append tArrParentB tObj
				tObj = tObj.parent
			)
		)
		
		if tArrParentA.count == 0 or tArrParentB.count == 0 do return undefined
			
		for o = 1 to tArrParentB.count do
		(
			if (findItem tArrParentA tArrParentB[o]) != 0 do return tArrParentB[o]
		)
		return undefined
	)
	
	function fnSyncOpposite objMe objOpposite = -- �� ������Ʈ�� ���� ������ �����ϵ��� �ڵ����� ��ũ�� �Ѵ�. ������̾ ������ �߰���
	(
		tModIndex = fnFindSMTModifier objOpposite -- Opposite ������Ʈ�� SoxMirrorTool ������̾� �ε��� ��ȣ�� �����Ѵ�. 0�̸� ������̾ ���� ���
		if tModIndex == 0 do
		(
			ca = custAttributes.getDef objMe.modifiers[#SoxMirrorTool] 1
			
			addModifier objOpposite (SoxMirrorTool ()) -- AttributeHolder ������̾� �߰�
-- 			objOpposite.modifiers[1].name = "SoxMirrorTool" -- AttributeHolder ������̾��� �̸��� SoxMirrorTool�� ����
		)
			
		objOpposite.modifiers[#SoxMirrorTool].varOppositeNodeName = objMe.name
		objOpposite.modifiers[#SoxMirrorTool].varAxisNode = objMe.modifiers[#SoxMirrorTool].varAxisNode
		objOpposite.modifiers[#SoxMirrorTool].varAxis = objMe.modifiers[#SoxMirrorTool].varAxis
		
		objOpposite.modifiers[#SoxMirrorTool].varOptPos = objMe.modifiers[#SoxMirrorTool].varOptPos
		objOpposite.modifiers[#SoxMirrorTool].varOptRot = objMe.modifiers[#SoxMirrorTool].varOptRot
		objOpposite.modifiers[#SoxMirrorTool].varOptScale = objMe.modifiers[#SoxMirrorTool].varOptScale

		
		tempPoint = matrix3 1
-- 		if varAxisNode != undefined do tempPoint = varAxisNode.transform -- �� ������Ʈ�� ������ Ʈ�������� �ӽ� ����Ʈ�� ������
		case of
		(
			(varAxis == 1) : tempTransform = mirrorX tempPoint varDefaultTransform
			(varAxis == 2) : tempTransform = mirrorY tempPoint varDefaultTransform
			(varAxis == 3) : tempTransform = mirrorZ tempPoint varDefaultTransform
		)
		
		if (classof objMe.baseobject) == Biped_Object OR (classof objMe.baseobject) == CATBone do
			(
				case of
				(
					(varAxis == 1) : tempTransform = ((eulerAngles 0 0 180) as matrix3) * tempTransform
					(varAxis == 3) : tempTransform = ((eulerAngles 180 0 0) as matrix3) * tempTransform
					default : ()
				)
			)
			
		objOpposite.modifiers[#SoxMirrorTool].varDefaultTransform = tempTransform
	)
	
	on btnPasteTransform pressed do
	(
		undo on
		(
			tempTransform = varCopyTransform
			
			if (classof selection[1].baseobject) == Biped_Object
				then (
					if ((biped.getNode selection[1] #horizontal link:1).controller.figuremode == false) then (		-- �ǱԾ��尡 �ƴ� ���
						selection[1].transform = tempTransform		-- �׳� ������ Ʈ������ ���� (IK ������ ������ ������ �� �����е� �ڼ��� �̻��ϰ� ����Ǵ� ���� ���Ƽ� �����ϸ� �̷��� �Ѳ����� Ʈ�������� �ִ°� ���� ����ϴ�.
					)
					else (		-- �ǱԾ� ����� ��� Ʈ�������� �ȸԾ ���� ó���ؾ��� (�ִϸ��̼��� �ϸ� �ȵ�)
						if (varBipedFigureScale != undefined) do (biped.setTransform selection[1] #scale varBipedFigureScale false)		-- �ǰܸ������� ���� ���� �����ϰ� ����
						biped.setTransform selection[1] #pos tempTransform.pos false
						biped.setTransform selection[1] #rotation tempTransform.rotation false
					)
				)
				else (
					selection[1].transform = tempTransform
				)
					
			if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
				fnSetSMTTreeSyncCount	true	-- ������忡�� �ϰ�ó�����̶�� ī��Ʈ ����
				tSel = selection[1]		-- ���� ������ ��� ����ϴ� ����
				for o in locSMTTreeArray do (
					select o
					o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnPasteTransform.pressed ()
				)
				select tSel
				fnSetSMTTreeSyncCount false		-- ������忡�� �ϰ�ó�� �Ϸ� 0 ī��Ʈ ����
			)
		)
		
		
	)
	
	on btnPasteTransformTarget pressed do
	(
		if (try (getNodeByName varOppositeNodeName) catch undefined) == undefined do return () -- �ݴ��� ������Ʈ�� �����Ǿ� ���� ������ �׳� ����
		
		undo on
		(
			objTarget = getNodeByName varOppositeNodeName		-- �ݴ��� ������Ʈ ����.
			
			fnApplyMirror varCopyTransform objTarget
			
			if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
				fnSetSMTTreeSyncCount	true	-- ������忡�� �ϰ�ó�����̶�� ī��Ʈ ����
				tSel = selection[1]		-- ���� ������ ��� ����ϴ� ����
				for o in locSMTTreeArray do (
					select o
					o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnPasteTransformTarget.pressed ()
				)
				select tSel
				fnSetSMTTreeSyncCount false		-- ������忡�� �ϰ�ó�� �Ϸ� 0 ī��Ʈ ����
			)
		)
	)

	on btnCopyTransform pressed do
	(
		varCopyTransform = selection[1].transform
		if (classof selection[1].baseObject == Biped_Object) do (varBipedFigureScale = biped.getTransform selection[1] #scale)		-- �����е尡 �ǱԾ����� ��츦 ���� �Ķ���� ���� ����. �ǱԾ��忡���� ������ ���� Ư���ϰ� ���Ǳ� ������
		
		if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
			fnSetSMTTreeSyncCount	true	-- ������忡�� �ϰ�ó�����̶�� ī��Ʈ ����
			tSel = selection[1]		-- ���� ������ ��� ����ϴ� ����
			for o in locSMTTreeArray do (
				select o
				o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnCopyTransform.pressed ()
			)
			select tSel
			fnSetSMTTreeSyncCount false		-- ������忡�� �ϰ�ó�� �Ϸ� 0 ī��Ʈ ����
		)
	)

	on MirrorToolRoll open do --�Ѿƿ��� ������ �� ����Ǵ� �۾���
	(
		if selection.count >= 2 do -- �̷� �� �Ѿƿ��� ���ȴµ� ������Ʈ�� �ΰ� �̻� ���õ� ���¶�� ���� ������̾ Instance ���¶�°ǵ� �̷��� �����
		(
			for o = 2 to selection.count do
			(
				tModIndex = fnFindSMTModifier selection[o]
				if tModIndex != 0 do deleteModifier selection[o] tModIndex
				addModifier selection[o] (SoxMirrorTool ())
			)
			
			tObj = selection[1]
			clearSelection ()
			select tObj
		)
		
		
		if chkOptSyncMirroredChildren.state == true then (		-- �ڽ� Ʈ�������� ��� ���� �۾��� ������ �� locSMTTreeArray ���� ������ Ʈ�� ������ �����Ѵ�
			fnGetSMTChildren ()		-- locSMTTreeArray ���� ������ �����ϴ� �Լ� ȣ��. �̷��� ����� �ڽ� ������ ��� �����Ͽ� �����Ѵ�. �ڱ� �ڽ� ����
		)
		else (
			locSMTTreeArray = #()
		)
		
		animate off -- �ʱ�ȭ �Ǵ� ���� ��ȭ�� �ִϸ��̼� �Ǹ� �ȵȴ�.
		(
			
			if this.varDefaultEmpty == true do		-- ���� ����� ����Ʈ �ڼ��� ������ �ϴ� �⺻ �ڼ��� �����Ѵ�.
			(
				btnSaveDefaultPose.pressed ()
				this.varDefaultEmpty = false
			)
			
			if  radioAxis.state == 0 do --���� ����ÿ��� varAxis ���� ��� state �� 0 �̴�.
			(
				radioAxis.state = 3 -- �⺻�� 3 ����
				varAxis = 3
			)
						
			if (classof varAxisNode) != undefinedClass do
			(
				pickAxis.object = varAxisNode --�Ķ���� ������ UI ������ ����ȭ �Ѵ� (�Ķ���� ���ǿ��� ����ȭ�� �ȵǴ� ������ ����)
				try (pickAxis.tooltip = "Axis : " + varAxisNode.name) catch ()
				pickAxis.text = "Axis : " + varAxisNode.name
			)
			
			if varOppositeNodeName == undefined do (varOppositeNodeName = "")
-- 			print ("test varOppositeNodeName = " + varOppositeNodeName)
			if (getNodeByName varOppositeNodeName) != undefined do
			(	
				pickOpposite.object = (getNodeByName varOppositeNodeName) --�Ķ���� ������ UI ������ ����ȭ �Ѵ� (�Ķ���� ���ǿ��� ����ȭ�� �ȵǴ� ������ ����)
				try (pickOpposite.tooltip = "Opposite : " + varOppositeNodeName) catch ()
				pickOpposite.text = "Opposite : " + varOppositeNodeName
			)
			
			--Attribute Holder �̸� �ʱ�ȭ �κ�
			if selection[1].modifiers.count != 0 do --������̾ �ϳ� �̻� ���� ���
			(
				tempCount = 0 --MirrorToolRoll �Ѿƿ��� ���° ������̾ �ִ��� ����ϴ� ���� �ʱ�ȭ
				tempIfFirst = false --���� ������ SoxMirrorTool �� Attiribute Holder �̸��� ������ "Attribute Holder" �� �����Ǵ� ������ �־ ������ ó�� ���õǴ°����� �˻�
				
				for o = 1 to selection[1].modifiers.count do --������̾� ���� ��ŭ �ݺ�
				(
					try
					(
						if (classof selection[1].modifiers[o].MirrorToolRoll) == RolloutClass do tempCount = o --MirrorToolRoll �Ѿƿ��� �߰ߵǸ� tempCount���� �ش� ���ڸ� �ִ´�.
						if (selection[1].modifiers[o].name == "Attribute Holder") do tempIfFirst = true --���� �� ���� ���õ� ������
					) catch ()
				)
				
				if tempCount != 0 do (selection[1].modifiers[tempCount].name = "SoxMirrorTool")
				
				if tempIfFirst == true do--������̾� ���� �� ���� ������ ��쿡�� ���� ���� �� �� ������ ���ش� �׷��� ����� �̸��� �ݿ��ȴ�.
				(
					tempNode = selection[1] --���� ������ ��� ����ϰ�
					actionMan.executeAction 0 "40043"  -- Selection: Select None ���� ���� ��
					select tempNode --�ٽ� �����Ѵ�
				)
			)
		)
		
	)
		

	on btnSaveDefaultPose pressed do
	(
		if varDefaultEmpty == false and varSyncCount == 0 do
		(
			if (queryBox "�⺻ �ڼ��� ��ü�ұ��?\n(Do you want to replace the default pose?)" title:"Important" beep:false) == false do return ()
		)
		if selection[1].parent == undefined then (varDefaultTransform = getLocalTransform (matrix3 1) selection[1].transform)
		else (varDefaultTransform = getLocalTransform selection[1].parent.transform selection[1].transform)
		
		if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
			fnSetSMTTreeSyncCount	true	-- ������忡�� �ϰ�ó�����̶�� ī��Ʈ ����
			tSel = selection[1]		-- ���� ������ ��� ����ϴ� ����
			for o in locSMTTreeArray do (
				select o
				o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnSaveDefaultPose.pressed ()
			)
			select tSel
			fnSetSMTTreeSyncCount false		-- ������忡�� �ϰ�ó�� �Ϸ� 0 ī��Ʈ ����
		)
	)
		
	on btnRestoreDefaultPose pressed do
	(
		undo on
		(				
			if selection[1].parent == undefined
				then (tempTransform = setLocalTransform (matrix3 1) varDefaultTransform)
				else (tempTransform = setLocalTransform selection[1].parent.transform varDefaultTransform)		-- ���� ���� Ʈ�������� �������� ���ο� ���� Ʈ�������� ����Ѵ�.
			
			if (classof selection[1].baseobject) == Biped_Object
				then
					(
						selection[1].transform = tempTransform
-- 						case of
-- 						(
-- 							(animButtonState == true):
-- 								(
-- 									biped.setTransform selection[1] #pos tempTransform.pos true
-- 									biped.setTransform selection[1] #rotation tempTransform.rotation true
-- 								)
-- 							(animButtonState == false):
-- 								(
-- 									biped.setTransform selection[1] #pos tempTransform.pos false
-- 									biped.setTransform selection[1] #rotation tempTransform.rotation false
-- 								)
-- 						)
					)
				else (selection[1].transform = tempTransform)
			
			if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
				fnSetSMTTreeSyncCount	true	-- ������忡�� �ϰ�ó�����̶�� ī��Ʈ ����
				tSel = selection[1]		-- ���� ������ ��� ����ϴ� ����
				for o in locSMTTreeArray do (
					select o
					o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnRestoreDefaultPose.pressed ()
				)
				select tSel
				fnSetSMTTreeSyncCount false		-- ������忡�� �ϰ�ó�� �Ϸ� 0 ī��Ʈ ����
			)
		)
		
	)
	
	-- locBipedFigureScale -- �̷��ø��� �ǱԾ��忡�� �����ϰ��� �� �� ����ϴ� ���� ����
	on btnMirrorMe pressed do
	(
		if varOppositeNodeName == "" or varOppositeNodeName == undefined do (return ()) -- �ݴ��� ������Ʈ�� �������� �ʾ����� �׳� ����
			
		undo on	(
			tOppObj = getNodeByName varOppositeNodeName
			
			if (classof tOppObj.baseobject) == Biped_Object then (locBipedFigureScale = biped.getTransform tOppObj #scale) else (locBipedFigureScale = undefined)		-- �ݴ��� ������Ʈ�� �����е�� �����е� ������� ������ ���� �ϴ� locBipedFigureScale ������ ���´�.
			
			fnApplyMirror tOppObj.transform selection[1]
			
			if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
				fnSetSMTTreeSyncCount	true	-- ������忡�� �ϰ�ó�����̶�� ī��Ʈ ����
				tSel = selection[1]		-- ���� ������ ��� ����ϴ� ����
				for o in locSMTTreeArray do (
					select o
					o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnMirrorMe.pressed ()
				)
				select tSel
				fnSetSMTTreeSyncCount false		-- ������忡�� �ϰ�ó�� �Ϸ� 0 ī��Ʈ ����
			)
		)
	)
		
	on btnMirrorTarget pressed do
	(
		if varOppositeNodeName == "" or varOppositeNodeName == undefined do (return ()) -- �ݴ��� ������Ʈ�� �������� �ʾ����� �׳� ����
		
		undo on (
			tOppObj = getNodeByName varOppositeNodeName
			
			if (classof selection[1].baseobject) == Biped_Object then (locBipedFigureScale = biped.getTransform selection[1] #scale) else (locBipedFigureScale = undefined)		-- ���� ������Ʈ�� �����е�� �����е� ������� ������ ���� �ϴ� locBipedFigureScale ������ ���´�.
			
			fnApplyMirror selection[1].transform tOppObj
			
			if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
				fnSetSMTTreeSyncCount	true	-- ������忡�� �ϰ�ó�����̶�� ī��Ʈ ����
				tSel = selection[1]		-- ���� ������ ��� ����ϴ� ����
				for o in locSMTTreeArray do (
					select o
					o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnMirrorTarget.pressed ()
				)
				select tSel
				fnSetSMTTreeSyncCount false		-- ������忡�� �ϰ�ó�� �Ϸ� 0 ī��Ʈ ����
			)
		)
	)
		
		on pickAxis picked var do
		(
			if (try (getNodeByName varOppositeNodeName) catch undefined) == var do (		 -- �ݴ��� ������Ʈ�� ������ ������
				pickAxis.object = undefined
				try (pickAxis.tooltip = "None - World") catch ()
				pickAxis.text = "Pick Axis Object"
				return ()
			)
			
			varAxisNode = var --�ƽ� ���� ������ �� ����Ǵ� �Ķ���� ������ ���
			
			pickAxis.object = var
			try (pickAxis.tooltip = "Axis : " + var.name) catch ()
			pickAxis.text = "Axis : " + var.name
			
			fnSyncOpposite selection[1] (getNodeByName varOppositeNodeName)
		)
		
		on pickOpposite picked var do
		(
			varOppositeNodeName = var.name --�ƽ� ���� ������ �� ����Ǵ� �Ķ���� ������ ���
			
			pickOpposite.object = var
			try (pickOpposite.tooltip = "Opposite : " + var.name) catch ()
			pickOpposite.text = "Opposite : " + var.name
			
			autoAxis = fnFindClosestParent var selection[1] -- �ڵ����� �θ� ã�� �Լ� ������ �θ� ã������.
			if autoAxis != undefined do -- Axis ��忡 ���
			(
				varAxisNode = autoAxis --�ƽ� ���� ������ �� ����Ǵ� �Ķ���� ������ ���
				pickAxis.object = autoAxis
				try (pickAxis.tooltip = "Axis : " + autoAxis.name) catch ()
				pickAxis.text = "Axis : " + autoAxis.name
			)
			
			fnSyncOpposite selection[1] var -- �ڽŰ� Opposite�� �̷� �¾��� ����ȭ�Ѵ�
			tObj = selection[1]
			select var -- ���� �Ѿƿ��� �ѹ� �����ֱ� ���� �������� Opposite ������Ʈ�� �������ش�.
			select tObj -- �ٽ� ���� ������Ʈ�� ����
		)
		
		on clearOpposite pressed do
		(
			varOppositeNodeName = ""
			
			pickOpposite.object = undefined
			try (pickOpposite.tooltip = "Pick Opposite Object") catch ()
			pickOpposite.text = "Pick Opposite Object"
		)
	
		on clearCenterObj pressed do
		(
			varAxisNode = undefined
			
			pickAxis.object = undefined
			try (pickAxis.tooltip = "None - World") catch ()
			pickAxis.text = "Pick Axis Object"
		)
		
		on btnAddKey pressed do
		(
			undo on
			(
				if classof selection[1].baseobject == Biped_Object then
					(
						if selection[1].controller.rootname == selection[1].name then
						(
							if chkBipHor.state == true do biped.addNewKey selection[1].controller.horizontal slidertime
							if chkBipVer.state == true do biped.addNewKey selection[1].controller.vertical slidertime
							if chkBipTurn.state == true do biped.addNewKey selection[1].controller.turning slidertime
						)
						else
						(
							biped.addNewKey selection[1].controller slidertime
						)
						
					)
					else
					(
						if chkObjPos.state == true do (addNewKey selection[1].pos.controller slidertime)
						if chkObjRot.state == true do (addNewKey selection[1].rotation.controller slidertime)
						if chkObjScale.state == true do (addNewKey selection[1].scale.controller slidertime)
					)
			)
		)
		

		
	on selectCenterObj pressed do
	(
		if varAxisNode != undefined do select varAxisNode
	)
		
	on selectOpposite pressed do
	(
		if varOppositeNodeName != "" do select (getNodeByName varOppositeNodeName)
	)
	
		on radioAxis changed var do
		(
			varAxis = var
			if (try (getNodeByName varOppositeNodeName) catch undefined) != undefined do fnSyncOpposite selection[1] (getNodeByName varOppositeNodeName)
		)
		
		on chkObjPos changed var do
		(
			varOptPos = var
			fnSyncOpposite selection[1] (getNodeByName varOppositeNodeName)
		)
		on chkObjRot changed var do
		(
			varOptRot = var
			fnSyncOpposite selection[1] (getNodeByName varOppositeNodeName)
		)
		on chkObjScale changed var do
		(
			varOptScale = var
			fnSyncOpposite selection[1] (getNodeByName varOppositeNodeName)
		)
		
		on chkOptSyncMirroredChildren changed var do (
			if var then (								-- �ڽ� Ʈ�������� ��� ���� �۾��� ������ �� locSMTTreeArray ���� ������ Ʈ�� ������ �����Ѵ�
				fnGetSMTChildren ()		-- locSMTTreeArray ���� ������ �����ϴ� �Լ� ȣ��. �̷��� ����� �ڽ� ������ ��� �����Ͽ� �����Ѵ�. �ڱ� �ڽ� ����
			)
			else (
				locSMTTreeArray = #()
			)
		)

		on site pressed do
		(
			shellLaunch "http://cafe.naver.com/pinksox/2297" ""
		)
	)
)