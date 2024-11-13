#! /bin/zsh

# rm -rf {app,.git,gradle,.gradle,.vscode,lib,build-logic,buildSrc,list,utilities}; rm gradlew gradlew.bat settings.gradle gradle.properties .gitattributes .gitignore
#  Create the basic file structure of a java project

# target java version
# target project name
# application structure 1 or 2
# new apis yes or no

basePackage='com.example.project'
projectName='projectname'
javaVersion=23

# https://docs.gradle.org/current/userguide/build_init_plugin.html
gradle init --type java-application \
    --package $basePackage \
    --project-name $projectName \
    --test-framework junit-jupiter  \
    --java-version $javaVersion \
    --dsl groovy \
    --use-defaults \
    --overwrite
#  The --split-project option does not create a fully buildable project
# $ gradle check does not build libraries in ./lib and ./utility directories
# and the main app project can not resolve those items in lib  & utility
    # --split-project \

#mkdir -p {app,lib}/src/{main,test}/java/com/example



## Perform intial git configuration and basic commits

git init
git add .
git commit -a -m'Initial commit'

git checkout -b develop

cat << EOF > .gitignore

# ===== MacOS =====
## General
.DS_Store
.AppleDouble
.LSOverride

## Icon must end with two \r
Icon

## Thumbnails
._*

## Files that might appear in the root of a volume
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

## Directories potentially created on remote AFP share
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk


# ===== JetBrains IDE =====
## Covers JetBrains IDEs: IntelliJ, RubyMine, PhpStorm, AppCode, PyCharm, CLion, Android Studio, WebStorm and Rider
## Reference: https://intellij-support.jetbrains.com/hc/en-us/articles/206544839

## User-specific stuff
.idea/**/workspace.xml
.idea/**/tasks.xml
.idea/**/usage.statistics.xml
.idea/**/dictionaries
.idea/**/shelf

## AWS User-specific
.idea/**/aws.xml

## Generated files
.idea/**/contentModel.xml

## Sensitive or high-churn files
.idea/**/dataSources/
.idea/**/dataSources.ids
.idea/**/dataSources.local.xml
.idea/**/sqlDataSources.xml
.idea/**/dynamic.xml
.idea/**/uiDesigner.xml
.idea/**/dbnavigator.xml

## Gradle
.gradle/**
**/build/**

.idea/**/gradle.xml
.idea/**/libraries

# Gradle and Maven with auto-import
# When using Gradle or Maven with auto-import, you should exclude module files,
# since they will be recreated, and may cause churn.  Uncomment if using
# auto-import.
# .idea/artifacts
# .idea/compiler.xml
# .idea/jarRepositories.xml
# .idea/modules.xml
# .idea/*.iml
# .idea/modules
# *.iml
# *.ipr

## CMake
cmake-build-*/

## Mongo Explorer plugin
.idea/**/mongoSettings.xml

## File-based project format
*.iws

## IntelliJ
out/

## mpeltonen/sbt-idea plugin
.idea_modules/

## JIRA plugin
atlassian-ide-plugin.xml

## Cursive Clojure plugin
.idea/replstate.xml

## SonarLint plugin
.idea/sonarlint/

## Crashlytics plugin (for Android Studio and IntelliJ)
com_crashlytics_export_strings.xml
crashlytics.properties
crashlytics-build.properties
fabric.properties

## Editor-based Rest Client
.idea/httpRequests

## Android studio 3.1+ serialized cache file
.idea/caches/build_file_checksums.ser

