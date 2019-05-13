local rand  = math.random
local floor = math.floor

local numvals = 16^3

local noisetab = {}

for ind = 1, numvals do
	noisetab[ind] = rand()
end

--n-dimensional array stitch
--p: {x, y, ...}
--n: side length (int) of n-dimensional cube
--returns an index corresponding with the coordinate
--  |1 2 3|
--n |4 5 6|
--  |7 8 9|
--     n
local function stitch(t, p)
	local d = #p
	local n = (#t)^(1/d)
	local f = 1--step out of the car please sir
	for i = 1, d do
		f = f + (p[i] - 1)%n*n^(i - 1)
	end
	return t[floor(f)]--fucking annoying
end

--literally acceltween
local function remap(x)
	return x < 1/2 and 2*x*x or 1 - 2*(x - 1)*(x - 1)
end

--should i do n-dimensional tween????
local function interp1(x, v0, v1)
	local x = remap(x)
	return v0 + x*(v1 - v0)
end

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

local function corners1(x)
	local x = floor(x)
	return stitch(noisetab, {x    }),
	       stitch(noisetab, {x + 1})
end

local function corners2(x, y)
	local x = floor(x)
	local y = floor(y)
	return stitch(noisetab, {x    , y    }),
	       stitch(noisetab, {x + 1, y    }),
	       stitch(noisetab, {x    , y + 1}),
	       stitch(noisetab, {x + 1, y + 1})
end

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

local function noise1(x)
	return interp1(x%1, corners1(x))
end

local function noise2(x, y)
	return interp2(x%1, y%1, corners2(x, y))
end

local function noise3(x, y, z)
	return interp3(x%1, y%1, z%1, corners3(x, y, z))
end
