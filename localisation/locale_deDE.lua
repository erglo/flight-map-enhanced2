if ( GetLocale() ~= "deDE" ) then
	return;
end
local ns = select( 2, ... );
ns.L = --@localization(locale="deDE", format="lua_table", handle-unlocalized="english")@

--@debug@ 
{}
--@end-debug@

