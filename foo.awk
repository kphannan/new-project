
BEGIN {
    #RS = ""
    #FS=""
    f=1
}

# Values of 'f'
# 1: normal processing
# 2: found 'plugins'
# 3: found 'repositories'

# Detect the 'plugins' section and insert the comment markers before, inside and after
/plugins/{f=2; print "buildscript {\n    ext {\n        //  SECTION_VERSIONTAGS\n    }\n}\n\nplugins {"; next;}
f==2 && /\}/ {print "    // SECTION_PLUGIN\n}\n\n// SECTION_APPLY\n"; f = 1; next; }
f==2 {print}

# Remove the respositories section
/repositories/ { f=3; next; }
f==3 && /\}/ { f=1; next }
f==3 {next}

f==1 {print}


/SECTION_PLUGIN/ {print pluginValue }

# Remove repositories section - they are defined in settings.gradle globally
