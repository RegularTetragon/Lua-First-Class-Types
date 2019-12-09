runtest:
	clear
	lua5.3 ./RunTests.lua

test2: RunTests.lua
	clear
	lua ./RunTests.lua