if Bn_All == undefined then
(
    try
    (--and i.ishidden == false
        Bn_All = for i in objects where (classof i== BoneGeometry and i.ishidden == false) collect i
        hide Bn_All
    )catch()
)
else
(
    try
    (
        for i in Bn_All do (i.ishidden = false);Bn_All = undefined
    )
    catch()
)
