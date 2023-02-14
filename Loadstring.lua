--- For debugging put this script inside your executor instead of the loadstring.

local Status, Release = pcall(function() return debug.getinfo(4) end)
Release = Status and Release

local Script = not Release and readfile("rath/Init.lua") or game:HttpGet("https://raw.githubusercontent.com/frayray909090/testing/main/Init.lua")

-- Import
loadstring(game:HttpGet("https://raw.githubusercontent.com/frayray909090/penis/main/wtf.lua"))()(Release, "frayray909090/testing", "main")

-- Main
loadstring(Script)()