# ===== VSCode =====
.vscode
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
!.vscode/*.code-snippets

## Local History for Visual Studio Code
.history/

## Built Visual Studio Code Extensions
*.vsix

# ===== NPM / Yarn / Bin =====
node_modules

/.cache
/build
.env

# ===== My common temporary files
build.out

EOF

git commit -a -m'Create develop branch and update .gitignore'

### Prepare for static analysis additions to the build ###

mkdir -p {buildscripts,config}

# Substitute this text in the settings.gradle file at the head of the file
REPOSITORIES_TEXT="
pluginManagement {
    repositories {
        mavenLocal()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set( RepositoriesMode.FAIL_ON_PROJECT_REPOS )
    repositories {
        mavenLocal()
        mavenCentral()
    }
}
"


##### Checkstyle #####
## Create branch for checkstyle addition
git checkout -b feature/add-checkstyle


VERSIONTAGS_TEXT="        basePackage                = '${basePackage}'
"
VERSIONTAGS_TEXT+="
        // ===== Quality checks =====
"
VERSIONTAGS_TEXT+="
        // --- Coding practices (static analysis) ---"

PLUGIN_TEXT="    // ===== Quality Assurance ====="
PLUGIN_TEXT+="
    // --- Static Analysis
"

APPLY_TEXT="// ===== QA ====="
APPLY_TEXT+="
// --- Static Code Analysis"



# --- Checkstyle ---
VERSIONTAGS_TEXT+="
        // --- Coding style
        checkstyleVersion          = '10.20.0'
"
PLUGIN_TEXT+="
    // --- Style
    id 'checkstyle'
"

APPLY_TEXT+="
// --- Coding Style
apply from: '../buildscripts/checkstyle.gradle'
"

mkdir -p config/checkstyle
#touch config/checkstyle/{checkstyle,checkstyle-suppressions}.xmlMy



# --- Main rules ---
cat << EOF > config/checkstyle/checkstyle.xml
<?xml version="1.0"?>
<!DOCTYPE module PUBLIC
          "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN"
          "https://checkstyle.org/dtds/configuration_1_3.dtd">

<!--
    Checkstyle configuration that checks the Google coding conventions from Google Java Style
    that can be found at https://google.github.io/styleguide/javaguide.html

    Checkstyle is very configurable. Be sure to read the documentation at
    http://checkstyle.org (or in your downloaded distribution).

    To completely disable a check, just comment it out or delete it from the file.
    To suppress certain violations please review suppression filters.

    Authors: Max Vetrenko, Ruslan Diachenko, Roman Ivanov.
 -->

<module name = "Checker">
  <property name="charset" value="UTF-8"/>

  <property name="severity" value="warning"/>

  <property name="fileExtensions" value="java, properties, xml"/>
  <!-- Excludes all 'module-info.java' files              -->
  <!-- See https://checkstyle.org/config_filefilters.html -->
  <module name="BeforeExecutionExclusionFileFilter">
    <property name="fileNamePattern" value="module\-info\.java$"/>
  </module>
  <!-- https://checkstyle.org/config_filters.html#SuppressionFilter -->
  <module name="SuppressionFilter">
    <property name="file" value="\${org.checkstyle.google.suppressionfilter.config}"
           default="checkstyle-suppressions.xml" />
    <property name="optional" value="true"/>
  </module>

  <!-- Checks for whitespace                               -->
  <!-- See http://checkstyle.org/config_whitespace.html -->
  <module name="FileTabCharacter">
    <property name="eachLine" value="true"/>
  </module>

  <module name="LineLength">
    <property name="fileExtensions" value="java"/>
    <property name="max" value="128"/>
    <property name="ignorePattern" value="^package.*|^import.*|a href|href|http://|https://|ftp://"/>
  </module>

  <module name="TreeWalker">
    <module name="OuterTypeFilename"/>
    <module name="IllegalTokenText">
      <property name="tokens" value="STRING_LITERAL, CHAR_LITERAL"/>
      <property name="format"
               value="\\\\u00(09|0(a|A)|0(c|C)|0(d|D)|22|27|5(C|c))|\\\\(0(10|11|12|14|15|42|47)|134)"/>
      <property name="message"
               value="Consider using special escape sequence instead of octal value or Unicode escaped value."/>
    </module>
    <module name="AvoidEscapedUnicodeCharacters">
      <property name="allowEscapesForControlCharacters" value="true"/>
      <property name="allowByTailComment" value="true"/>
      <property name="allowNonPrintableEscapes" value="true"/>
    </module>
    <module name="AvoidStarImport"/>
    <module name="OneTopLevelClass"/>
    <module name="NoLineWrap">
      <property name="tokens" value="PACKAGE_DEF, IMPORT, STATIC_IMPORT"/>
    </module>
    <module name="EmptyBlock">
      <property name="option" value="TEXT"/>
      <property name="tokens"
               value="LITERAL_TRY, LITERAL_FINALLY, LITERAL_IF, LITERAL_ELSE, LITERAL_SWITCH"/>
    </module>
    <module name="NeedBraces">
      <property name="tokens"
               value="LITERAL_DO, LITERAL_ELSE, LITERAL_FOR, LITERAL_IF, LITERAL_WHILE"/>
    </module>
    <module name="LeftCurly">
      <property name="option" value="nl" />
      <property name="tokens"
               value="ANNOTATION_DEF, CLASS_DEF, CTOR_DEF, ENUM_CONSTANT_DEF, ENUM_DEF,
                    INTERFACE_DEF, LAMBDA, LITERAL_CASE, LITERAL_CATCH, LITERAL_DEFAULT,
                    LITERAL_DO, LITERAL_ELSE, LITERAL_FINALLY, LITERAL_FOR, LITERAL_IF,
                    LITERAL_SWITCH, LITERAL_SYNCHRONIZED, LITERAL_TRY, LITERAL_WHILE, METHOD_DEF,
                    OBJBLOCK, STATIC_INIT, RECORD_DEF, COMPACT_CTOR_DEF"/>
    </module>
    <module name="RightCurly">
      <property name="id" value="RightCurlySame"/>
      <property name="tokens"
               value="LITERAL_FINALLY, LITERAL_ELSE,
                    LITERAL_DO"/>
    </module>
    <module name="RightCurly">
      <property name="id" value="RightCurlyAlone"/>
      <property name="option" value="alone"/>
      <property name="tokens"
               value="CLASS_DEF, METHOD_DEF, CTOR_DEF, LITERAL_FOR, LITERAL_WHILE, STATIC_INIT,
                    INSTANCE_INIT, ANNOTATION_DEF, ENUM_DEF, INTERFACE_DEF, RECORD_DEF,
                    LITERAL_CATCH, LITERAL_TRY,
                    COMPACT_CTOR_DEF"/>
    </module>
    <module name="SuppressionXpathSingleFilter">
      <!-- suppresion is required till https://github.com/checkstyle/checkstyle/issues/7541 -->
      <property name="id" value="RightCurlyAlone"/>
      <property name="query" value="//RCURLY[parent::SLIST[count(./*)=1]
                                     or preceding-sibling::*[last()][self::LCURLY]]"/>
    </module>
    <module name="WhitespaceAfter">
      <property name="tokens"
               value="COMMA, SEMI, LITERAL_IF, LITERAL_ELSE,
                    LITERAL_WHILE, LITERAL_DO, LITERAL_FOR, DO_WHILE"/>
    </module>
    <module name="WhitespaceAround">
      <property name="allowEmptyConstructors" value="true"/>
      <property name="allowEmptyLambdas" value="true"/>
      <property name="allowEmptyMethods" value="true"/>
      <property name="allowEmptyTypes" value="true"/>
      <property name="allowEmptyLoops" value="true"/>
      <property name="ignoreEnhancedForColon" value="false"/>
      <property name="tokens"
               value="ASSIGN, BAND, BAND_ASSIGN, BOR, BOR_ASSIGN, BSR, BSR_ASSIGN, BXOR,
                    BXOR_ASSIGN, COLON, DIV, DIV_ASSIGN, DO_WHILE, EQUAL, GE, GT, LAMBDA, LAND,
                    LCURLY, LE, LITERAL_CATCH, LITERAL_DO, LITERAL_ELSE, LITERAL_FINALLY,
                    LITERAL_FOR, LITERAL_IF, LITERAL_RETURN, LITERAL_SWITCH, LITERAL_SYNCHRONIZED,
                    LITERAL_TRY, LITERAL_WHILE, LOR, LT, MINUS, MINUS_ASSIGN, MOD, MOD_ASSIGN,
                    NOT_EQUAL, PLUS, PLUS_ASSIGN, QUESTION, RCURLY, SL, SLIST, SL_ASSIGN, SR,
                    SR_ASSIGN, STAR, STAR_ASSIGN, LITERAL_ASSERT, TYPE_EXTENSION_AND"/>
      <message key="ws.notFollowed"
              value="WhitespaceAround: ''{0}'' is not followed by whitespace. Empty blocks may only be represented as '{}' when not part of a multi-block statement (4.1.3)"/>
      <message key="ws.notPreceded"
              value="WhitespaceAround: ''{0}'' is not preceded with whitespace."/>
    </module>
    <module name="OneStatementPerLine"/>
    <module name="MultipleVariableDeclarations"/>
    <module name="ArrayTypeStyle"/>
    <module name="MissingSwitchDefault"/>
    <module name="FallThrough"/>
    <module name="UpperEll"/>
    <module name="ModifierOrder"/>
    <module name="EmptyLineSeparator">
      <property name="tokens"
               value="PACKAGE_DEF, IMPORT, STATIC_IMPORT, CLASS_DEF, INTERFACE_DEF, ENUM_DEF,
                    STATIC_INIT, INSTANCE_INIT, METHOD_DEF, CTOR_DEF, VARIABLE_DEF, RECORD_DEF,
                    COMPACT_CTOR_DEF"/>
      <property name="allowNoEmptyLineBetweenFields" value="true"/>
    </module>
    <module name="SeparatorWrap">
      <property name="id" value="SeparatorWrapDot"/>
      <property name="tokens" value="DOT"/>
      <property name="option" value="nl"/>
    </module>
    <module name="SeparatorWrap">
      <property name="id" value="SeparatorWrapComma"/>
      <property name="tokens" value="COMMA"/>
      <property name="option" value="nl"/>
    </module>
    <module name="SeparatorWrap">
      <!-- ELLIPSIS is EOL until https://github.com/google/styleguide/issues/259 -->
      <property name="id" value="SeparatorWrapEllipsis"/>
      <property name="tokens" value="ELLIPSIS"/>
      <property name="option" value="EOL"/>
    </module>
    <module name="SeparatorWrap">
      <!-- ARRAY_DECLARATOR is EOL until https://github.com/google/styleguide/issues/258 -->
      <property name="id" value="SeparatorWrapArrayDeclarator"/>
      <property name="tokens" value="ARRAY_DECLARATOR"/>
      <property name="option" value="EOL"/>
    </module>
    <module name="SeparatorWrap">
      <property name="id" value="SeparatorWrapMethodRef"/>
      <property name="tokens" value="METHOD_REF"/>
      <property name="option" value="nl"/>
    </module>
    <module name="PackageName">
      <property name="format" value="^[a-z]+(\.[a-z][a-z0-9]*)*$"/>
      <message key="name.invalidPattern"
             value="Package name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="TypeName">
      <property name="tokens" value="CLASS_DEF, INTERFACE_DEF, ENUM_DEF,
                    ANNOTATION_DEF, RECORD_DEF"/>
      <message key="name.invalidPattern"
             value="Type name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="MemberName">
      <property name="format" value="^[a-z][a-z0-9][a-zA-Z0-9]*$"/>
      <message key="name.invalidPattern"
             value="Member name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="ParameterName">
      <property name="format" value="^[a-z]([a-z0-9][a-zA-Z0-9]*)?$"/>
      <message key="name.invalidPattern"
             value="Parameter name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="LambdaParameterName">
      <property name="format" value="^[a-z]([a-z0-9][a-zA-Z0-9]*)?$"/>
      <message key="name.invalidPattern"
             value="Lambda parameter name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="CatchParameterName">
      <property name="format" value="^[a-z]([a-z0-9][a-zA-Z0-9]*)?$"/>
      <message key="name.invalidPattern"
             value="Catch parameter name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="LocalVariableName">
      <property name="format" value="^[a-z]([a-z0-9][a-zA-Z0-9]*)?$"/>
      <message key="name.invalidPattern"
             value="Local variable name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="PatternVariableName">
      <property name="format" value="^[a-z]([a-z0-9][a-zA-Z0-9]*)?$"/>
      <message key="name.invalidPattern"
             value="Pattern variable name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="ClassTypeParameterName">
      <property name="format" value="(^[A-Z][0-9]?)$|([A-Z][a-zA-Z0-9]*[T]$)"/>
      <message key="name.invalidPattern"
             value="Class type name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="RecordComponentName">
      <property name="format" value="^[a-z]([a-z0-9][a-zA-Z0-9]*)?$"/>
      <message key="name.invalidPattern"
               value="Record component name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="RecordTypeParameterName">
      <property name="format" value="(^[A-Z][0-9]?)$|([A-Z][a-zA-Z0-9]*[T]$)"/>
      <message key="name.invalidPattern"
               value="Record type name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="MethodTypeParameterName">
      <property name="format" value="(^[A-Z][0-9]?)$|([A-Z][a-zA-Z0-9]*[T]$)"/>
      <message key="name.invalidPattern"
             value="Method type name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="InterfaceTypeParameterName">
      <property name="format" value="(^[A-Z][0-9]?)$|([A-Z][a-zA-Z0-9]*[T]$)"/>
      <message key="name.invalidPattern"
             value="Interface type name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="NoFinalizer"/>
    <module name="GenericWhitespace">
      <message key="ws.followed"
             value="GenericWhitespace ''{0}'' is followed by whitespace."/>
      <message key="ws.preceded"
             value="GenericWhitespace ''{0}'' is preceded with whitespace."/>
      <message key="ws.illegalFollow"
             value="GenericWhitespace ''{0}'' should followed by whitespace."/>
      <message key="ws.notPreceded"
             value="GenericWhitespace ''{0}'' is not preceded with whitespace."/>
    </module>
    <module name="Indentation">
      <property name="basicOffset" value="4"/>
      <property name="braceAdjustment" value="0"/>
      <property name="caseIndent" value="4"/>
      <property name="throwsIndent" value="4"/>
      <property name="lineWrappingIndentation" value="4"/>
      <property name="arrayInitIndent" value="4"/>
    </module>

    <!--
    <module name="AbbreviationAsWordInName">
      <property name="ignoreFinal" value="false"/>
      <property name="allowedAbbreviationLength" value="1"/>
      <property name="tokens"
               value="CLASS_DEF, INTERFACE_DEF, ENUM_DEF, ANNOTATION_DEF, ANNOTATION_FIELD_DEF,
                    PARAMETER_DEF, VARIABLE_DEF, METHOD_DEF, PATTERN_VARIABLE_DEF, RECORD_DEF,
                    RECORD_COMPONENT_DEF"/>
    </module>
    -->
    <module name="AbbreviationAsWordInName">
      <property name="ignoreFinal" value="false"/>
      <property name="allowedAbbreviationLength" value="1"/>
      <property name="tokens"
               value="ENUM_DEF, ANNOTATION_DEF, ANNOTATION_FIELD_DEF,
                    RECORD_DEF,
                    RECORD_COMPONENT_DEF"/>
    </module>
    <module name="AbbreviationAsWordInName">
      <property name="ignoreFinal" value="false"/>
      <property name="allowedAbbreviationLength" value="3"/>
      <property name="tokens"
               value="CLASS_DEF, INTERFACE_DEF,
                    METHOD_DEF,
                    PARAMETER_DEF, VARIABLE_DEF, PATTERN_VARIABLE_DEF"/>
    </module>

    <module name="NoWhitespaceBeforeCaseDefaultColon"/>
    <module name="OverloadMethodsDeclarationOrder"/>
    <module name="VariableDeclarationUsageDistance"/>
    <module name="CustomImportOrder">
      <property name="sortImportsInGroupAlphabetically" value="true"/>
      <property name="separateLineBetweenGroups" value="true"/>
      <property name="customImportOrderRules" value="STATIC###STANDARD_JAVA_PACKAGE###THIRD_PARTY_PACKAGE"/>
      <property name="tokens" value="IMPORT, STATIC_IMPORT, PACKAGE_DEF"/>
    </module>
    <module name="MethodParamPad">
      <property name="tokens"
               value="CTOR_DEF, LITERAL_NEW, METHOD_CALL, METHOD_DEF,
                    SUPER_CTOR_CALL, ENUM_CONSTANT_DEF, RECORD_DEF"/>
    </module>
    <module name="NoWhitespaceBefore">
      <property name="tokens"
               value="COMMA, SEMI, POST_INC, POST_DEC, DOT,
                    LABELED_STAT, METHOD_REF"/>
      <property name="allowLineBreaks" value="true"/>
    </module>
    <module name="ParenPad">
      <property name="option" value="space" />
      <property name="tokens"
               value="ANNOTATION, ANNOTATION_FIELD_DEF, CTOR_CALL, CTOR_DEF, DOT, ENUM_CONSTANT_DEF,
                    EXPR, LITERAL_CATCH, LITERAL_DO, LITERAL_FOR, LITERAL_IF, LITERAL_NEW,
                    LITERAL_SWITCH, LITERAL_SYNCHRONIZED, LITERAL_WHILE, METHOD_CALL,
                    METHOD_DEF, QUESTION, RESOURCE_SPECIFICATION, SUPER_CTOR_CALL, LAMBDA,
                    RECORD_DEF"/>
    </module>
    <module name="OperatorWrap">
      <property name="option" value="NL"/>
      <property name="tokens"
               value="BAND, BOR, BSR, BXOR, DIV, EQUAL, GE, GT, LAND, LE, LITERAL_INSTANCEOF, LOR,
                    LT, MINUS, MOD, NOT_EQUAL, PLUS, QUESTION, SL, SR, STAR, METHOD_REF,
                    TYPE_EXTENSION_AND "/>
    </module>
    <module name="AnnotationLocation">
      <property name="id" value="AnnotationLocationMostCases"/>
      <property name="tokens"
               value="CLASS_DEF, INTERFACE_DEF, ENUM_DEF, METHOD_DEF, CTOR_DEF,
                      RECORD_DEF, COMPACT_CTOR_DEF"/>
    </module>
    <module name="AnnotationLocation">
      <property name="id" value="AnnotationLocationVariables"/>
      <property name="tokens" value="VARIABLE_DEF"/>
      <property name="allowSamelineMultipleAnnotations" value="true"/>
    </module>
    <module name="NonEmptyAtclauseDescription"/>
    <module name="InvalidJavadocPosition"/>
    <module name="JavadocTagContinuationIndentation"/>
    <module name="SummaryJavadoc">
      <property name="forbiddenSummaryFragments"
               value="^@return the *|^This method returns |^A [{]@code [a-zA-Z0-9]+[}]( is a )"/>
    </module>
    <module name="JavadocParagraph"/>
    <module name="RequireEmptyLineBeforeBlockTagGroup"/>
    <module name="AtclauseOrder">
      <property name="tagOrder" value="@param, @return, @throws, @deprecated"/>
      <property name="target"
               value="CLASS_DEF, INTERFACE_DEF, ENUM_DEF, METHOD_DEF, CTOR_DEF, VARIABLE_DEF"/>
    </module>
    <module name="JavadocMethod">
      <property name="accessModifiers" value="public"/>
      <property name="allowMissingParamTags" value="true"/>
      <property name="allowMissingReturnTag" value="true"/>
      <property name="allowedAnnotations" value="Override, Test"/>
      <property name="tokens" value="METHOD_DEF, CTOR_DEF, ANNOTATION_FIELD_DEF, COMPACT_CTOR_DEF"/>
    </module>
    <module name="MissingJavadocMethod">
      <property name="scope" value="public"/>
      <property name="minLineCount" value="2"/>
      <property name="allowedAnnotations" value="Override, Test"/>
      <property name="tokens" value="METHOD_DEF, CTOR_DEF, ANNOTATION_FIELD_DEF,
                                   COMPACT_CTOR_DEF"/>
    </module>
    <module name="MissingJavadocType">
      <property name="scope" value="protected"/>
      <property name="tokens"
                value="CLASS_DEF, INTERFACE_DEF, ENUM_DEF,
                      RECORD_DEF, ANNOTATION_DEF"/>
      <property name="excludeScope" value="nothing"/>
    </module>
    <module name="MethodName">
      <property name="format" value="^[a-z][a-z0-9][a-zA-Z0-9_]*$"/>
      <message key="name.invalidPattern"
             value="Method name ''{0}'' must match pattern ''{1}''."/>
    </module>
    <module name="SingleLineJavadoc"/>
    <module name="EmptyCatchBlock">
      <property name="exceptionVariableName" value="expected"/>
    </module>
    <module name="CommentsIndentation">
      <property name="tokens" value="SINGLE_LINE_COMMENT, BLOCK_COMMENT_BEGIN"/>
    </module>
    <!-- https://checkstyle.org/config_filters.html#SuppressionXpathFilter -->
    <module name="SuppressionXpathFilter">
      <property name="file" value="\${org.checkstyle.google.suppressionxpathfilter.config}"
             default="checkstyle-xpath-suppressions.xml" />
      <property name="optional" value="true"/>
    </module>
  </module>
</module>
EOF

# --- Suppressions
cat << EOF > buildscripts/checkstyle.gradle
// ----- Static Analysis
// --- Checkstyle
checkstyle {
    ignoreFailures = false
    showViolations = false
    toolVersion = "\${checkstyleVersion}"
    // checkstyle.xml copy from:
    // https://raw.githubusercontent.com/checkstyle/checkstyle/checkstyle-8.6/src/main/resources/google_checks.xml
    // the version should be as same as plugin version
    configFile = file("\${rootDir}/config/checkstyle/checkstyle.xml")
}

checkstyleMain {
    source = 'src/main/java'
}

checkstyleTest {
    source = 'src/test/java'
}
EOF


cat << EOF > config/checkstyle/checkstyle-suppressions.xml
<?xml version="1.0"?>

<!DOCTYPE module PUBLIC
          "-//Puppy Crawl//DTD Suppressions 1.1//EN"
          "http://www.puppycrawl.com/dtds/suppressions_1_1.dtd">

<suppressions>

    <suppress files="src/.*" checks="JavadocType" />
    <suppress files="src/.*" checks="JavadocStyle" />
    <suppress files="src/.*" checks="JavadocTagContinuationIndentation" />
    <suppress files="src/.*" checks="JavadocParagraph" />
    <suppress files="src/.*" checks="JavadocMethod" />
    <suppress files="src/.*" checks="InvalidJavadocPosition" />
    <suppress files="src/.*" checks="SummaryJavadoc" />
    <suppress files="src/.*" checks="MissingJavadocMethod" />
    <suppress files="src/.*" checks="MissingJavadocType" />
    <suppress files="src/.*" checks="RequiresEmptyLineBeforeBlockTagGroup" />
    <suppress files="src/.*" checks="AtclauseOrder" />

</suppressions>
EOF

git add .
git commit -m'Checkstyle basic configuration'

git checkout develop
git merge feature/add-checkstyle

##### ----- PMD -----
git checkout -b feature/add-pmd

VERSIONTAGS_TEXT+="
        // --- Common Coding flaws
        pmdVersion                 = '7.7.0'
"

PLUGIN_TEXT+="
    // --- PMD - Common Coding flaws
    // id 'pmd'
"

APPLY_TEXT+="
// --- Common Coding flaws
//apply from: '../buildscripts/pmd.gradle'
"


cat << EOF > buildscripts/pmd.gradle
// ----- Static Analysis
// --- PMD
pmd {
    //toolVersion = "\${pmdVersion}"       // 6.32.0
    ruleSetFiles = files("\${rootDir}/config/pmd/pmd.xml")
    // ruleSets = []
    threads = 8

    consoleOutput  = true
    ignoreFailures = true       // Don't interrupt the build
}
EOF

mkdir -p config/pmd

cat << EOF > config/pmd/pmd-java-checkstyle-suppressions.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE suppressions PUBLIC
     "-//Puppy Crawl//DTD Suppressions 1.0//EN"
     "http://www.puppycrawl.com/dtds/suppressions_1_0.dtd">
<suppressions>
    <suppress files="[\\/]generated-sources[\\/]" checks="[a-zA-Z0-9]*"/>
    <suppress files="[\\/]javasymbols[\\/]testdata[\\/]" checks="[a-zA-Z0-9]*"/>

    <suppress files="[\\/]src[\\/]main[\\/]java[\\/]net[\\/]sourceforge[\\/]pmd[\\/]lang[\\/]java[\\/]rule[\\/]AbstractJavaRule\.java"
        checks="AvoidStarImport" />
    <suppress files="[\\/]src[\\/]test[\\/]java[\\/]net[\\/]sourceforge[\\/]pmd[\\/]typeresolution[\\/]testdata[\\/]*"
              checks="AvoidStarImport" />
    <suppress files="[\\/]src[\\/]test[\\/]java[\\/]net[\\/]sourceforge[\\/]pmd[\\/]typeresolution[\\/]testdata[\\/]*"
              checks="HideUtilityClassConstructor" />
    <suppress files="[\\/]src[\\/]test[\\/]java[\\/]net[\\/]sourceforge[\\/]pmd[\\/]typeresolution[\\/]testdata[\\/]*"
              checks="OneTopLevelClass" />
    <suppress files="src[\\/]main[\\/]java[\\/]net[\\/]sourceforge[\\/]pmd[\\/]lang[\\/]java[\\/]types[\\/]TypeSystem\.java"
              checks="MemberName" />
</suppressions>
EOF

cat << EOF > config/pmd/pmd.xml
<?xml version="1.0"?>

<!-- https://codestijl.dev/2020/05/08/using-pmd-in-a-gradle-build/ -->
<!-- https://github.com/darrendanvers/pmd-gradle-example/blob/master/config/pmd/pmd.xml -->


<!-- @SuppressWarnings({"PMD.JUnitAssertionsShouldIncludeMessage", "PMD.JUnitTestContainsTooManyAsserts", "PMD. AtLeastOneConstructor" }) -->


<ruleset name="Custom ruleset"
         xmlns="http://pmd.sourceforge.net/ruleset/2.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://pmd.sourceforge.net/ruleset/2.0.0
         http://pmd.sourceforge.net/ruleset_2_0_0.xsd">
    <description>
        PMD Basic Configuration
    </description>


    <!-- Best Practices -->
    <rule ref="category/java/bestpractices.xml">
        <!-- Tests for exceptions may check message text and cause. -->
        <exclude name="JUnitAssertionsShouldIncludeMessage" />
    </rule>
    <rule ref="category/java/bestpractices.xml/JUnitTestContainsTooManyAsserts">
        <properties>
            <property name="maximumAsserts" value="5" />
        </properties>
    </rule>

    <!-- Code Style -->
    <rule ref="category/java/codestyle.xml">
        <exclude name="CommentDefaultAccessModifier" />

        <!-- Forcing only one return is a mistake. It allows code to be cleaner -->
        <!-- if you allow for multiple returns. -->
        <exclude name="OnlyOneReturn" />

        <!-- Requiring a constructor clutters up the code and doesn't add a lot of value. -->
        <exclude name="AtLeastOneConstructor" />
    </rule>

    <rule ref="category/java/codestyle.xml/TooManyStaticImports">
        <properties>
            <property name="maximumStaticImports" value="6" />
        </properties>
    </rule>

    <rule ref="category/java/codestyle.xml/MethodNamingConventions" >
        <properties>
            <!-- I like have underscores in my test names. This allows for that. -->
            <property name="junit4TestPattern" value="[a-z][a-zA-Z0-9_]*" />
            <property name="junit5TestPattern" value="[a-z][a-zA-Z0-9_]*" />
        </properties>
    </rule>

    <rule ref="category/java/codestyle.xml/LongVariable">
        <properties>
            <property name="minimum" value="20" />
        </properties>
    </rule>

    <!-- Design -->
    <rule ref="category/java/design.xml">
        <!-- As much as I theoretically like the Law of Demeter, the test for it hasn't kept up -->
        <!-- with how a lot of coding is done. It can't handle stream processing. -->
        <exclude name="LawOfDemeter" />
        <!-- This rule has to be configured explicitly. There are no defaults. Since there is nothing -->
        <!-- I want to put in here, I excluded it to remove a warning during build. See -->
        <!-- https://pmd.github.io/latest/pmd_rules_java_design.html#loosepackagecoupling for how to configure -->
        <!-- this rule if you want to use 0it. -->
        <exclude name="LoosePackageCoupling" />
    </rule>

    <!-- Documentation -->
    <rule ref="category/java/documentation.xml" />
    <rule ref="category/java/documentation.xml/CommentRequired">
        <properties>
            <!-- Field comments can clutter the code. -->
            <property name="fieldCommentRequirement" value="Ignored" />
        </properties>
    </rule>
    <rule ref="category/java/documentation.xml/CommentSize">
        <properties>
            <!-- 6 lines is too restrictive for comment length as it includes the Javadoc comments. -->
            <property name="maxLines" value="30" />
            <!-- I want the line size to match the code requirement. -->
            <property name="maxLineLength" value="150" />
        </properties>
    </rule>

    <!-- Multithreading -->
    <rule ref="category/java/multithreading.xml" />

    <!-- Performance -->
    <rule ref="category/java/performance.xml" />

    <!-- Security -->
    <rule ref="category/java/security.xml"/>

    <!-- Error Prone -->
    <rule ref="category/java/errorprone.xml" />

</ruleset>
EOF

git add config/pmd
git add buildscripts

git commit -a -m'PMD is configured'
git checkout develop
git merge feature/add-pmd






### ----- Jacoco - code coverage

##### Checkstyle #####
## Create branch for code coverage (jacoco) addition
git checkout -b feature/add-jacoco


# VERSIONTAGS_TEXT="        // ===== Quality checks ====="
# VERSIONTAGS_TEXT+="\n        // --- Coding practices (static analysis) ---"

# PLUGIN_TEXT="    // ===== Quality Assurance ====="
# PLUGIN_TEXT+="\n    // --- Static Analysis"

# APPLY_TEXT="// ===== QA ====="
# APPLY_TEXT+="\n// --- Static Code Analysis"



# --- Jacoco ---
# VERSIONTAGS_TEXT+="
#         // --- Coding style
#         checkstyleVersion          = '10.20.0'
# "
PLUGIN_TEXT+="
    // --- Coverage
    id 'jacoco'
"

APPLY_TEXT+="
// --- Code Coverage
apply from: '../buildscripts/jacoco.gradle'
"



cat << EOF > buildscripts/jacoco.gradle
// --- Code coverage
jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                minimum = 0.1
            }
        }

        rule {
            limit {
                counter = 'LINE'
                value   = 'COVEREDRATIO'
                minimum = 0.1
            }
        }

        rule {
            enabled = false
            element = 'CLASS'
            includes = ['org.gradle.*']

            limit {
                counter = 'LINE'
                value = 'TOTALCOUNT'
                maximum = 0.1
            }
        }
    }
}

jacocoTestReport {
    dependsOn test // tests are required to run before generating the report

    reports {
        xml.required = true
    }

    afterEvaluate {
        classDirectories.setFrom(files(classDirectories.files.collect {
            fileTree(dir: it, exclude: [
                      "**/Application.class"  // Do not include the application class in coverage stats
                    , "**/App.class"          // Do not include the application class in coverage stats
            ])
        }))
    }
}
EOF

