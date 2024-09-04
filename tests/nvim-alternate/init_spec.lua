local mod = require('nvim-alternate')

it('works', function()
	assert.is.same(
		mod.map_alternate('lua/a.lua', 'lua/*.lua', 'test/lua/*_spec.lua', { glob = true }),
		"test/lua/a_spec.lua"
	)

	assert.is.same(
		mod.map_alternate('test/lua/a_spec.lua', 'test/lua/*_spec.lua', 'lua/*.lua', { glob = true }),
		"lua/a.lua"
	)
end)
