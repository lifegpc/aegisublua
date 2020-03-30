-- GPL许可证 许可
-- 作者：lifegpc
-- 代码库 https://github.com/lifegpc/aesigublua
local tr = aegisub.gettext
clipboard = require 'aegisub.clipboard'

tip="\n（如果选中行内容为空，该行将被覆盖，反之则插入至下一行）\n最小的时间将会被设为0以适应插入一部分歌词的情况"
script_name = tr"导入LRC"
script_description = tr"导入LRC歌词，支持从剪贴板/文件中导入。"..tip
script_author = "lifegpc"
script_version = "1"

function cl(subs,sel,text)
    local lines={}
    for s in text:gmatch("[^\r\n]+") do
        table.insert(lines,s)
    end
    local tq={60000,1000,10} --对应的毫秒数
    local r={}
    local ll=0
    for i,line in ipairs(lines) do
        local i3=1
        local ta={}
        local str=line
        local has=false
        for s in line:gmatch("%[[0-9][0-9]:[0-5][0-9].[0-9][0-9]%]") do
            has=true
            local i2=1
            local t=0
            for s2 in s:gmatch("[0-9][0-9]") do
                t=t+s2*tq[i2]
                i2=i2+1
            end
            ta[i3]=t
            i3=i3+1
            str=str:sub(11)
        end
        if has==true then
            for i,v in ipairs(ta) do
                if r[v]==nli then
                    r[v]={}
                end
                ll=ll+1
                table.insert(r[v],str)
            end
        end
    end
    local re={}
    for i,_ in pairs(r) do
        table.insert(re,i)
    end
    local l=#re
    local i=1
    while i<=l do--进行升序排序
        local j=1
        while j<=l-i do
            if re[j] > re[j+1] then
                local t=re[j]
                re[j]=re[j+1]
                re[j+1]=t
            end
            j=j+1
        end
        i=i+1
    end
    if l>=1 then
        local t=re[1]
        for k,v in pairs(re) do
            re[k]=v-t
        end
        local temp={}
        for k,v in pairs(r) do
            temp[k-t]=v
        end
        r=temp
    end
    local now=sel[#sel]
    local ii=1
    local ml=subs[now]
    local ofs=0
    if ml.text=="" then
        ofs=ml.start_time
    else
        ofs=ml.end_time
    end
    local i=1
    while i<=l do
        for _,v in pairs(r[re[i]]) do
            local line=ml
            if ii==1 and ml.text=="" then
                line.text=v
                if i<l then
                    line.end_time=re[i+1]+ofs-10
                end
                subs[now]=line
                now=now+1
                ii=ii+1
            else
                if ii==1 then
                    now=now+1
                end
                line.start_time=re[i]+ofs
                if i<l then
                    line.end_time=re[i+1]+ofs-10
                else
                    line.end_time=re[i]+ofs+2000
                end
                line.text=v
                subs.insert(now,line)
                now=now+1
                ii=ii+1
            end
        end
        i=i+1
    end
end

function iflrc(subs,sel)
    cl(subs,sel,clipboard.get())
    aegisub.set_undo_point(tr"从剪贴板导入LRC")
end

function iflrc2(subs,sel)
    local fn=aegisub.dialog.open("打开LRC","","","歌词文件(*.lrc)|*.lrc|所有文件(*)|*",false,true)
    if fn~=nli then
        local f=io.open(fn,"r")
        if f~=nli then
            local text=f:read("*a")
            if text ~= nli then
                cl(subs,sel,text)
                aegisub.set_undo_point(tr"从文件导入LRC")
            end
        end
    end
end

aegisub.register_macro(tr"从剪贴板导入LRC", tr"从剪贴板导入LRC。"..tip, iflrc)
aegisub.register_macro(tr"从文件导入LRC", tr"从文件导入LRC。"..tip, iflrc2)
