if ( GetLocale() ~= "esES" ) then
	return;
end
local ns = select( 2, ... );
ns.L = --@localization(locale="esES", format="lua_table", handle-unlocalized="english")@

