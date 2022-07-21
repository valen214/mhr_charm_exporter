

# use with nmake only

include .env

GAME_REFRAMEWORK_AUTORUN_DIR=$(MHR_GAME_DIRECTORY)/reframework/autorun

INCLUDE=$(INCLUDE);C:\Program Files\Lua
INCLUDE=$(INCLUDE);C:\Program Files\Lua\include

OUTPUT_DIR=reframework/autorun/charms_export
OUTPUT_DLL_PATH=$(OUTPUT_DIR)\charms_export_lib.dll


TEST_LIBS=Shell32.lib,Ole32.lib,Comctl32.lib,Propsys.lib,Shlwapi.lib

all: "src/charms_export_lib.cpp"
	if not exist "$(OUTPUT_DIR:/=\)" mkdir "$(OUTPUT_DIR:/=\)"

	cl /nologo /EHsc /std:c++17 \
		/D_USRDLL /D_WINDLL src/charms_export_lib.cpp \
		/D "_CRT_SECURE_NO_WARNINGS" \
		/LD /link /nologo \
		/DEFAULTLIB:"C:\Program Files\Lua\lua54.lib" \
		/DLL /OUT:"$(OUTPUT_DLL_PATH)"
	del *.obj *.lib *.exp

	copy /Y \
		"reframework\autorun\charms_export.lua" \
		"$(GAME_REFRAMEWORK_AUTORUN_DIR)"
	copy /B /Y "$(OUTPUT_DLL_PATH)" "$(GAME_REFRAMEWORK_AUTORUN_DIR)/charms_export/"

test:
	echo $(INPUT:a=c) # Evaluates to "a and b"

testa:
	cl /EHsc /std:c++17 /nologo src/a.cpp /link /out:a.exe
	.\a.exe

dialog: src/test.cpp
	cl /nologo \
		src/test.cpp \
		/link /nologo \
		/DEFAULTLIB:$(TEST_LIBS:,= /DEFAULTLIB:)

clean:
	del *.obj *.so *.exp *.lib