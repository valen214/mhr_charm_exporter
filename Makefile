

# use with nmake only

include .env

GAME_REFRAMEWORK_AUTORUN_DIR=$(MHR_GAME_DIRECTORY)/reframework/autorun

INCLUDE=$(INCLUDE);C:\Program Files\Lua
INCLUDE=$(INCLUDE);C:\Program Files\Lua\include

OUTPUT_DIR=reframework/autorun/charms_export
OUTPUT_DLL_PATH=$(OUTPUT_DIR)\charms_export_lib.dll


TEST_LIBS=Shell32.lib,Ole32.lib,Comctl32.lib,Propsys.lib,Shlwapi.lib

all: dll
	copy /Y \
		"reframework\autorun\charms_export.lua" \
		"$(GAME_REFRAMEWORK_AUTORUN_DIR)"
	copy /B /Y "$(OUTPUT_DLL_PATH)" \
		"$(GAME_REFRAMEWORK_AUTORUN_DIR)/charms_export/"

dll: "src/charms_export_lib.c"
	if not exist "$(OUTPUT_DIR:/=\)" mkdir "$(OUTPUT_DIR:/=\)"

# /EHsc /std:c++17
	cl /nologo \
		/D_USRDLL /D_WINDLL src/charms_export_lib.c \
		/D "_CRT_SECURE_NO_WARNINGS" \
		/LD /link /nologo \
		/DEFAULTLIB:"C:\Program Files\Lua\lua54.lib" \
		/DLL /OUT:"$(OUTPUT_DLL_PATH)"
	del *.obj *.lib *.exp

search: "src/armor_set_search/search.ts"
	ts-node src/armor_set_search/search.ts


search_rust: "src/armor_set_search/search.rs" "Cargo.toml"
  cargo run --bin "search"
# rustc "src/armor_set_search/search.rs"
# .\search.exe


test:
	echo $(INPUT:a=c) # Evaluates to "a and b"

testa:
	cl /EHsc /std:c++17 /nologo tests/a.cpp /link /out:tests\a.exe
	.\tests\a.exe

testdll: "tests/test_dll.lua" dll
	lua tests\test_dll.lua


dialog: src/test.cpp
	cl /nologo \
		src/test.cpp \
		/link /nologo \
		/DEFAULTLIB:$(TEST_LIBS:,= /DEFAULTLIB:)

clean:
	del *.obj *.so *.exp *.lib