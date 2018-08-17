if Bip_All == undefined then
(
    try
    (--and i.ishidden == false
        Bip_All = for i in objects where (classof i== Biped_Object and i.ishidden == false) collect i
        hide Bip_All
    )catch()
)
else
(
    try
    (
        for i in Bip_All do (i.ishidden = false);Bip_All = undefined
    )
    catch()
)
