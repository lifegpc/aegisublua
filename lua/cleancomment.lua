-- GPL许可证 许可
-- 作者：lifegpc
-- 代码库 https://github.com/lifegpc/aesigublua
local tr = aegisub.gettext

script_name = tr"清理评论行"
script_description = tr"清理评论行"
script_author = "lifegpc"
script_version = "1"

function clean(subs)
    local l=#subs
    local i=1
    while i<=l do
        local line=subs[i]
        if line.class=="dialogue" then
            if line.comment then
                subs.delete(i)
                i=i-1
                l=l-1
            end
        end
        i=i+1
    end
end

function  clean_export(subs,config)
    clean(subs)
end

function clean_auto(subs,sels,sel)
    clean(subs)
    aegisub.set_undo_point(script_name)
end

aegisub.register_filter(script_name,script_description,1,clean_export)
aegisub.register_macro(script_name,script_description,clean_auto)
