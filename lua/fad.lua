-- GPL许可证 许可
-- 作者：lifegpc
-- 代码库 https://github.com/lifegpc/aesigublua
local tr = aegisub.gettext

script_name = tr"批量淡入淡出效果"
script_description = tr"批量淡入淡出效果"
script_author = "lifegpc"
script_version = "1"

config = {
    {class="label",x=0,y=0,label="淡入持续时间（毫秒）："},
    {class="intedit",x=1,y=0,value=500,min=1,name="cx1"},
    {class="label",x=0,y=1,label="淡出持续时间（毫秒）："},
    {class="intedit",x=1,y=1,value=500,min=1,name="cx2"},
    {class="label",x=0,y=2,label="持续时间短于n毫秒的字幕不进行淡入/淡出处理："},
    {class="intedit",x=1,y=2,value=2000,min=0,name="min"},
    {class="label",x=0,y=3,label="高级选项："},
    {class="checkbox",x=0,y=4,label="启用高级选项",value=false,name="gj"},
    {class="label",x=0,y=5,width=2,label="Alpha的有效值为0-255的整数，0完全可见，255完全隐藏。"},
    {class="label",x=0,y=6,label="淡入前Alpha值："},
    {class="intedit",x=1,y=6,value=255,max=255,min=0,name="a1"},
    {class="label",x=0,y=7,label="淡入后淡出前Alpha值："},
    {class="intedit",x=1,y=7,value=0,max=255,min=0,name="a2"},
    {class="label",x=0,y=8,label="淡出后Alpha值："},
    {class="intedit",x=1,y=8,value=255,max=255,min=0,name="a3"},
    {class="label",x=0,y=9,label="淡入前持续时间（毫秒）："},
    {class="intedit",x=1,y=9,value=0,min=0,name="t1"},
    {class="label",x=0,y=10,label="淡出后持续时间（毫秒）："},
    {class="intedit",x=1,y=10,value=0,min=0,name="t2"},
    {class="label",x=0,y=12,width=2,label="注：若实现淡入淡出效果必须的时间长于字幕持续时间，将不进行处理"},
    {class="checkbox",x=0,y=13,label="记住设置",value=false,name="gz"}
}
gz=false --是否记住设置
config2=nli --记住的设置内容
decon={ --默认设置
    cx1=config[2].value,
    cx2=config[4].value,
    min=config[6].value,
    gj=config[8].value,
    a1=config[11].value,
    a2=config[13].value,
    a3=config[15].value,
    t1=config[17].value,
    t2=config[19].value,
    gz=config[21].value
}

function fad(subs,sels,sel)
    local con=nli
    if gz and config2~=nli then
        con=getset(config2)
    else 
        con=getset(decon)
    end
    btn, re = aegisub.dialog.display(con)
    if btn==false then --用户取消，退出
        return 0
    end
    local cx1=re["cx1"]
    local cx2=re["cx2"]
    local min=re["min"]
    local gj=re["gj"]
    local a1=re["a1"]
    local a2=re["a2"]
    local a3=re["a3"]
    local t1=re["t1"]
    local t2=re["t2"]
    gz=re["gz"]
    if gz then
        config2=re
    end
    for _,i in pairs(sels) do
        local line=subs[i]
        local t=line.end_time-line.start_time
        if t>=min then
            if gj then
                local nt=cx1+cx2+t1+t2 --需要的最短时间
                if nt<=t then
                    line.text="{\\fade("..a1..","..a2..","..a3..","..t1..","..t1+cx1..","..t-t2-cx2..","..t-t2..")}"..line.text
                    subs[i]=line
                end
            else
                local nt=cx1+cx2
                if nt<=t then
                    line.text="{\\fad("..cx1..","..cx2..")}"..line.text
                    subs[i]=line
                end
            end
        end
    end
    aegisub.set_undo_point(script_name)
end

function getset(config2) --读取设置
    local con=config
    con[2].value=config2["cx1"]
    con[4].value=config2["cx2"]
    con[6].value=config2["min"]
    con[8].value=config2["gj"]
    con[11].value=config2["a1"]
    con[13].value=config2["a2"]
    con[15].value=config2["a3"]
    con[17].value=config2["t1"]
    con[19].value=config2["t2"]
    con[21].value=config2["gz"]
    return con
end

aegisub.register_macro(script_name, script_description, fad)
