
-----
# Realtime Spring V1.5.3

## 2018/08/03

![](https://github.com/4698to/Joetime.linetool.bar/blob/master/Realtime_Spring_V1.5/v_1.53.png)

新增手动计算权重混合。

---
# Realtime Spring V1.5
-------------

![](https://github.com/4698to/Joetime.linetool.bar/blob/master/Realtime_Spring_V1.5/Realtime_Spring_V1.5_01.png)

2018/3/6

简单修改UI.

每次执行 Build Chain  都会另新建 Group_Spr；Group_Spr_N；Group_Spr_Upnode 选择集,以方便选择.

修复 骨骼名中有 (mirrored) 字符时，使用 Select按钮出错的问题。 这种名字是骨骼镜像之后没有重新命名。

                    try
                    (
                        drv = lv.Items.item[i].SubItems.Item[3].Text
                        drv = execute( "$" + drv)
                        if drv.isselected == true then lv.Items.item[i].Selected = true
                        else lv.Items.item[i].Selected = false
                    )
                    catch(print "因骨骼名中有(mirrored)字符，所以此功能无法使用")

----------------

------------------------------
如遇BUG 还请联系，方便我及时修改
联系 99U：199505  E-mail:738746223@qq.com






