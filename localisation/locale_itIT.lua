if ( GetLocale() ~= "itIT" ) then
	return;
end
local ns = select( 2, ... );
ns.L = --@localization(locale="itIT", format="lua_table", handle-unlocalized="english")@

--@debug@ 
{}
--@end-debug@
