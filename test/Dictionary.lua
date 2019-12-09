require "src.Dictionary"
return {
    Contains = function()
        assert(String[String]:contains {asdf = "asdf", jkl = "jkl"})
        assert(String[Number]:contains {"asdf", "jkl"})
    end
}