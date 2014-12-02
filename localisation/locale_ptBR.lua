if ( GetLocale() ~= "ptBR" ) then
	return;
end
local ns = select( 2, ... );
ns.L = --@localization(locale="ptBR", format="lua_table", handle-unlocalized="english")@

--@debug@ 
{}
--@end-debug@