-- GPL许可证 许可
-- 作者：lifegpc
-- 代码库 https://github.com/lifegpc/aesigublua
local tr = aegisub.gettext

script_name = tr"合并歌词"
script_description = tr"合并歌词"
script_author = "lifegpc"
script_version = "1"

function lrcformat(subs, sel)
    local last=false
    local lt=-1
    local id
    for _,i in ipairs(sel) do
        if subs[i].start_time == subs[i].end_time then
            last=true
            lt=subs[i].start_time
            id=i
        elseif subs[i].start_time == (lt+10) and last == true then
            local line=subs[i]
            line.start_time=lt
            subs[i]=line
            line=subs[id]
            line.end_time=subs[i].end_time
            subs[id]=line
            last=false
        end
    end
    aegisub.set_undo_point(tr"合并歌词")
end

aegisub.register_macro(script_name, script_description, lrcformat)
