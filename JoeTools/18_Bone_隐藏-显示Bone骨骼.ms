--if Bn_All == undefined then
--(
    try
    (--and i.ishidden == false
        Bn_All = for i in objects where (classof i== BoneGeometry) collect i.ishidden = (not i.ishidden)
        --hide Bn_All
    )catch()
--)
/*
else
(
    try
    (
        for i in Bn_All do (i.ishidden = false);Bn_All = undefined
    )
    catch()
)
