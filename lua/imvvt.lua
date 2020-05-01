-- GPL许可证 许可
-- 作者：lifegpc
-- 代码库 https://github.com/lifegpc/aesigublua
local tr = aegisub.gettext
clipboard = require 'aegisub.clipboard'

script_name = tr"导入WEBVTT（简易）"
script_description = tr"导入WEBVTT格式\n只支持简易的导入，即不对内容进行详细的处理"
script_author = "lifegpc"
script_version = "1"

function imvtt(subs,sel,acl)
    local fn=aegisub.dialog.open('打开WEBVTT','','',"WEBVTT(*.vtt)|*.vtt|所有文件(*)|*",false)
    local f
    if fn == nli then
        return
    else
        f=io.open(fn,'r')
        if f == nli then
            aegisub.log(0,'无法写入文件')
            return
        end
    end
    local t=f:read()
    local a={}
    while t ~= nli do
        table.insert(a,t)
        t=f:read()
    end
    f:close()
    if a[1] ~= "WEBVTT" then
        aegisub.log(0,'貌似不是WEBVTT文件')
        return
    end
    local b={}
    local c={}
    local d=nli
    local q={3600000,60000,1000,1}
    local h
    for _,v in pairs(a) do
        h=true
        for w in v:gmatch("[0-9][0-9]:[0-5][0-9]:[0-5][0-9].[0-9][0-9][0-9] %-%-> [0-9][0-9]:[0-5][0-9]:[0-5][0-9].[0-9][0-9][0-9]") do
            h=false
            local i=1
            local x=0
            local z
            for y in w:gmatch("[0-9][0-9][0-9]?") do
                if i==5 then
                    if b[x]~=nli then
                        z=b[x]
                    else
                        z={}
                        b[x]=z
                    end
                    i=1
                    x=0
                end
                x=x+y*q[i]
                i=i+1
            end
            if z[x]~=nli then
                d=z[x]
            else
                d={}
                z[x]=d
            end
        end
        if d~=nli and h and v~="" then
            table.insert(d,v)
        end
    end
    local n
    if acl~=nli then
        n=acl
    else
        n=sel[#sel]
    end
    local m=subs[n]
    local i=1
    for s,k in pairs(b) do
        for e,l in pairs(k) do
            for _,v in pairs(l) do
                local o=m
                if i==1 and m.text=="" then
                    o.text=v
                    o.start_time=s
                    o.end_time=e
                    subs[n]=o
                    n=n+1
                    i=i+1
                else
                    if i==1 then
                        n=n+1
                    end
                    o.text=v
                    o.start_time=s
                    o.end_time=e
                    subs.insert(n,o)
                    n=n+1
                    i=i+1
                end
            end
        end
    end
    aegisub.set_undo_point(tr"导入WEBVTT（简易）")
end

aegisub.register_macro(script_name, script_description, imvtt)
