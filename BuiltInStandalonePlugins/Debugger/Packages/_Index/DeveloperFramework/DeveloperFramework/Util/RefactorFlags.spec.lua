return function ()
    local RefactorFlags = require(script.Parent.RefactorFlags)
    it("should return a table", function()
        expect(RefactorFlags).to.be.ok()
        expect(typeof(RefactorFlags)).to.equal("table")
    end)
end