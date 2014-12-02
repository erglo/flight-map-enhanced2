if ( GetLocale() ~= "ruRU" ) then
	return;
end
local ns = select( 2, ... );
ns.L = --@localization(locale="ruRU", format="lua_table", handle-unlocalized="english")@

--@debug@ 
{}
--@end-debug@