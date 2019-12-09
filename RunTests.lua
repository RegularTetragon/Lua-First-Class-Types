local testfiles = {
    "Type",
    "Primitives",
    "Function",
    "Interface",
    "Dictionary",
    "Tuple"
}
local failureStrings = {}
local totalSuccesses, totalFailures = 0,0
for i, file in pairs(testfiles) do
    local tests = require("test/"..file)
    print("Running tests: test/"..file)
    local successes, failures = 0, 0
    for testname, test in pairs(tests) do
        local trace, message
        local success = xpcall(test,
            function(err)
                message = err
                trace = debug.traceback()
            end
        )
        if success then
            successes = successes + 1
            totalSuccesses = totalSuccesses + 1
            print("test/"..file.."."..testname.. "() succeeded.")
        else
            failures = failures + 1
            totalFailures = totalFailures + 1
            table.insert(failureStrings, "test/"..file.."."..testname.. "() failed.")
            print("test/"..file.."."..testname.. "()\n    failed with reason: \n"..message.."\n"..trace)
        end
    end
    
    print(successes .. " / ".. failures + successes.. " tests passed.\n")
end

for i, failureString in pairs(failureStrings) do
    print(failureString)
end
print(totalSuccesses .. " / "..totalFailures + totalSuccesses.." tests passed in total.\n")