if ( GetLocale() ~= "esMX" ) then
	return;
end
local ns = select( 2, ... );
ns.L = --@localization(locale="esMX", format="lua_table", handle-unlocalized="english")@

--@debug@ 
{}
--@end-debug@