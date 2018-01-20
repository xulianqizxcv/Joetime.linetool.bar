-- Unist script by Joe --

rollout Uninst_JiRt "Unist" width:210 height:60
(
    --usermacros = (symbolicPaths.getPathValue "$userMacros")+"\\"
    --userscripts = (symbolicPaths.getPathValue "$userScripts")+"\\"
    local scripts = symbolicPaths.getPathValue "$scripts"+"\\"
    local JiRt_deldir = scripts+"JiRt_Scripts"

    label lb01 "是否卸载原版JiRts_Anim_Tools_Bar"  pos:[16,5] width:200 height:13
    button uninst "卸载" pos:[45,25] width:120 height:30

    fn getFilesRecursive root pattern =
    (
        dir_array = GetDirectories (root+"/*")
            for d in dir_array do
                join dir_array (GetDirectories (d+"/*"))
            my_files = #()
            for f in dir_array do
                join my_files (getFiles (f + pattern))
            my_files
    )

    fn del_JiRts =
    (
        jiRts_file = getFilesRecursive scripts "JiRts*" --del Max root path
        for i in jiRts_file do deleteFile i

        commandd = "RD /S /Q \""+JiRt_deldir+"\""
		HiddenDOSCommand commandd startpath:".\\"

    )

    on uninst pressed do
    (
        if queryBox "确定卸载JiRts_Anim_Tools_Bar原版 ? " title: "Unist!" do
        (
            del_JiRts()

        )
    )

)
createDialog Uninst_JiRt style:#(#style_toolwindow, #style_border, #style_sysmenu)