git add buildscripts

git commit -a -m'Code coverage (Jacoco) is configured'
git checkout develop
git merge feature/add-jacoco







## ===== Runtime Testing =====
VERSIONTAGS_TEXT+="
        // --- Testing ---
"

# --- Mutation Testing ---
git checkout -b feature/add-mutation-testing

VERSIONTAGS_TEXT+="
        // --- Mutation Testing
        pitPluginVersion           = '1.15.0'
        pitVersion                 = '1.17.1'
"
PLUGIN_TEXT+="
    // --- Mutation testing
    id 'info.solidsoft.pitest' version \""\${pitPluginVersion}"\"
"

APPLY_TEXT+="
// --- Mutation Testing
apply from: '../buildscripts/pitest.gradle'
"


cat << EOF > buildscripts/pitest.gradle
// --- Mutation testing
pitest {
    pitestVersion = "\${pitVersion}" //not needed when a default PIT version should be used
    verbose = true
    junit5PluginVersion = '1.2.1'
    // testSourceSets = [sourceSets.test]
    // mainSourceSets = [sourceSets.main]
    targetClasses = ["\${basePackage}.*"]
    threads = 16
    timestampedReports = false
    withHistory = false
    outputFormats = ['XML', 'HTML']
    reportDir = new File("\${project.buildDir}/test-results/mutation")
    // mutators = ['DEFAULTS', 'STRONGER', 'ALL' ]
    mutators = ['DEFAULTS' ]
}
EOF


