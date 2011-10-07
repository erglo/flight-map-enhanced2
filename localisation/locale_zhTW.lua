if ( GetLocale() ~= "zhTW" ) then
	return;
end
local ns = select( 2, ... );
ns.L = --@localization(locale="zhTW", format="lua_table", handle-unlocalized="english")@

