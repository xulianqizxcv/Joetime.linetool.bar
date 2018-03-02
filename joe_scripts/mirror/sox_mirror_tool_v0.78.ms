plugin modifier 'SoxMirrorTool'
	name:"SoxMirrorTool"
	classID:#(0x6defb01d, 0x58506c06)
	version:1
(
		
	parameters params rollout:MirrorToolRoll
	(
		varDefaultTransform type:#matrix3 animatable:false								-- Default Pose 저장 변수
		varDefaultEmpty type:#boolean default:true animatable:false				-- 기존에 Default Pose가 저장된적이 있는지 검사하는 플래그
		
		varAxisNode type:#node ui:pickAxis animatable:false
		varAxis type:#integer animatable:false ui:radioAxis
		varOptSyncMirroredChieldren type:#boolean default:true animatable:false ui:chkOptSyncMirroredChildren		-- 자식중에 미러 적용된 것들이 동시에 적용될지 옵션
		
		varOppositeNodeName type:#string animatable:false							-- 반대편 오브젝트 이름
		varCopyTransform type:#matrix3 animatable:false								-- Copy Current Transform 변수
		varOptPos type:#boolean animatable:false default:true	 ui:chkObjPos						-- Pos 옵션
		varOptRot type:#boolean animatable:false default:true ui:chkObjRot							-- Rot 옵션
		varOptScale type:#boolean animatable:false default:false ui:chkObjScale				-- Scale 옵션
		
		varSyncCount type:#integer animatable:false default:0		-- Sync 일괄처리 플래그를 위한 파라미터. 현재 롤아웃이 일괄처리시 몇 번째 처리인지를 카운트 하는 파라미터
		
		varBipedFigureScale type:#point3 animatable:false		-- 바이패드 피규어모드만의 스케일 값을 Copy & Paste 용으로 기억하는 파라미터. Copy 할 때 바이패드용으로 동시에 기억시켜줘야함
		-- 하지만 구조가 복잡해져서 일단은 Mirror 에만 피규어모드 스케일을 반영하도록 하여 당장은 이 변수가 사용되진 않음. (사실은 작업하다 말았음)
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
		
		local locBipedFigureScale		-- 바이패드가 Figure Mode 에 있을 때에는 Scale 값이 중요하다. Rotation 과 Position 값은 일반 트랜스폼에서 얻어와서 Mirror 적용하지만 Figure 모드에서만은 바이패드의 Scale 값을 얻어와서 사용하기 위해 바이패드의 트랜스폼을 처리할 땐 항상 이 값을 같이 다뤄준다.
		
		function fnFindSMTModifier obj = -- SoxMirrorTool 모디파이어를 찾아서 해당 인덱스 번호를 리턴한다 못찾으면 0 리턴
		(
			if obj == undefined do return false
			if obj.modifiers.count == 0 do return 0
			for o = 1 to obj.modifiers.count do
			(
				if obj.modifiers[o].name == "SoxMirrorTool" do return o
			)
			
			return 0
		)
		
		-- locSMTTreeArray 이 변수는 매우 중요한 변수이다.
		-- Sync Mirrored Children 옵션에 의해 여러 노드에 한꺼번에 작업하기 위해서 항상 대상 노드들을 기억시켜두는 배열.
		local locSMTTreeArray = #()		-- 모든 자식 노드들 중에서 미러 툴이 적용된 노드의 배열 로컬 변수. 자기 자신은 포함하지 않는다.
		
		local arrGetChildren = #()		-- fnGetChildren 함수는 하위 자식들을 모두 리턴하는 재귀 함수인데 여기서 저장에 사용하는 arrGetChildren 배열은 함수 바깥에서 미리 선언해야함
		function fnGetChildren obj = (		-- 이 함수를 사용할 때는 언제나 arrGetChildren을 함수 바로 앞에서 초기화 해줘야함
			if obj.children.count != 0 do (
				for o = 1 to obj.children.count do (
					append arrGetChildren obj.children[o]
					fnGetChildren obj.children[o]
				)
			)
		)
		
		function fnGetSMTChildren = (		-- locSMTTreeArray 로컬 변수를 셋팅하는 함수. 미러가 적용된 노드를 모두 locSMTTreeArray 배열에 저장한다.
			locSMTTreeArray = #()		-- 일단 초기화
			
			arrGetChildren = #()		-- fnGetChildren 함수를 쓸 때에는 무조건 이 로컬 변수를 초기화해주고 써야함
			fnGetChildren selection[1]		-- arrGetChildren 변수 셋팅. 일단 자식노드들 모두 검토 대상에 넣는다.
			
			for o in arrGetChildren do (
				if (fnFindSMTModifier o) != 0 do (append locSMTTreeArray o)		-- 미러 모디파이어가 있으면 locSMTTreeArray에 추가
			)
			
			-- locSMTTreeArray 변수는 로컬변수이므로 리턴 없이 그냥 종료
		)
		
		function fnSetSMTTreeSyncCount var = (		-- locSMTTreeArray 노드의 varSyncCount 플래그 파라미터를 일괄 셋팅한다. 하나라도 셋팅된게 있으면 숫자 리턴. 없으면 0 리턴
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
		
		-- trParent 로부터 trChild 의 로컬 위치와 로테이션과 스케일 값을 를 리턴한다.
		fn getLocalTransform trParent trChild = -- 입력 값은 matrix3, 리턴 값도 matrix3,
		(
			tempVar = trChild*(inverse trParent)
		)

		-- trParent 를 기준으로 trLocal 값 만큼을 이동한 월드 트랜스폼 값을 리턴한다
		fn setLocalTransform trParent trLocal = -- 입력 값은 matrix3, 리턴 값도 matrix3
		(
			tempVar = trLocal*trParent
		)
		
-- 		fn infoTransform val = --transform 값을 받아들여서 textTransform 의 내용을 pos 와 rotation 으로 보기 좋게 넣어준다.
-- 		(
-- 			textTransform.text = ""
-- 			textTransform.text += "[Position]\n"
-- 			textTransform.text += (val.pos as string) + "\n"
-- 			textTransform.text += "[Rotation]\n"
-- 			textTransform.text += ((val.rotation as eulerAngles) as string) + "\n"
-- 		)

		
		--입력은 노드 출력은 모두 transform matrix3
	
	-- 트랜스폼을 트랙별로 적용하는 순서 : scale > rotation > position 이렇게 해야 다른 트랜스폼 정보를 건드리지 않는다.
	fn mirrorX trCenter trBefore =
	(
		tempTr = getLocalTransform trCenter trBefore
		posTr = transMatrix [tempTr.pos.x * -1, tempTr.pos.y, tempTr.pos.z]
		tempQuat = tempTr.rotation
		tempQuat.y = tempQuat.y * -1
		tempQuat.z = tempQuat.z * -1
		rotTr = tempQuat as matrix3
		FV = matrix3 1 --임시 변수 초기화
		FV = FV * (scaleMatrix trBefore.scale)
		FV = FV * rotTr
		FV = FV * posTr
		
		FV = FV* trCenter		-- 센터 오브젝트로 월드 변환
		FV = ((eulerAngles 0 0 180) as matrix3)*FV
		
		-- 여기까지의 FV는 센터 오브젝트가 반영된 위치와 회전값을 가지고 있으나 센터 오브젝트의 스케일까지도 가지게 되어서 스케일을 없앤 rMat이 필요해짐
		
		rMat = matrix3 1		-- 리턴 변수
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
		FV = matrix3 1 --임시 변수 초기화
		FV = FV * (scaleMatrix trBefore.scale)
		FV = FV * rotTr
		FV = FV * posTr
		
		FV = FV* trCenter		-- 센터 오브젝트로 월드 변환
	-- 	FV = ((eulerAngles 0 0 0) as matrix3)*FV
		
		-- 여기까지의 FV는 센터 오브젝트가 반영된 위치와 회전값을 가지고 있으나 센터 오브젝트의 스케일까지도 가지게 되어서 스케일을 없앤 rMat이 필요해짐
		
		rMat = matrix3 1		-- 리턴 변수
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
		FV = matrix3 1 --임시 변수 초기화
		FV = FV * (scaleMatrix trBefore.scale)
		FV = FV * rotTr
		FV = FV * posTr
		
		FV = FV* trCenter		-- 센터 오브젝트로 월드 변환
		FV = ((eulerAngles 180 0 0) as matrix3)*FV
		
		-- 여기까지의 FV는 센터 오브젝트가 반영된 위치와 회전값을 가지고 있으나 센터 오브젝트의 스케일까지도 가지게 되어서 스케일을 없앤 rMat이 필요해짐
		
		rMat = matrix3 1		-- 리턴 변수
		rMat = rMat * (scaleMatrix trBefore.scale)
		rotate rMat FV.rotation
		translate rMat FV.pos
		return rMat
	)
	
	function fnApplyTransByOpt obj trans =
	(
		-- Add Key Option에 의해서 Pos, Rot, Scale 트랙에 독립적으로 키가 추가되게 하려면 기존 오브젝트에서 추가로 이동시키거나 스케일 조절을 해줘야 한다.
		
		if varOptScale == true do (scale obj (trans.scale / obj.transform.scale))
		if varOptRot == true do (rotate obj (obj.transform.rotation - trans.rotation))
		if varOptPos == true do (move obj (trans.pos - obj.transform.pos))
	)

	function fnApplyMirror transformMe objTarget = -- 미러 적용 함수. 미러 중심은 varAxisNode 파라미터 내용을 가져다 쓴다. 입력 변수는 미러를 계산할 타겟과 적용될 transformMe 는 matrix3
	(
		tempPoint = matrix3 1
		
		if varAxisNode != undefined do tempPoint = varAxisNode.transform -- 축 오브젝트가 있으면 트랜스폼을 임시 포인트에 적용함
			
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
				
				if ((biped.getNode objTarget #horizontal link:1).controller.figuremode == false) then (		-- 피규어모드가 아닌 경우
					objTarget.transform = tempTransform
				)
				else (		--피규어 모드인 경우 (피규어모드는 애니메이션 적용하면 안됨)
					if (locBipedFigureScale != undefined) do (biped.setTransform objTarget #scale locBipedFigureScale false)		-- 피겨모드용으로 따로 기억된 스케일값 적용
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

	function fnFindClosestParent objA objB = -- 두 오브젝트의 부모들 중에 공통된 부모를 찾는데 가장 오브젝트와 가까운 부모를 찾는다. 공통된 부모가 없으면 undefined 리턴
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
	
	function fnSyncOpposite objMe objOpposite = -- 두 오브젝트의 각종 설정이 동일하도록 자동으로 싱크를 한다. 모디파이어가 없으면 추가함
	(
		tModIndex = fnFindSMTModifier objOpposite -- Opposite 오브젝트의 SoxMirrorTool 모디파이어 인덱스 번호를 리턴한다. 0이면 모디파이어가 없는 경우
		if tModIndex == 0 do
		(
			ca = custAttributes.getDef objMe.modifiers[#SoxMirrorTool] 1
			
			addModifier objOpposite (SoxMirrorTool ()) -- AttributeHolder 모디파이어 추가
-- 			objOpposite.modifiers[1].name = "SoxMirrorTool" -- AttributeHolder 모디파이어의 이름을 SoxMirrorTool로 변경
		)
			
		objOpposite.modifiers[#SoxMirrorTool].varOppositeNodeName = objMe.name
		objOpposite.modifiers[#SoxMirrorTool].varAxisNode = objMe.modifiers[#SoxMirrorTool].varAxisNode
		objOpposite.modifiers[#SoxMirrorTool].varAxis = objMe.modifiers[#SoxMirrorTool].varAxis
		
		objOpposite.modifiers[#SoxMirrorTool].varOptPos = objMe.modifiers[#SoxMirrorTool].varOptPos
		objOpposite.modifiers[#SoxMirrorTool].varOptRot = objMe.modifiers[#SoxMirrorTool].varOptRot
		objOpposite.modifiers[#SoxMirrorTool].varOptScale = objMe.modifiers[#SoxMirrorTool].varOptScale

		
		tempPoint = matrix3 1
-- 		if varAxisNode != undefined do tempPoint = varAxisNode.transform -- 축 오브젝트가 있으면 트랜스폼을 임시 포인트에 적용함
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
					if ((biped.getNode selection[1] #horizontal link:1).controller.figuremode == false) then (		-- 피규어모드가 아닌 경우
						selection[1].transform = tempTransform		-- 그냥 간단히 트랜스폼 적용 (IK 때문에 포지션 적용할 때 바이패드 자세가 이상하게 적용되는 일이 많아서 엔간하면 이렇게 한꺼번에 트랜스폼을 넣는게 가장 깔끔하다.
					)
					else (		-- 피규어 모드인 경우 트랜스폼이 안먹어서 따로 처리해야함 (애니메이션은 하면 안됨)
						if (varBipedFigureScale != undefined) do (biped.setTransform selection[1] #scale varBipedFigureScale false)		-- 피겨모드용으로 따로 기억된 스케일값 적용
						biped.setTransform selection[1] #pos tempTransform.pos false
						biped.setTransform selection[1] #rotation tempTransform.rotation false
					)
				)
				else (
					selection[1].transform = tempTransform
				)
					
			if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
				fnSetSMTTreeSyncCount	true	-- 하위노드에도 일괄처리중이라는 카운트 셋팅
				tSel = selection[1]		-- 현재 선택을 잠시 기억하는 변수
				for o in locSMTTreeArray do (
					select o
					o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnPasteTransform.pressed ()
				)
				select tSel
				fnSetSMTTreeSyncCount false		-- 하위노드에도 일괄처리 완료 0 카운트 셋팅
			)
		)
		
		
	)
	
	on btnPasteTransformTarget pressed do
	(
		if (try (getNodeByName varOppositeNodeName) catch undefined) == undefined do return () -- 반대편 오브젝트가 지정되어 있지 않으면 그냥 리턴
		
		undo on
		(
			objTarget = getNodeByName varOppositeNodeName		-- 반대편 오브젝트 지정.
			
			fnApplyMirror varCopyTransform objTarget
			
			if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
				fnSetSMTTreeSyncCount	true	-- 하위노드에도 일괄처리중이라는 카운트 셋팅
				tSel = selection[1]		-- 현재 선택을 잠시 기억하는 변수
				for o in locSMTTreeArray do (
					select o
					o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnPasteTransformTarget.pressed ()
				)
				select tSel
				fnSetSMTTreeSyncCount false		-- 하위노드에도 일괄처리 완료 0 카운트 셋팅
			)
		)
	)

	on btnCopyTransform pressed do
	(
		varCopyTransform = selection[1].transform
		if (classof selection[1].baseObject == Biped_Object) do (varBipedFigureScale = biped.getTransform selection[1] #scale)		-- 바이패드가 피규어모드일 경우를 위한 파라미터 변수 셋팅. 피규어모드에서는 스케일 값이 특이하게 사용되기 떄문에
		
		if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
			fnSetSMTTreeSyncCount	true	-- 하위노드에도 일괄처리중이라는 카운트 셋팅
			tSel = selection[1]		-- 현재 선택을 잠시 기억하는 변수
			for o in locSMTTreeArray do (
				select o
				o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnCopyTransform.pressed ()
			)
			select tSel
			fnSetSMTTreeSyncCount false		-- 하위노드에도 일괄처리 완료 0 카운트 셋팅
		)
	)

	on MirrorToolRoll open do --롤아웃이 생성될 때 수행되는 작업들
	(
		if selection.count >= 2 do -- 미러 툴 롤아웃이 열렸는데 오브젝트가 두개 이상 선택된 상태라는 것은 모디파이어가 Instance 상태라는건데 이러면 곤란함
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
		
		
		if chkOptSyncMirroredChildren.state == true then (		-- 자식 트리구조에 모두 같은 작업을 지시할 때 locSMTTreeArray 로컬 변수에 트리 노드들을 저장한다
			fnGetSMTChildren ()		-- locSMTTreeArray 로컬 변수를 셋팅하는 함수 호출. 미러가 적용된 자식 노드들을 모두 선택하여 저장한다. 자기 자신 제외
		)
		else (
			locSMTTreeArray = #()
		)
		
		animate off -- 초기화 되는 값의 변화는 애니메이션 되면 안된다.
		(
			
			if this.varDefaultEmpty == true do		-- 뭔가 저장된 디폴트 자세가 없으면 일단 기본 자세로 지정한다.
			(
				btnSaveDefaultPose.pressed ()
				this.varDefaultEmpty = false
			)
			
			if  radioAxis.state == 0 do --최초 실행시에는 varAxis 값이 없어서 state 가 0 이다.
			(
				radioAxis.state = 3 -- 기본값 3 적용
				varAxis = 3
			)
						
			if (classof varAxisNode) != undefinedClass do
			(
				pickAxis.object = varAxisNode --파라미터 변수와 UI 변수를 동기화 한다 (파라미터 정의에서 동기화가 안되는 오류가 있음)
				try (pickAxis.tooltip = "Axis : " + varAxisNode.name) catch ()
				pickAxis.text = "Axis : " + varAxisNode.name
			)
			
			if varOppositeNodeName == undefined do (varOppositeNodeName = "")
-- 			print ("test varOppositeNodeName = " + varOppositeNodeName)
			if (getNodeByName varOppositeNodeName) != undefined do
			(	
				pickOpposite.object = (getNodeByName varOppositeNodeName) --파라미터 변수와 UI 변수를 동기화 한다 (파라미터 정의에서 동기화가 안되는 오류가 있음)
				try (pickOpposite.tooltip = "Opposite : " + varOppositeNodeName) catch ()
				pickOpposite.text = "Opposite : " + varOppositeNodeName
			)
			
			--Attribute Holder 이름 초기화 부분
			if selection[1].modifiers.count != 0 do --모디파이어가 하나 이상 있을 경우
			(
				tempCount = 0 --MirrorToolRoll 롤아웃이 몇번째 모디파이어에 있는지 기억하는 숫자 초기화
				tempIfFirst = false --최초 복제된 SoxMirrorTool 은 Attiribute Holder 이름이 무조건 "Attribute Holder" 로 지정되는 문제가 있어서 생성후 처음 선택되는건지를 검사
				
				for o = 1 to selection[1].modifiers.count do --모디파이어 숫자 만큼 반복
				(
					try
					(
						if (classof selection[1].modifiers[o].MirrorToolRoll) == RolloutClass do tempCount = o --MirrorToolRoll 롤아웃이 발견되면 tempCount에다 해당 숫자를 넣는다.
						if (selection[1].modifiers[o].name == "Attribute Holder") do tempIfFirst = true --복제 후 최초 선택된 상태임
					) catch ()
				)
				
				if tempCount != 0 do (selection[1].modifiers[tempCount].name = "SoxMirrorTool")
				
				if tempIfFirst == true do--모디파이어 복제 후 최초 선택인 경우에만 선택 해제 후 재 선택을 해준다 그래야 변경된 이름이 반영된다.
				(
					tempNode = selection[1] --현재 선택을 잠시 기억하고
					actionMan.executeAction 0 "40043"  -- Selection: Select None 선택 해제 후
					select tempNode --다시 선택한다
				)
			)
		)
		
	)
		

	on btnSaveDefaultPose pressed do
	(
		if varDefaultEmpty == false and varSyncCount == 0 do
		(
			if (queryBox "기본 자세를 대체할까요?\n(Do you want to replace the default pose?)" title:"Important" beep:false) == false do return ()
		)
		if selection[1].parent == undefined then (varDefaultTransform = getLocalTransform (matrix3 1) selection[1].transform)
		else (varDefaultTransform = getLocalTransform selection[1].parent.transform selection[1].transform)
		
		if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
			fnSetSMTTreeSyncCount	true	-- 하위노드에도 일괄처리중이라는 카운트 셋팅
			tSel = selection[1]		-- 현재 선택을 잠시 기억하는 변수
			for o in locSMTTreeArray do (
				select o
				o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnSaveDefaultPose.pressed ()
			)
			select tSel
			fnSetSMTTreeSyncCount false		-- 하위노드에도 일괄처리 완료 0 카운트 셋팅
		)
	)
		
	on btnRestoreDefaultPose pressed do
	(
		undo on
		(				
			if selection[1].parent == undefined
				then (tempTransform = setLocalTransform (matrix3 1) varDefaultTransform)
				else (tempTransform = setLocalTransform selection[1].parent.transform varDefaultTransform)		-- 기억된 로컬 트랜스폼을 기준으로 새로운 월드 트랜스폼을 계산한다.
			
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
				fnSetSMTTreeSyncCount	true	-- 하위노드에도 일괄처리중이라는 카운트 셋팅
				tSel = selection[1]		-- 현재 선택을 잠시 기억하는 변수
				for o in locSMTTreeArray do (
					select o
					o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnRestoreDefaultPose.pressed ()
				)
				select tSel
				fnSetSMTTreeSyncCount false		-- 하위노드에도 일괄처리 완료 0 카운트 셋팅
			)
		)
		
	)
	
	-- locBipedFigureScale -- 미러시마다 피규어모드에서 스케일값을 매 번 기억하는 로컬 변수
	on btnMirrorMe pressed do
	(
		if varOppositeNodeName == "" or varOppositeNodeName == undefined do (return ()) -- 반대편 오브젝트가 지정되지 않았으면 그냥 리턴
			
		undo on	(
			tOppObj = getNodeByName varOppositeNodeName
			
			if (classof tOppObj.baseobject) == Biped_Object then (locBipedFigureScale = biped.getTransform tOppObj #scale) else (locBipedFigureScale = undefined)		-- 반대편 오브젝트가 바이패드면 바이패드 방식으로 스케일 값을 일단 locBipedFigureScale 변수에 얻어온다.
			
			fnApplyMirror tOppObj.transform selection[1]
			
			if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
				fnSetSMTTreeSyncCount	true	-- 하위노드에도 일괄처리중이라는 카운트 셋팅
				tSel = selection[1]		-- 현재 선택을 잠시 기억하는 변수
				for o in locSMTTreeArray do (
					select o
					o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnMirrorMe.pressed ()
				)
				select tSel
				fnSetSMTTreeSyncCount false		-- 하위노드에도 일괄처리 완료 0 카운트 셋팅
			)
		)
	)
		
	on btnMirrorTarget pressed do
	(
		if varOppositeNodeName == "" or varOppositeNodeName == undefined do (return ()) -- 반대편 오브젝트가 지정되지 않았으면 그냥 리턴
		
		undo on (
			tOppObj = getNodeByName varOppositeNodeName
			
			if (classof selection[1].baseobject) == Biped_Object then (locBipedFigureScale = biped.getTransform selection[1] #scale) else (locBipedFigureScale = undefined)		-- 현재 오브젝트가 바이패드면 바이패드 방식으로 스케일 값을 일단 locBipedFigureScale 변수에 얻어온다.
			
			fnApplyMirror selection[1].transform tOppObj
			
			if locSMTTreeArray.count != 0 and varSyncCount == 0 do (
				fnSetSMTTreeSyncCount	true	-- 하위노드에도 일괄처리중이라는 카운트 셋팅
				tSel = selection[1]		-- 현재 선택을 잠시 기억하는 변수
				for o in locSMTTreeArray do (
					select o
					o.modifiers[#SoxMirrorTool].MirrorToolRoll.btnMirrorTarget.pressed ()
				)
				select tSel
				fnSetSMTTreeSyncCount false		-- 하위노드에도 일괄처리 완료 0 카운트 셋팅
			)
		)
	)
		
		on pickAxis picked var do
		(
			if (try (getNodeByName varOppositeNodeName) catch undefined) == var do (		 -- 반대편 오브젝트를 축으로 고르면
				pickAxis.object = undefined
				try (pickAxis.tooltip = "None - World") catch ()
				pickAxis.text = "Pick Axis Object"
				return ()
			)
			
			varAxisNode = var --맥스 파일 저장할 때 저장되는 파라미터 변수에 기억
			
			pickAxis.object = var
			try (pickAxis.tooltip = "Axis : " + var.name) catch ()
			pickAxis.text = "Axis : " + var.name
			
			fnSyncOpposite selection[1] (getNodeByName varOppositeNodeName)
		)
		
		on pickOpposite picked var do
		(
			varOppositeNodeName = var.name --맥스 파일 저장할 때 저장되는 파라미터 변수에 기억
			
			pickOpposite.object = var
			try (pickOpposite.tooltip = "Opposite : " + var.name) catch ()
			pickOpposite.text = "Opposite : " + var.name
			
			autoAxis = fnFindClosestParent var selection[1] -- 자동으로 부모를 찾는 함수 돌려서 부모가 찾아지면.
			if autoAxis != undefined do -- Axis 노드에 등록
			(
				varAxisNode = autoAxis --맥스 파일 저장할 때 저장되는 파라미터 변수에 기억
				pickAxis.object = autoAxis
				try (pickAxis.tooltip = "Axis : " + autoAxis.name) catch ()
				pickAxis.text = "Axis : " + autoAxis.name
			)
			
			fnSyncOpposite selection[1] var -- 자신과 Opposite의 미러 셋업을 동기화한다
			tObj = selection[1]
			select var -- 최초 롤아웃을 한번 열어주기 위한 목적으로 Opposite 오브젝트를 선택해준다.
			select tObj -- 다시 원래 오브젝트를 선택
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
			if var then (								-- 자식 트리구조에 모두 같은 작업을 지시할 때 locSMTTreeArray 로컬 변수에 트리 노드들을 저장한다
				fnGetSMTChildren ()		-- locSMTTreeArray 로컬 변수를 셋팅하는 함수 호출. 미러가 적용된 자식 노드들을 모두 선택하여 저장한다. 자기 자신 제외
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