git add buildscripts

git commit -a -m'Mutation Testing is configured'
git checkout develop
git merge feature/add-mutation-testing





## ===== Configuration Management =====
VERSIONTAGS_TEXT+="
        // ===== Configuration Management =====
"

# yet to add maven-publish
# https://docs.gradle.org/current/userguide/publishing_maven.html

# --- Artifact Versioning --- (Incomplete)
git checkout -b feature/add-artifact-versioning

VERSIONTAGS_TEXT+="
        // --- Artifact Versioning
        nemerosaVersion            = '3.1.0'
"
PLUGIN_TEXT+="
    // --- Artifact Versioning
    id 'net.nemerosa.versioning' version \""\${nemerosaVersion}"\"
"

APPLY_TEXT+="
// --- Artifact Versioning
apply from: '../buildscripts/versioning.gradle'
"


cat << EOF > buildscripts/versioning.gradle
// --- Artifact Versioning

jar {
    manifest {
        attributes(
            'Built-By'       : System.properties['user.name'],
            'Build-Timestamp': new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").format(new Date()),
            'Build-Revision' : versioning.info.commit,
            'Created-By'     : "Gradle \${gradle.gradleVersion}",
            'Build-Jdk'      : "Version: \${System.properties['java.version']} (Vendor: \${System.properties['java.vendor']} Version: \${System.properties['java.vm.version']})",
            'Build-OS'       : "OS: \${System.properties['os.name']} Arch: \${System.properties['os.arch']} Version: \${System.properties['os.version']}"
        )
    }
}

