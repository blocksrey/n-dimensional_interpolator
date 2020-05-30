--n-dimensional array stitch
--p: {x, y, ...} (tween position; values should be constricted within 0 and 1)
--s: side length (int) of n-dimensional cube
--returns an index corresponding with the coordinate
--  |1 2 3|
--s |4 5 6|
--  |7 8 9|
--     s
--x {aaa, baa, aba, bba, aab, bab, abb, bbb}
--y {aaabaa, ababba, aabbab, abbbbb}
--z {aaabaaababba, aabbababbbbb}

local remove = table.remove
local floor  = math.floor
local rand   = math.random

local function remap(x)
	return 2*x < 1 and 2*x*x or 1 - 2*(x - 1)*(x - 1)
end

local function gentable(s, d)
	local f = {}
	for i = 1, s^d do
		f[i] = rand()
	end
	return f
end

local function stitch1(s, x)
	return
		1 +
		(x - 1)%s
end

local function stitch2(s, x, y)
	return
		1 +
		(x - 1)%s +
		(y - 1)%s*s
end

local function stitch3(s, x, y, z)
	return
		1 +
		(x - 1)%s +
		(y - 1)%s*s +
		(z - 1)%s*s*s
end

local function stitchn(s, p)
	local f = 1
	for i = 1, #p do
		f = f + (p[i] - 1)%s*s^(i - 1)
	end
	return floor(f)
end

local function vertex1(t, x)
	local s = #t
	local fx = floor(x)
	return
		t[stitch1(s, fx    )],
		t[stitch1(s, fx + 1)]
end

local function vertex2(t, x, y)
	local s = (#t)^(1/2)
	local fx = floor(x)
	local fy = floor(y)
	return
		t[stitch2(s, fx    , fy    )],
		t[stitch2(s, fx + 1, fy    )],
		t[stitch2(s, fx    , fy + 1)],
		t[stitch2(s, fx + 1, fy + 1)]
end

local function vertex3(t, x, y, z)
	local s = (#t)^(1/3)
	local fx = floor(x)
	local fy = floor(y)
	local fz = floor(z)
	return
		t[stitch3(s, fx    , fy    , fz    )],
		t[stitch3(s, fx + 1, fy    , fz    )],
		t[stitch3(s, fx    , fy + 1, fz    )],
		t[stitch3(s, fx + 1, fy + 1, fz    )],
		t[stitch3(s, fx    , fy    , fz + 1)],
		t[stitch3(s, fx + 1, fy    , fz + 1)],
		t[stitch3(s, fx    , fy + 1, fz + 1)],
		t[stitch3(s, fx + 1, fy + 1, fz + 1)]
end

local function vertexn(t, p)
	local d = #p
	local t = 2^d
	for i = 1, t do
		print(i)
	end
end

local function interp1(x, a, b)
	return a + x*(b - a)
end

local function interp2(x, y, aa, ba, ab, bb)
	local aaba = aa + x*(ba - aa)
	local abbb = ab + x*(bb - ab)
	return aaba + y*(abbb - aaba)
end

local function interp3(x, y, z, aaa, baa, aba, bba, aab, bab, abb, bbb)
	local aaabaa = aaa + x*(baa - aaa)
	local ababba = aba + x*(bba - aba)
	local aabbab = aab + x*(bab - aab)
	local abbbbb = abb + x*(bbb - abb)
	local aaabaaababba = aaabaa + y*(ababba - aaabaa)
	local aabbababbbbb = aabbab + y*(abbbbb - aabbab)
	return aaabaaababba + z*(aabbababbbbb - aaabaaababba)
end

local function interpn(p, v)
	local n = #v
	if n > 2 then
		local f = {}
		local x = p[1]
		for i = 1, n, 2 do
			f[1/2*(i + 1)] = (1 - x)*v[i] + x*v[i + 1]
		end
		remove(p, 1)
		return interpn(p, f)
	else
		local x = p[1]
		return (1 - x)*v[1] + x*v[2]
	end
end

local noise = {}

function noise.noise1(t, x)
	return interp1(x, vertex1(t, x))
end

function noise.noise2(t, x, y)
	return interp2(x, y, vertex2(t, x, y))
end

function noise.noise3(t, x, y, z)
	return interp3(x, y, z, vertex3(t, x, y, z))
end

function noise.noisen(t, p)
	return interpn(p, vertexn(t, p))
end

return noise