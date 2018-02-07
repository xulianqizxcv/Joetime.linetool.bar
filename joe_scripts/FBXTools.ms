
try(destroyDialog FBXTools)
		catch()	





fn Fn_CollectSkinNodes Fn_AllObjects =  --20170506检索模型和骨骼 并进行分类处理	并返回模型 骨骼 根节点等信息
	(
	fn_SkinNodes = #()
	fn_IsSkinNode = #()
	--检索有skin编辑器的模型 并收集
	fn_IsSkinNode = for o in fn_AllObjects where (not o.isNodehidden and o.modifiers[Skin] != undeinfed) collect o	
	--分别收集每一个模型所参与绑点的骨骼 并整合到一个数组里
	for NodeID = 1 to fn_IsSkinNode.count do 
		(
		fn_SkinBoneNodes = #()
		select fn_IsSkinNode[NodeID]	
		max modify mode
		--激活skin编辑器
		modPanel.setCurrentObject fn_IsSkinNode[NodeID].modifiers[#Skin]
		Bone_Count =  skinOps.GetNumberBones fn_IsSkinNode[NodeID].modifiers[#Skin]

		Fn_SkinBoneNodes = for i = 1 to Bone_Count collect getNodebyname (skinOps.GetBoneName Fn_IsSkinNode[NodeID].modifiers[#Skin] i 0)

		--20170512 修改功能 判断bip的根节点如果没有参与绑点的话 也添加进骨骼选择集
		--for i = 1 to Bone_Count do
		--	(
		--	fn_BoneNode = getNodebyname (skinOps.GetBoneName fn_IsSkinNode[NodeID].modifiers[#Skin] i 0)	
		--	append fn_SkinBoneNodes fn_BoneNode	
		--	)
		--20170515 修正 bip质心重复输入的bug 把判断并添加bip质心的语句 挑出来单独做一个循环
		for o in fn_SkinboneNodes do 
			(
			--如果物体为bip 判断bip质心是否添加进选择集
			if classof o == Biped_Object do 
				(
				if findItem fn_SkinBoneNodes (biped.getNode o 13) == 0 do append fn_SkinBoneNodes (biped.getNode o 13)
				)	
			)
			--20170512 Bug Bip001已经存在绑点骨骼范围之内的时候 如果再添加父物体为 bip001的语句 可能会导致重复输入  总骨骼数量最终多了一位 需要把判断父物体是否为bip001的语句独立出来执行一遍
/*
			
	Fn_AllObjects = objects
	NodeID = 1
	i = 0
	i=i+1
	
 fn_IsSkinNode[NodeID]
	
classof fn_BoneNode == Biped_Object	
findItem fn_SkinBoneNodes (biped.getNode fn_BoneNode 13) == 0
			
print fn_SkinBoneNodes		
 fn_SkinBoneNodes.count

RootID		
parentID			
Fn_SkinBoneRoot
fn_SkinBoneNodes[RootID]
fn_SkinBoneNodes[RootID].parent
			Fn_CollectSkinNodes objects
	
$rotate != undefined and fn_SkinBoneRoot.parent == $rotate

	*/		
		
		--判断骨骼根节点 并挑出根节点ID
		RootID = 1
		parentID = RootID
		--先定义变量
		--local fn_SkinboneRoot
		while parentID > 0 do 
			(
			parentID = findItem fn_SkinBoneNodes fn_SkinBoneNodes[RootID].parent 
			if parentID != 0 do RootID = parentID
			)
		fn_SkinBoneRoot = fn_SkinBoneNodes[RootID]
		--判断骨骼根节点 是否为 rotate
		 if $rotate != undefined and fn_SkinBoneRoot.parent == $rotate do
			(
			fn_SkinBoneRoot = $rotate
			append fn_SkinBoneNodes $rotate
	
			)
		--20170622 摄像机插槽没有隐藏的时候 把没有隐藏的 poisiton 和 v_camera 也加入到骨骼集里
		if $position !=undefined do
			if not $position.isNodehidden do append fn_SkinBoneNodes $position
		if $v_camera !=undefined do
			if not $v_camera.isNodehidden do append fn_SkinBoneNodes $v_camera	
			--添加对插槽的处理 和骨骼有父子链接关系的物体 并且没有隐藏的 都加入到选择集里	 
		for Bone_Slot in Fn_AllObjects do
			if not Bone_Slot.isNodehidden and (findItem Fn_SkinBoneNodes Bone_Slot) == 0 and (findItem Fn_SkinBoneNodes Bone_Slot.parent) != 0 and classof Bone_Slot != BoneGeometry do
				append Fn_SkinBoneNodes Bone_Slot
			
		--整理最终输出数据 格式按[模型名字,骨骼根节点信息,所有骨骼] 格式返回数据
		Fn_SkinNodes[NodeID] =#(Fn_IsSkinNode[NodeID],#(Fn_SkinBoneRoot,Fn_SkinBoneRoot.parent,Fn_SkinBoneRoot.transform),Fn_SkinBoneNodes)	
		)
	return Fn_SkinNodes
	)

--MaxFiles = #()-- bug!!!! 20160727 变量在每次批量导出的时候没有清零 导致重复导出上一次导出的max文件 取消
--20160727 把函数改为单纯循环检索收集子目录的功能
fn GetAllSubPath fn_pickPath = 
	(
	--MaxFiles += getFiles (fn_pickPath +"\\*.max")
	dirs = getDirectories (fn_pickPath + "\\*")
	for SubPath in dirs do 
		(
		dirs += GetAllSubPath SubPath
		)
	return dirs
	)
	
fn GetFbxNameFormMax =
	(
		--20161414 添加max文件名过滤功能 检索扩展名前的 第一个 “-” 以这个为标识，过滤掉这个符号及以后的字符 作为导出的fbx 文件名
	TempName = toLower (getFilenameFile maxfilename)
	NameCutPos = 0
	fn_FBXfileName = ""
	for i in TempName.count to 1 by -1 do	
		if TempName[i] == "-" do
			(
			NameCutPos = i 
			exit
			)
	if NameCutPos > 0 then
		fn_FBXfileName = substring TempName 1 (NameCutPos - 1)
		else fn_FBXfileName = TempName
	--FBXFile = maxFilePath + "fbx\\" + FBXFileName +".fbx"
	--20170506 文件名改为外部组合
	fn_FBXFile = fn_FBXFileName +".fbx"
	return fn_FBXFile
	)
	
rollout FBXTools "FBX相关工具" width:217 height:156
(
	GroupBox grp15 "" pos:[9,-1] width:200 height:125
	groupBox grp6 "" pos:[9,-1] width:100 height:54
	groupBox grp7 "" pos:[9,46] width:100 height:78
	button btn_RemoveCHNChar "名字去中文" pos:[20,16] width:80 height:30 toolTip:"将选中的部分全部去掉中文字符"
	button btn_FBXManualOutput "手动导出" pos:[25,57] width:70 height:25 toolTip:"按规则 一次性导出当前场景未隐藏的物体 不分部件导出"
	button btn_FBXOutput "FBX自动导出" pos:[18,86] width:84 height:33 toolTip:"给当前max档未隐藏的物体 分部件导出单独的fbx文件 "

	--checkbox chk_AutoFbxName "文件名继承" pos:[21,96] width:83 height:17 checked:true
	checkbox chk_ForceOutPutSkin "强制导模型" pos:[119,11] width:83 height:17
	checkbox chk_SubFolders "包含子目录" pos:[119,31] width:83 height:17 checked:true
	button btn_FBXBatchOutput "FBX批量导出" pos:[118,85] width:80 height:30 toolTip:"批量导出fbx 范围为当前max档同位置的所有文件，勾选上\"强制导模型\"选项，则每个fbx都会一起导出未隐藏的模型。勾选上\"包含子目录\"则将当前位置之下的子目录的所有文件都进行批量处理"
	button btn_ExportRule "导出规则说明" pos:[118,53] width:80 height:25
	
	label lbl1 "FBXTools1.41" pos:[16,133] width:65 height:15											
	label lbl2 "-20170515- by 李骅" pos:[104,133] width:105 height:15


fn fnOutPutFbx fn_IsKeepMaxName fn_FBXFile = 
	(
	SelObj = #()
	sliderTime = animationRange.start
		
	--if classof o.controller == Footsteps do hide o --隐藏足迹动画点

			/*
		--测试用数据	
		i= 1
		i = 2	
		SkinNodes[i][2]
		print skinNodes
		skinNodes.count
		print SkinNodes[i][2][3]
		print skinNodes[i][3]
		
		select skinNodes[i][1]	
		select skinNodes[i][3]
		fn_IsKeepMaxName = false
		fn_FBXFile = FBXFile
		fn_FBXFile
		
		isSkinFile
		
		--测试结束
			*/		
		
		
	
	--fbx文件名处理
	NameString = filterString (getFilenameFile MaxFileName) "@"				
		--20161414 给skin文件也加上 "-" 分隔符判断的功能,对分隔符之前的字符进行判断是否为 skin 
	SkinNameCutPos = 0
	isSkinfileName = ""
	for i in NameString[NameString.count].count to 1 by -1 do	
		if NameString[NameString.count][i] == "-" do
		(
			SkinNameCutPos = i 
			exit
			)
	if SkinNameCutPos > 0 then
		isSkinfileName = substring NameString[NameString.count] 1 (SkinNameCutPos - 1)
		else isSkinfileName = NameString[NameString.count]
	
		--判断处理之后的名字 是否有4个字符	
	if isSkinfileName.count >= 4 then
		(	
		IsSkinFile = substring isSkinfileName (isSkinfileName.count - 3) isSkinfileName.count
		--IsSkinFile = substring NameString[NameString.count] (NameString[NameString.count].count - 3) NameString[NameString.count].count
		)
		else isSkinFile = isSkinfileName

	
	
	--判断是否手动导出fbx文件
	if fn_IsKeepMaxName then --自动导出
		(	
		SkinNodes =  Fn_CollectSkinNodes objects -- 取得多个模型的分类信息
		

		for i = 1 to SkinNodes.count do
			(
			--加入筛选之后的模型和骨骼
			--骨骼Bone on
			skinNodes[i][3].boneEnable = true
			skinNodes[i][3].boneScaleType=#none	
			OutPutAnimation = true		
			if tolower IsSkinFile == "skin" then
				(
				SelObj =  #(SkinNodes[i][1]) + SkinNodes[i][3]
				OutPutAnimation = false		
				)
				--else if chk_ForceOutPutSkin.checked then SelObj =  #(SkinNodes[i][1]) + SkinNodes[i][3]		
				else SelObj =  SkinNodes[i][3]
			--判断是否导出模型 处理结束
				
			--对根节点进行归零处理	20170508修改 rotate 也需要归零 做骑宠的时候可以用到
			--20170515 根节点归零功能修改 检测到根节点如果是bip质心 或者根节点位移为0但是旋转不为零的物体 不进行归零处理
			RootRestID = true
	
			if classof SkinNodes[i][2][1] == Biped_Object then RootRestID = false
				else if SkinNodes[i][2][1].pos as string == "[0,0,0]" then RootRestID = false
				else if SkinNodes[i][2][2] == undefined do RootRestID = false
			
			if RootRestID do
				(
				SkinNodes[i][2][1].parent = undefined 
				animate off SkinNodes[i][2][1].transform 	= (matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])
				)
				--归零结束
				
			-- 基本完成分部件导出功能 还需要全面测试 以及完善手动单独导出的机制
			--手动单独导出基本测试通过 采用放弃分部件导出的功能 直接一次性导出未隐藏的所有物体 隐藏物体也导出的bug已修正
				
			select SelObj
			if OutPutAnimation then FbxExporterSetParam "Animation" true
				else FbxExporterSetParam "Animation" false
			
			--20170506 对FBX文件导出路径进行重新计算
			fn_FBXPath = maxFilePath +"fbx_"+ SkinNodes[i][1].name +"\\"
			fn_FBXFile = fn_FBXPath + GetFbxNameFormMax()
			if not doesFileExist fn_FBXPath do makeDir fn_FBXPath
			--开始fbx文件导出
			if fn_FBXFile!=undefined do deletefile fn_FBXFile
			o = exporterplugin.classes
			for i = 1 to o.count do
				(
				if o[i] as string == "FBXEXP" then
				exportFile fn_FBXFile #noPrompt selectedOnly:true using:exporterPlugin.classes[i] 
				)
				
			--骨骼根节点归位 20170508修改 rotate 也需要归零 做骑宠的时候可以用到
			if RootRestID do
				(
				SkinNodes[i][2][1].parent = SkinNodes[i][2][2]
				animate off SkinNodes[i][2][1].transform 	= SkinNodes[i][2][3]
				)
			)
		)
		else --手动导出
		(
		OutPutAnimation = true
		for o in objects do 
			(
			if o.isNodehidden == false do
				(
				--判断物体是否为Bip和Bone 是则将其当骨骼进行处理
				if classof o == Biped_Object or classof o == BoneGeometry or classof o.parent == Biped_Object or classof o.parent == BoneGeometry then 
					(
					o.boneEnable = true
					o.boneScaleType = #none
					append SelObj o
					)
				
				if tolower IsSkinFile == "skin" then
					--20170126 添加对 Skin或者 PHY编辑器的判断 如果不是带编辑器的 就不导出
					if o.modifiers[Skin] != undeinfed or o.modifiers[Physique] != undeinfed do
						(
						append SelObj o
						OutPutAnimation = false
						)
				else if chk_ForceOutPutSkin.checked do append SelObj o
				)
			)
		if $position !=undefined do
			if not $position.isNodehidden do append SelObj $position
		if $v_camera !=undefined do
			if not $v_camera.isNodehidden do append SelObj $v_camera	
				
		select SelObj
		if OutPutAnimation then FbxExporterSetParam "Animation" true
			else FbxExporterSetParam "Animation" false
		--strCurPath = substring maxFilePath 1 (maxFilePath.count - 1)
		--开始fbx文件导出
		if fn_FBXFile!=undefined do deletefile fn_FBXFile
		o = exporterplugin.classes
		for i = 1 to o.count do
			(
			if o[i] as string == "FBXEXP" then
			exportFile fn_FBXFile #noPrompt selectedOnly:true using:exporterPlugin.classes[i] 
			)
		)
		
	)

	on FBXTools open do
		(
	
	)
	on btn_RemoveCHNChar pressed do
		(
		try
			(
			objid = 1
			for o in $objects do
				( 
				
				Allascii = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 _" 
				--bbb = #("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9")
				objName = o.name
				NewName = ""
				for i = 1 to objName.count do
					(	
					if (findstring Allascii objName[i]) != undefined do append NewName objName[i]
					)
				if (substring NewName 1 4) == "bone" do 
					(
					NewName = NewName + objid as string
					objid = objid + 1
					)
				o.name = NewName
				--print newname
				)
			)
			catch()
		)
	on btn_FBXOutput pressed do
		(
		
		try
			(
			/* 20170515 修改 将是否继承max文件名勾选项 改为单独的手动导出按钮
			--定义一个导出标记 标记的状态决定是否执行导出
			OutPutMark = true
			--先定义两个变量		
			--SelObj = #()
			FBXFile = maxFilePath + (trimRight maxfilename ".max")+".fbx"	
			--20160203 改为强制在max文件之下建立fbx目录	
			--20170506 fbx文件目变更为 依据身体模型名字的进行设置 并且添加是否继承max名字的标记 传入到导出函数里
			--if not doesFileExist (maxFilePath + "fbx") do makeDir (maxFilePath + "fbx\\")
			
			--20160913 添加直接导出FBX文件名是否继承max的选项
			if chk_AutoFbxName.checked then
				(
				--调用Fbx文件名判断函数
				--FBXFile = GetFbxNameFormMax()
				--if doesFileExist FBXFile do
				--	(
				--	if queryBox (FBXFile + "\n\n\r该文件已存在，是否覆盖？") then
				--		OutPutMark = true
				--		else 
				--		OutPutMark = false
				--	)
				FBXFile = maxFilePath
				IsKeepMaxName = true
				)
				else 
				(
				if (FBXFile = getSaveFileName caption:"Export fbx File" types:"Autodesk(*.FBX)|*.fbx|" filename:(maxFilePath )) != undefined then
					(
					IsKeepMaxName = false	
					OutPutMark = true
					)
					else OutPutMark = false
				)
			*/
			FBXFile = maxFilePath + (trimRight maxfilename ".max")+".fbx"
			IsKeepMaxName = true
			fnOutPutFbx IsKeepMaxName FBXFile--调用导出fbx函数
			ShellLaunch "explorer.exe" (getFilenamePath FBXFile)
			)
			catch()
		
		)
	on btn_FBXManualOutput pressed do
		(
			--OutPutMark = true
			--FBXFile = getSaveFileName caption:"Export fbx File" types:"Autodesk(*.FBX)|*.fbx|" filename:(maxFilePath + GetFbxNameFormMax())

			IsKeepMaxName = false
			if (FBXFile = getSaveFileName caption:"Export fbx File" types:"Autodesk(*.FBX)|*.fbx|" filename:(maxFilePath + GetFbxNameFormMax())) != undefined do
				(
				IsKeepMaxName = false	
				fnOutPutFbx IsKeepMaxName FBXFile--调用导出fbx函数
				ShellLaunch "explorer.exe" (getFilenamePath FBXFile)
				)
/*
		if OutPutMark do 
			(
			fnOutPutFbx IsKeepMaxName FBXFile--调用导出fbx函数
			ShellLaunch "explorer.exe" (getFilenamePath FBXFile)
			)
	*/
		)
	on btn_FBXBatchOutput pressed do
		(
		IsKeepMaxName = true --自动导出标记
		--20160725 添加对子目录之下的所有文件处理
		MaxFiles = #()
		--20160727 先拾取当前目录之下的max文件
		MaxFiles += getFiles (maxfilePath +"\\*.max")
		if chk_SubFolders.checked do
			(
			--20160727 更改文件收集算法 把目录循环嵌套收集 和max文件收集分为两个独立的步骤 先收集目录 再根据目录收集文件 逻辑更简单明了
			AllSubPath = GetAllSubPath maxfilePath
			--20160727 循环拾取子目录数组里的所有max
			for dir in AllSubPath do MaxFiles += getFiles (dir +"\\*.max")
			)
			
		BatchInfo = "将对 “" + maxfilePath + "” 之下的  " + MaxFiles.count as string + "  个MAX文件进行批量导出操作，是否开始？"
		if queryBox BatchInfo do --跳出提示框 判断是否进行批量处理
			(
			try
				(
				--取得当前文件同目录下的max文件
				--MaxFiles = getFiles (maxfilePath +"*.max")
				disableSceneRedraw()
				--对单个文件进行循环处理
				for i = 1 to MaxFiles.count do
					(
					--FbxExporterSetParam "Animation" true
					OutPutAnimation = true
					loadMaxFile MaxFiles[i] useFileUnits:true quiet:true
					--调用Fbx文件名判断函数
					FBXFile = GetFbxNameFormMax()
					--FBXFile = maxFilePath + "fbx\\" + (getFilenameFile maxfilename)+".fbx"
					fnOutPutFbx IsKeepMaxName FBXFile--调用导出fbx函数
					)
				--最后打开最初始的max文件
				loadMaxFile MaxFiles[1] useFileUnits:true quiet:true
				enableSceneRedraw()
				redrawViews()
				FBXPath = maxFilePath
				ShellLaunch "explorer.exe" (getFilenamePath FBXPath)
				--resetmaxfile #noprompt	
				)
				catch()
			enableSceneRedraw()
			redrawViews()
			)
	)
	on btn_ExportRule pressed do
	(
		--20160913 添加导出规则说明
		messagebox "FBX文件批量导出规则：\n\n\r一.参与导出的 max 文件：\n\r      为当前打开的 max 文件目录下的所有文件，如有勾选 \"包含子目录\" 勾选项，则导出当前位置之下的子目录里所有的 max 文件。\n\n\r二. 参与导出的MAX物体：\n\n\r      1.导出所有不隐藏的物体，（特别注意：在窗口右侧的 Hide by Category 栏里，勾选不可见的类型，不属于隐藏，这部分物体依旧会参与导出）\n\n\r       2.所有的 dummy 物体，无论隐藏与否，都强制不能导出。\n\n\r三. FBX文件位置：\n\r       MAX文件所在位置自动创建一个 fbx 文件夹，该文件夹即为fbx文件导出位置。\n\n\r四. FBX文件名：\n\r      fbx文件名与对应的MAX文件名相同。\n\n\r五. 导出类型判断：\n\r      通过MAX文件名来判断，MAX文件扩展名前四个字符为 skin或者Skin或者SKIN 的时候，判断为这是一个模型文件，会同时导出骨骼和模型。\n\n\r      文件名最后四个字符不为以上三种情况的时候，判断为这是一个动作文件，只导出骨骼，不导出模型，以上两种情况骨骼和插槽均会自动Bone On\n\n\r      如有特殊情况，每个文件都需要骨骼和模型同时一起导出的，可以勾选面板上的 \"强制导模型\" 勾选项。"
	
	)
)














--createDialog FBXTools