EOF

#cat << EOF > buildscripts/versioning.gradle
#// --- Artifact Versioning

git add buildscripts/versioning.gradle

git commit -a -m'Artifact Versioning is configured'
git checkout develop
git merge feature/add-artifact-versioning





# --- Artifact Publishing --- (Incomplete)
git checkout -b feature/add-artifact-publishing

VERSIONTAGS_TEXT+="
        // --- Artifact Publishing
        //publishingVersion          = '3.1.0'
"
PLUGIN_TEXT+="
    // --- Artifact Publishing
    id 'maven-publish'
"

APPLY_TEXT+="
// --- Artifact Publishing
apply from: '../buildscripts/publishing.gradle'
"

cat << EOF > buildscripts/publishing.gradle
// --- Artifact Publishing
publishing {
    publications {
        maven( MavenPublication ) {
            groupId = 'com.example'
            artifactId = 'default-application'
            version = '0.0'
        }
    }
}
EOF


git add buildscripts/publishing.gradle

git commit -a -m'Artifact Publishing is configured'
git checkout develop
git merge feature/add-artifact-publishing





##### ---------------------------  #####
##### ----- Post-processing -----  #####

mv app/build.gradle app/build.gradle.generated

awk -f foo.awk < app/build.gradle.generated > app/build.gradle

