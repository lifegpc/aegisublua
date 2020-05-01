-- GPL许可证 许可
-- 作者：lifegpc
-- 代码库 https://github.com/lifegpc/aesigublua
local tr = aegisub.gettext
clipboard = require 'aegisub.clipboard'

script_name = tr"导出WEBVTT（简易）"
script_description = tr"导出WEBVTT格式\n只支持简易的导出，即只导出文本内容，不导出注释、样式等内容。\n仅导出选中部分\n\\n将会被忽略，\\N会转换成换行，脚本标签全部忽略"
script_author = "lifegpc"
script_version = "1"

function etvtt(subs,sel)
    local fn=aegisub.dialog.save('保存WEBVTT','','',"WEBVTT(*.vtt)|*.vtt|所有文件(*)|*",false)
    local f
    if fn == nli then
        return
    else
        f=io.open(fn,'w+')
        if f == nli then
            aegisub.log(0,'无法写入文件')
            return
        end
    end
    f:write("WEBVTT\n")
    local t={}
    for _,i in pairs(sel) do
        local k=subs[i]
        if ish(t,k.start_time) then
            table.insert(t,k.start_time)
        end
        if ish(t,k.end_time) then
            table.insert(t,k.end_time)
        end
    end
    local l=#t
    local i=1
    while i<=l do--升序排序
        local j=1
        while j<=l-i do
            if t[j]>t[j+1] then
                local e=t[j]
                t[j]=t[j+1]
                t[j+1]=e
            end
            j=j+1
        end
        i=i+1
    end
    local s={}
    for _,i in pairs(sel) do
        local k=subs[i]
        local st=k.start_time
        local se=k.end_time
        k=k.text
        local ke=st
        if s[ke] == nli then
            s[ke]={}
        end
        table.insert(s[ke],k)
        local n=findn(t,ke)
        while n ~= nli and n < se do
            if s[n] == nli then
                s[n]={}
            end
            table.insert(s[n],k)
            ke=n
            n=findn(t,ke)
        end
    end
    for _,i in pairs(t) do
        if s[i] ~= nli then
            local et=i
            if _ ~= #t then
                et=t[_+1]
            end
            f:write("\n"..gett(i).." --> "..gett(et).."\n")
            for _1,k in pairs(s[i]) do
                f:write(cl(k).."\n")
            end
        end
    end
    f:close()
end
--判断是否存在相应的值 true 不存在 false 存在
function ish(t,k)
    for i,v in pairs(t) do
        if k==v then
            return false
        end
    end
    return true
end
-- 查找下一个键值
function findn(t,k)
    local i
    for _,v in ipairs(t) do
        i=_
        if k==v then
            break
        end
    end
    if i~=#t then
        return t[i+1]
    end
    return nli
end
--获取格式化的时间
function gett(t)
    local h=math.modf(t/3600000)
    local m=math.modf(math.fmod(t,3600000)/60000)
    local z=math.modf(math.fmod(t,60000)/1000)
    local ms=math.fmod(t,1000)
    local s=""
    if h>9 then
        s=s..h
    else
        s=s.."0"..h
    end
    s=s..":"
    if m>9 then
        s=s..m
    else
        s=s.."0"..m
    end
    s=s..":"
    if z>9 then
        s=s..z
    else
        s=s.."0"..z
    end
    s=s.."."
    if ms>99 then
        s=s..ms
    elseif ms>9 then
        s=s.."0"..ms
    else
        s=s.."00"..ms
    end
    return s
end
--处理文本
function cl(text)
    text=text:gsub("{[^}]*}","")
    text=text:gsub("\\n","")
    text=text:gsub("\\N","\n")
    return text
end

aegisub.register_macro(script_name, script_description, etvtt)
