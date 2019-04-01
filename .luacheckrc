stds.roblox = {
	read_globals = {
		"script", "spawn", "warn", "Instance", "game",
	},

	globals = {
		"typeof"
	}
}

stds.testez = {
	read_globals = {
		"describe",
		"it", "itFOCUS", "itSKIP",
		"FOCUS", "SKIP", "HACK_NO_XPCALL",
		"expect",
	}
}

ignore = {
	"212", -- unused arguments
	"self", "super"
}

std = "lua51+roblox"

files["**/*.spec.lua"] = {
	std = "+testez",
}