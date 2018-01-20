
--usermacros = (symbolicPaths.getPathValue "$userMacros")+"\\"
--userscripts = (symbolicPaths.getPathValue "$userScripts")+"\\"
scripts+ = symbolicPaths.getPathValue "$scripts"+"\\"

JiRt_deldir = scripts+"JiRt_Scripts"


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
    for i in jiRts_file deleteFile i

    command = "RD /S /Q \""+JiRt_deldir+"\""
    HiddenDOSCommand command startpath:".\\"
    ---
)
--删除文件夹
dirpath = "E:\usermacros"
command = "RD /S /Q \""+dirPath+"\""
HiddenDOSCommand command startpath:".\\"
--

--删除文件
filepath = "e:\11112.txt"
deleteFile filePath



command = "DEL \""+filePath+"\" /Q /F"

HiddenDOSCommand command startpath:".\\"
--


--HiddenDOSCommand "del hiddencmdout.tmp.txt" donotwait:true startpath:"e:\\"