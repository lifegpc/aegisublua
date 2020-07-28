-- GPL许可证 许可
-- 作者：lifegpc
-- 代码库 https://github.com/lifegpc/aesigublua
local tr = aegisub.gettext

script_name = tr"重复内容"
script_description = tr"重复内容，每隔n秒出现m次"
script_author = "lifegpc"
script_version = "1"

config = {
    {class="label",label="重复次数：",x=0,y=0},
    {class="intedit",value=99,x=1,y=0,min=1,name="cf"},
    {class="label",label="间隔时间（毫秒）：",x=0,y=1},
    {class="intedit",value=1000,x=1,y=1,min=0,name="ct"}
}

function cf(subs,sels,sel)
    btn, result = aegisub.dialog.display(config)
    local cf=result["cf"]
    local ct=result["ct"]
    local ml=subs[sel]
    local et=ml.end_time
    local cx=et-ml.start_time
    now=sel+1
    for i=1,cf do
        local line=ml
        et=et+ct
        line.start_time=et
        et=et+cx
        line.end_time=et
        subs.insert(now,line)
        now=now+1
    end
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, cf)