## AWK post procesing to replace placeholder tags

#AWK pattern should determine indentation level for the tag and indent all the replacement text by that amount (maybe)

# build.gradle
# SECTION_VERSIONTAGS with VERSIONTAGS_TEXT
# SECTION_PLUGIN with PLUGIN_TEXT
# SECTION_APPLY with APPLY_TEXT
#echo "Write to build.gradle"
echo "----- VersionTags"
		# // --- Target artifact
    #     basePackage                = 'com.example.spring'
echo "${VERSIONTAGS_TEXT}"
# echo "buildscript {\n    ext  {\n        // --- Target artifact\n        basePackage                = '${basePackage}'\n${VERSIONTAGS_TEXT}    }\n}"
echo "----- Plugins"
echo ${PLUGIN_TEXT}
set -x
# sed "s/[[:space:]]*\/\/[[:space:]]*SECTION_PLUGIN/${pluginText}    \/\/SECTION_PLUGIN/" app/build.gradle
# awk -f bar.awk < app/build.gradle.gen2 > app/build.gradle
#sed -i "s/[[:space:]]*\/\/[[:space:]]*SECTION_PLUGIN/insert plugin list    \/\/SECTION_PLUGIN/" app/build.gradle
# sed "s:SECTION_PLUGIN:\\${PLUGIN_TEXT}:" app/build.gradle
# echo  "awk -v pluginValue=\"${PLUGIN_TEXT}\" -f bar.awk < app/build.gradle"
awk -v pluginValue=\"$PLUGIN_TEXT\" -f bar.awk < app/build.gradle
# awk -v pluginValue="'${PLUGIN_TEXT}'" -f bar.awk < app/build.gradle
#awk -v pluginValue=\"${PLUGIN_TEXT}\" -f bar.awk < app/build.gradle

set +x
echo "----- Apply"
echo ${APPLY_TEXT}
#echo "-----"
# awk '/SECTION_APPLY/ {print ${APPLY_TEXT}}' < app/build.gradle


# settings.gradle
# Insert awk  here to replace the tag 'SECTION_REPOSITORIES' with REPOSITORIES_TEXT
# SECTION_REPOSITORIES with REPOSITORIES_TEXT
echo "Write to 'settings.gradle'"
echo ${REPOSITORIES_TEXT}


git commit -a -m'Tie all the build plugins together'



