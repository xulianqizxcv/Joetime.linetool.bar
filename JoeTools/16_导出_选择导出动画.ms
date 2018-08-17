try (
        tem_path = maxfilepath + (getFilenameFile maxfilename) + ".FBX"
        export_path = getSaveFileName caption:"选择导出动画 FBX :" filename:tem_path types:"FBX(*.FBX)|"
        if export_path!= undefined do
        (
            FbxExporterSetParam "Animation"  true --导出FBX设置
            FbxExporterSetParam "BakeAnimation"  true
            exportFile export_path #noPrompt selectedOnly:true using:#FBXEXP

            print "!!export OK"
        )
)catch()