-- GPL许可证 许可
-- 作者：lifegpc
-- 代码库 https://github.com/lifegpc/aesigublua
local tr = aegisub.gettext

script_name = tr"同时间字幕翻转"
script_description = tr"同时间字幕翻转"
script_author = "lifegpc"
script_version = "1"

function fz(subs, sel)
    local v={}
    for i2,i in ipairs(sel) do
        local s={}
        s.i=i
        s.s=subs[i].start_time
        s.e=subs[i].end_time
        v[i2]=s
    end
    local d={}
    for i,s in ipairs(v) do
        if d[s.s] == nli then
            d[s.s]={}
        end
        if d[s.s][s.e] == nli then
            d[s.s][s.e]={}
        end
        table.insert(d[s.s][s.e],s.i)
    end
    for i,_ in pairs(d) do
        for j,s in pairs(d[i]) do
            local l=#s
            local i1=1
            local h=math.modf(l/2);
            while i1 <= h do
                local temp=subs[s[i1]]
                subs[s[i1]]=subs[s[l-i1+1]]
                subs[s[l-i1+1]]=temp
                i1=i1+1
            end
        end
    end
    aegisub.set_undo_point(tr"同时间字幕翻转")
end

aegisub.register_macro(script_name, script_description, fz)
