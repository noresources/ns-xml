local version = "2.0"

workspace "ns-xml"

	configurations {"Debug"}
	location (path.join("../../tests/derived", _ACTION))
	objdir "../../tests/derived/obj"
	targetdir "../../tests/derived/bin"
	warnings "Extra"
	
	project "c-parser-base"
		kind "StaticLib"
		language "C"
		files {
			path.join ("../../resources/c/program", version)
		}
	-- Parser tests
	-- Require tools/sh/run.sh parser -T -p c
	project "test-lib"
		kind "SharedLib"
		language "C"
		warnings "Extra"
		visibility "hidden"
		files {
			"../../tests/parsers/derived/src/parser-lib.c"
		}
	
	local apps = os.matchfiles( "../../tests/parsers/apps/*/program-exe.c" )
	for _, filename in pairs (apps)
	do
		local dir = path.getdirectory(filename)
		local name = path.getname (dir)
		project ("test-" .. name)
			kind "ConsoleApp"
			language "C"
			includedirs ({dir})
			files {
				path.join (dir, "*.c")
			}
			links { "test-lib" }
	end
