local Loader = {
	_VERSION = 1.0,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/loader.lua",
	_LICENSE = [[
		MIT LICENSE
		Copyright (c) 2021 incredible-gmod.ru
		Permission is hereby granted, free of charge, to any person obtaining a
		copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:
		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
		OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]],
	_DEBUG = false
}

local include_realm = {
    sv = SERVER and include or function() end,
    cl = SERVER and AddCSLuaFile or include
}

include_realm.sh = function(f)
    AddCSLuaFile(f)
    return include(f)
end

function Loader:include(path, realm)
	local worker = include_realm[realm or "sh"]
	if worker == nil then
		realm = "sh"
		worker = include_realm.sh
	end

	if file.Find(path, "LUA") then
		if self._DEBUG then
			print(realm .." > ".. path)
		end

		return worker(path)
	end
end

function Loader:GetFilename(path)
    return path:match("[^/]+$")
end

function Loader:RemoveExtension(path)
	return path:match("(.+)%..+")
end

function Loader:Include(path, realm)
	realm = realm or string.sub(self:GetFilename(path), 1, 2)
	return self:include(path, realm)
end

function Loader:IncludeDir(dir, recursive, realm, storage, base_path)
	base_path = base_path or dir
    local path = dir .."/"
    local files, folders = file.Find(path .."*", "LUA")

    for _, f in ipairs(files) do
    	if storage then
    		storage[self:RemoveExtension(recursive and (path:sub(#base_path + 2) .. f) or f)] = self:Include(path .. f, realm)
    	else
        	self:Include(path .. f, realm)
        end
    end

    if recursive == nil then return end

    for _, f in ipairs(folders) do
        self:IncludeDir(dir .."/".. f, recursive, realm, storage, base_path)
    end
end

function Loader:AddCsDir(dir, recursive)
    local path = dir .."/"
    local files, folders = file.Find(path .."*", "LUA")

    for _, f in ipairs(files) do
        AddCSLuaFile(path .. f)
    end

    if recursive == nil then return end

    for _, f in ipairs(folders) do
        self:IncludeDir(path .. f, true)
    end
end

Loader.__index = Loader
return Loader
