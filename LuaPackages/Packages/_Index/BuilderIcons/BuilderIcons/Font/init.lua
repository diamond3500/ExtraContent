local BuilderIcons = script.Parent

local CorePackages = script:FindFirstAncestor("CorePackages")

local BuilderIconsFallback = require(BuilderIcons.BuilderIconsFallback)

local function getPackagePath(): string?
	local packageRoot = script.Parent

	if CorePackages == nil then
		-- We're not in a core script, no internal path
		return nil
	end

	local path = {}
	local current: Instance? = packageRoot
	while current ~= nil and current ~= CorePackages do
		table.insert(path, 1, current.Name)
		current = current.Parent
	end

	return "LuaPackages/" .. table.concat(path, "/")
end

local function getFamilyAsset(): string
  local packagePath = getPackagePath()
  if packagePath == nil then
    return "rbxassetid://" .. BuilderIconsFallback
  end

  return "rbxasset://" .. packagePath .. "/BuilderIcons.json"
end

local familyAsset = getFamilyAsset()

return {
  Regular = Font.new(familyAsset, Enum.FontWeight.Regular),
  Filled = Font.new(familyAsset, Enum.FontWeight.Bold),
}
