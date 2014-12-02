if ( GetLocale() ~= "zhCN" ) then
	return;
end
local ns = select( 2, ... );
ns.L = --@localization(locale="zhCN", format="lua_table", handle-unlocalized="english")@

--@debug@ 
{}
--@end-debug@