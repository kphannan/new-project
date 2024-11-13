
#/SECTION_REPOSITORIES/ {print ":::" $1 ":::"}

#/SECTION_APPLY/ {print applyValue }

#/SECTION_VERSIONTAGS/ {print versionValue }
# r = sub( "\/\/ SECTION_PLUGIN", pluginValue ) { print "===" r }
# /\/\/ SECTION_PLUGIN/ {sub( "\/\/ SECTION_PLUGIN", pluginValue, r ); print r; print pluginValue }
/\/\/ SECTION_PLUGIN/ {print pluginValue }

{print}
