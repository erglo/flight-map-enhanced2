if ( GetLocale() ~= "koKR" ) then
	return;
end
local ns = select( 2, ... );
ns.L = --@localization(locale="koKR", format="lua_table", handle-unlocalized="english")@

