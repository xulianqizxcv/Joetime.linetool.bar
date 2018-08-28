rollout rename_File "重命名文件"
(
    group "目标" (
        edittext form_path "路径"
        checkbox check_fbx ".FBX" across:2
        checkbox check_max ".MAX" offset:[-120,0] checked:true
    )
    group "" (
        checkbox chk_f_text across:2
        edittext f_str "前缀" fieldWidth:280 labelOnTop:false offset:[-140,0]

        checkbox chk_f_text_01 across:3 --前端字符操作
        radiobuttons sele_f_b_text_00 labels:#("保留前","删除前")  columns:2 offset:[-90,0]
        spinner delPreSpin_f  range:[0,20,0] type:#integer offset:[-90,0]

        label lab_01 ""
        checkbox chk_b_text across:2
        edittext b_str "后缀" fieldWidth:280 labelOnTop:false offset:[-140,0]

        /*
        checkbox chk_b_text_01 across:3
        radiobuttons sele_f_b_text_01 labels:#("保留后","删除后")  columns:2 offset:[-90,0]
        spinner delPreSpin_b  range:[0,20,0] type:#integer offset:[-90,0]
        */
    )
    button btn_01 "OK " width:338 height:26--across:2
    --button btn_02 "Ok MAX"
    fn find_file type =     -- 找到 源 路径 文件夹里面的FBX - max 文件，忽略次级目录
    (
        --local from_path = pathSource + @"\"
        if form_path.text != "" then
        (
            local from_path = form_path.text + @"\"
            if type == 1 do (tem_file_fbx = getFiles (from_path + "*"+".FBX");return tem_file_fbx )
            if type == 2 do (tem_file_max = getFiles (from_path + "*"+".max");return tem_file_max )
        )
        else(return undefined)

    )
    fn new_name_file tem_path =
    (
        file_name = getFilenameFile tem_path
        file_path = getFilenamePath tem_path
        file_type = getFilenameType tem_path

        new_name = file_name
        if chk_f_text_01.state == true do  --前端字符操作
        (
            if sele_f_b_text_00.state == 1 then  --保留前几个字符
            (
                new_name = (substring file_name 1 delPreSpin_f.value)
            )
            else
            (   --删除前几个字符
                local start_t = delPreSpin_f.value + 1
                local end_t = file_name.count
                new_name = (substring file_name start_t end_t)
            )
        )

        if chk_f_text.state == true do --添加前缀名
        (
            if f_str.text != "" do ( new_name = f_str.text + new_name )
        )

        if chk_b_text.state == true do --添加后缀名
        (
            if b_str.text != "" do (new_name += b_str.text)
        )
        --new_name = (substring file_name 1 3) + "_o" --取前3个字符
        --new_name = file_name + "_20180823_熊建桥"
        if new_name != file_name do
        (try (
            new_path = file_path + new_name + file_type
            renameFile tem_path new_path
            )catch("OK")
        )
    )

    on btn_01 pressed do
    (
        if check_fbx.state == true do --处理FBX文件
        (
            local a = find_file 1
            if a != undefined do
            (
                for i in a do
                (
                    new_name_file i
                )
            )
        )
        if check_fbx.state == true do --处理MAX文件
        (
            local a = find_file 2
            if a != undefined do
            (
                for i in a do
                (
                    new_name_file i
                )
            )
        )
    )

)
createDialog rename_File 370 220

