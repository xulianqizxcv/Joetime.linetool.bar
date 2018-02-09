

---
# Auto Export FBX v.1
-------------
## Auto Export FBXv.1  [下载](https://github.com/4698to/Joetime.linetool.bar/blob/master/Auto%20Export%20FBX/AutoExportFBX.rar)


![](https://github.com/4698to/Joetime.linetool.bar/blob/master/Auto%20Export%20FBX/UI.png)

### 目标;保存,路径

Imp 目标文件夹，会对文件夹内的全部 .MAX文件进行处理。但是忽略这个文件夹里的文件夹。

Out 保存文件夹，保存导出的 FBX文件夹。





--------------------

### 设置
#### 帧区间标记：

正常情况，导出都是按直接打开MAX档时的时间轴长度导出动画的。还是得看你保存MAX档时，时间轴长度是否是正确的动画长度。
只需选中一个物体，最好是虚拟体，Bone 骨骼 ，BOX 什么的，Bip骨骼 CAT 没支持。

            try (

                    if classOf obj == Biped_Object then ()

                    else if classOf obj == CATBone then ()
                    else
                    (
                        if obj != undefined and obj[3][1].keys.count <= 1 then  --检查标记帧区间对象是否正常 ，
                        (
                            print j_exp.cust_file + obj.name +"没有设置标记区间帧"
                        )
                        else
                        (
                            try
                            (
                                kk = obj[3][1].keys.count--
                                --return #(obj[3][1].keys[1].time,obj[3][1].keys[kk].time)
                                s_t = (obj[3][1].keys[1].time.frame) as Integer
                                e_t = (obj[3][1].keys[kk].time.frame) as Integer
                                animationRange = interval s_t e_t
                            )catch()
                        )
                    )
                )catch()

设置帧区间标记对象的作用就是，不管你打开MAX档时的时间轴长度，而是 ！！！按这个 帧区间标记对象 的头尾帧来设置时间轴！！！

简单使用的小案例 就是动画分段导出，比如说动画总长度为 75 帧，现在需要分两段导出，00F-25F，25F-75F，你只需把这个当复制出一份，一份 帧区间标记对象 在0帧 25 帧 K上帧，另一份 在 25帧 75 帧，

#### 分段标记：



#### 导出对象：

选中你所有需要导出的然后点按钮，就可以了。这个需要根据你的FBX预设来，如果你的FBX预设是导出动画的，就只选择骨骼部分，不选模型。另外还会记录下选中对象的Bone On 属性的。

这两个按键都会在目标文件夹下新建一个导出配置，帧区间标记对象，导出对象，Bone on 属性都在 Export_config.ini 里。

按照这个 导出配置 批量导出 目标路径下的 .MAX 文件。

---------

### 预设

导出预设 ， 就是导出配置，包含导出对象，Bone On 属性 ，帧区间标记对象。

FBX Export 预设

就是MAX 导出FBX 时的选项设置，这里提供 两份。

UE_Anim.fbxexportpreset ，是导出 动画 预设。只选择骨骼 导出。

UE_MD.fbxexportpreset ，  是导出 模型 预设，选择模型和骨骼 导出。

存放路径，(我的MAX版本是2015) D:\Documents\3dsMax\FBX\3dsMax2014_X64\Presets\2015.1\export

![](https://github.com/4698to/Joetime.linetool.bar/blob/master/Auto%20Export%20FBX/FBX_export.png)



------------------------------
BUG 反馈，建议
99U : 199505
QQ : 738746223







