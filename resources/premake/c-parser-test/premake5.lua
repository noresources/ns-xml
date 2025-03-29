local ROOT_PATH = path.getabsolute ("../../..")
local DERIVED_PATH = path.join (ROOT_PATH, "tests/parsers/derived")
local SANITIZE_OPTIONS = {
	"Address",
	"UndefinedBehavior",
	"Fuzzer"
}

workspace "c-parser-test"
	configurations (SANITIZE_OPTIONS)
	runtime "Debug"
	symbols "On"
	location (path.join(DERIVED_PATH, "build") )
	targetdir ( path.join(DERIVED_PATH, "bin") )
	rtti "off"
	exceptionhandling "off"
	
	table.foreachi(
		os.matchdirs (path.join(ROOT_PATH, "tests/parsers/apps/*") ),
		function (appdir)
			local filename = path.join (appdir, "program-exe.c")
			if not os.isfile (filename)
			then
				return
			end
			local name = path.getname (appdir)
			project (name)
				kind "ConsoleApp"
				language "C"
				table.foreachi (SANITIZE_OPTIONS, function(n)
					filter {"configurations:" .. n }
						sanitize(n)
				end)
				filter {}
				files {
					path.join (appdir, "*.c"),
					path.join (ROOT_PATH, DERIVED_PATH, "src/*.c")
				}
				includedirs {
					path.join (ROOT_PATH, DERIVED_PATH, "src")
				}
		end)
