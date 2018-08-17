--showFrozenInGray = off
if obj_mesh_b == undefined then
(
    obj_mesh_b = #()
    local obj_mesh_a = objects as array
    for i in obj_mesh_a where (classOf i == PolyMeshObject ) do
    (
        i.showFrozenInGray = off
        freeze i
        append obj_mesh_b i
    )
    print "冻结模型"
)
else
(
    try (for i in obj_mesh_b do (unfreeze i ))catch()
    obj_mesh_b = undefined
    print "已解冻"
)