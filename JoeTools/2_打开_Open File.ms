--getMAXOpenFileName
try (
    new_open = getMAXOpenFileName filename:(maxfilepath+maxfilename)
    if new_open != undefined do
    (
        loadMaxFile new_open
    )
    )
catch()
