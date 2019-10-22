--[[
local function interp2(x, y, v00, v10, v01, v11)
	local x = remap(x)
	local y = remap(y)
	local v00v10 = v00 + x*(v10 - v00)
	local v01v11 = v01 + x*(v11 - v01)
	return v00v10 + y*(v01v11 - v00v10)
end

local function interp3(x, y, z, v000, v100, v010, v110, v001, v101, v011, v111)
	local x = remap(x)
	local y = remap(y)
	local z = remap(z)
	local v000v100 = v000 + x*(v100 - v000)
	local v010v110 = v010 + x*(v110 - v010)
	local v001v101 = v001 + x*(v101 - v001)
	local v011v111 = v011 + x*(v111 - v011)
	local v000v100v010v110 = v000v100 + y*(v010v110 - v000v100)
	local v001v101v011v111 = v001v101 + y*(v011v111 - v001v101)
	return v000v100v010v110 + z*(v001v101v011v111 - v000v100v010v110)
end

x {aaa, baa, aba, bba, aab, bab, abb, bbb}
y {aaabaa, ababba, aabbab, abbbbb}
z {aaabaaababba, aabbababbbbb}

local function corners3(x, y, z)
	local x = floor(x)
	local y = floor(y)
	local z = floor(z)
	return stitch(noisetab, {x    , y    , z    }),
	       stitch(noisetab, {x + 1, y    , z    }),
	       stitch(noisetab, {x    , y + 1, z    }),
	       stitch(noisetab, {x + 1, y + 1, z    }),
	       stitch(noisetab, {x    , y    , z + 1}),
	       stitch(noisetab, {x + 1, y    , z + 1}),
	       stitch(noisetab, {x    , y + 1, z + 1}),
	       stitch(noisetab, {x + 1, y + 1, z + 1})
end

local function noise3(x, y, z)
	return interp3(x%1, y%1, z%1, corners3(x, y, z))
end
--]]

local remove = table.remove
local rand   = math.random
local floor  = math.floor

--n-dimensional array stitch
--p: {x, y, ...} (tween position; values should be constricted within 0 and 1)
--s: side length (int) of n-dimensional cube
--returns an index corresponding with the coordinate
--  |1 2 3|
--s |4 5 6|
--  |7 8 9|
--     s

--vector position to table index
local function posind(d, s, p)
	local f = 1
	for i = 1, d do
		f = f + (p[i] - 1)%s*s^(i - 1)
	end
	return floor(f)--thanks
end

--vector position to table value
local function posval(t, p)
	local d = #p
	return t[posind(d, (#t)^(1/d), p)]
end

--generates a noise table
local function gentable(d, s)
	local f = {}
	for i = 1, d^s do
		f[i] = rand()
	end
	return f
end

--quadratic interpolation
local function remap(x)
	return 2*x < 1 and 2*x*x or 1 - 2*(x - 1)*(x - 1)
end

--interpolate values in n-dimensions
local function tween(v, p)
	local n = #v
	if n > 2 then
		local f = {}
		local x = p[1]
		for i = 1, n, 2 do
			f[#f + 1] = (1 - x)*v[i] + x*v[i + 1]
		end
		remove(p, 1)
		return tween(f, p)
	else
		local x = p[1]
		return (1 - x)*v[1] + x*v[2]
	end
end

--get the corners (vertex values) of the n-dimensional cube
local function corners(t, p)
	local f = {}
	local intpos = {}
	for i = 1, #p do
		intpos[i] = floor(p[i])
	end
	for i = 1, 2*#p, 2 do
		f[i]     = posval()
		f[i + 1] = posval()
	end
	return f
end

--constrain values within tweening limitations
local function constrain(p)
	local f = {}
	for i = 1, #p do
		f[i] = remap(p%1)
	end
	return f
end

--do the thing
local function noise(t, p)
	return tween(corners(t, p), constrain(p))
end

local table = gentable(2, 10)
local value = noise(table, {12.1, 2.4})
print(value)
