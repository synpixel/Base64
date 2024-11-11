local fs = require("@lune/fs")
local serde = require("@lune/serde")

type Environment = "luau" | "lune" | "roblox"

type Target = {
	environment: Environment,
	lib: string,
	build_files: { string }?,
}

local TARGETS: { [Environment]: Target } = {
	luau = {
		environment = "luau",
		lib = "lib.luau",
	},
	lune = {
		environment = "lune",
		lib = "lib.luau",
	},
	roblox = {
		environment = "roblox",
		lib = "lib.luau",
		build_files = { "lib.luau" },
	},
}

local baseManifest = serde.decode("toml", fs.readFile("pesde-base.toml"))

if fs.isDir("build") then
	fs.removeDir("build")
end
fs.writeDir("build")

for name, target in TARGETS do
	local out = `build/{name}`
	fs.writeDir(out)

	local includes = {
		"pesde.toml",
		"README.md",
		"LICENSE",
		target.lib,
	}

	fs.copy("README.md", `{out}/README.md`)
	fs.copy("LICENSE", `{out}/LICENSE`)
	fs.copy(target.lib, `{out}/{target.lib}`)

	local manifest = table.clone(baseManifest)
	manifest.target = target
	manifest.includes = includes

	local file = serde.encode("toml", manifest)
	fs.writeFile(`{out}/pesde.toml`, file)
end
