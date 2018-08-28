rollout delete_cust_att "删除自定义属性"
(
    group "" (
        button btn_01 "仅模型"
        label abl_01 "作用:"
        label abl_001 "和创建一个BOX然后Attach合并类似"
        label abl_010 "去掉模型上的各种从其"
        label abl_011 "他软件导入带来的无效属性. \n "
    )
    group "" (

        button btn_02 "所有"
        label abl_02 "场景中所有对象上,包括材质"
       label abl_03 "可以除删的自定义属性. "
       label abl_04 "只建议在刚导入FBX时使用. \r\n"
    )
    on btn_01 pressed do
    (
        ab =  objects as array
        --custAttributes.getSceneDefs()
        for i in ab do
        (
            if (classof i  == Editable_Poly) or (classof i  == Editable_mesh) do
            (
                i.DeleteIsoMapVerts()
                att_count = custAttributes.count i BaseObject:true
                if att_count != 0 do
                (
                    for p= 1 to att_count do
                    (
                        custAttributes.delete i p
                    )
                )
            )
        )
    )
    on btn_02 pressed do
    (
        ab = custAttributes.getSceneDefs()
        for def in ab do
        (
            local instances = custAttributes.getDefInstances def;
            for i in instances \
               where (owner = custAttributes.getOwner i) != undefined do
            (
            --Loop through all ca sets on the owner object and find one that
            --matches the one we want to remove. Delete has to be done using
            --the index, since it has to be made unique first.
                for caIndex = 1 to (custAttributes.count owner) do
                (
                   --if (((custAttributes.get owner caIndex).name as name) == defName) do
                   --(
                      --Make CA set unique first, otherwise delete won't work..
                      --custAttributes.makeUnique owner caIndex;
                      custAttributes.delete owner caIndex;
                   --)
                )
            )

         --Remove the nested layer custom attributes definition from the scene.
            try(
                custAttributes.deleteDef def;
            )
            catch ()
        )
    )
)
createDialog delete_cust_att 200 250