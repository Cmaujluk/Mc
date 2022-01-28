local gpu=require("component").gpu
local graffiti = {}

if gpu.maxDepth()==8 then
 graffiti.colors = {
  white    = 0xffffff,
  orange   = 0xff9200,
  magenta  = 0xff00ff,
  lightblue= 0x99dbff,
  yellow   = 0xffff00,
  lime     = 0x00ff00,
  pink     = 0xffb6bf,
  gray     = 0x787878,
  silver   = 0xc3c3c3,
  cyan     = 0x00ffff,
  purple   = 0x990080,
  blue     = 0x0000ff,
  brown    = 0x992440,
  green    = 0x009200,
  red      = 0xff0000,
  black    = 0x000000}
elseif gpu.maxDepth()==4 then
 graffiti.colors = {
  white    = 0xffffff,
  orange   = 0xffcc33,
  magenta  = 0xcc66cc,
  lightblue= 0x336699,
  yellow   = 0xffff33,
  lime     = 0x33cc33,
  pink     = 0xff6699,
  gray     = 0x333333,
  silver   = 0xcccccc,
  cyan     = 0x6699ff,
  purple   = 0x9933cc,
  blue     = 0x333399,
  brown    = 0x663300,
  green    = 0x336600,
  red      = 0xff3333,
  black    = 0x000000}
else
 graffiti.colors  ={
  white    = 0xffffff,
  black    = 0x000000}
end

local currentX,currentY = 1,1
local Color = gpu.getForeground()
local maxX,maxY=gpu.getResolution()

graffiti.setColor=function(color)
  checkArg(1, color, "number")
  Color=color
end

local function getColor(x,y)
  if x<1 or x>maxX then return end
  local n=y % 2
  y=(y+n)/2
  if y<1 or y>maxY then return end
  local c,Fc,Bc = gpu.get(x,y)
  if c~="▄" or n==1 then return Bc end
  return Fc
end

graffiti.getColor=function(x,y)
  checkArg(1, x, "number")
  checkArg(2, y, "number")
  return getColor(math.floor(x+0.5),math.floor(y+0.5))
end

local function dot(x,y,color)
  if x<1 or x>maxX then return end
  local n=y % 2
  y=(y+n)/2
  if y<1 or y>maxY then return end
  color=color or Color
  local c,Fc,Bc = gpu.get(x,y)
  if c~="▄" then Fc=Bc end
  if n==0 then Fc=color else Bc=color end
  gpu.setForeground(Fc)
  gpu.setBackground(Bc)
  gpu.set(x,y,"▄")
end

local function dot_alpha(x,y,r,g,b,a)
  if x<1 or x>maxX then return end
  local n=y % 2
  y=(y+n)/2
  if y<1 or y>maxY then return end
  local c,Fc,Bc = gpu.get(x,y)
  if c~="▄" then Fc=Bc end
  if n==0 then
    local b0=Fc % 256
	Fc=math.floor(Fc/256)
	local r0, g0 = math.floor(Fc/256), Fc % 256
	r0=math.floor(r0+(r-r0)*a/255+0.5)
	g0=math.floor(g0+(g-g0)*a/255+0.5)
	b0=math.floor(b0+(b-b0)*a/255+0.5)
    Fc=(r0*256 + g0)*256 + b0
  else
    local b0=Bc % 256
	Bc=math.floor(Bc/256)
	local r0, g0 = math.floor(Bc/256), Bc % 256
	r0=math.floor(r0+(r-r0)*a/255+0.5)
	g0=math.floor(g0+(g-g0)*a/255+0.5)
	b0=math.floor(b0+(b-b0)*a/255+0.5)
    Bc=(r0*256 + g0)*256 + b0
  end
  
  gpu.setForeground(Fc)
  gpu.setBackground(Bc)
  gpu.set(x,y,"▄")
end

graffiti.dot=function(x,y)
  checkArg(1, x, "number")
  checkArg(2, y, "number")
  local Fc, Bc = gpu.getForeground(), gpu.getBackground()
  maxX,maxY=gpu.getResolution()
  x=math.floor(x+0.5)
  y=math.floor(y+0.5)
  dot(x,y)
  currentX,currentY = x,y
  gpu.setForeground(Fc)
  gpu.setBackground(Bc)
end

local function move(x,y) -- алгоритм Брезенхема рисования линии
  local dx,dy=math.abs(x-currentX),math.abs(y-currentY)
  local x0,y0=currentX,currentY
  local sx = x0<x and 1 or -1
  local sy = y0<y and 1 or -1
  local err = 0
  if dx>dy then
    while true do
	  dot(x0,y0)
	  x0=x0+sx
	  if x0*sx>=x*sx then return end
	  err=err+dy
	  if 2*err>=dx then
	    y0=y0 + sy
		err=err-dx
	  end
	end
  else
    while true do
	  dot(x0,y0)
	  y0=y0+sy
	  if y0*sy>=y*sy then return end
	  err=err+dx
	  if 2*err>=dy then
	    x0=x0 + sx
		err=err-dy
	  end
	end
  end
end

graffiti.move=function(x,y)
  checkArg(1, x, "number")
  checkArg(2, y, "number")
  x=math.floor(x+0.5)
  y=math.floor(y+0.5)
  local Fc, Bc = gpu.getForeground(), gpu.getBackground()
  maxX,maxY=gpu.getResolution()
  move(x,y)
  currentX,currentY = x,y
  gpu.setForeground(Fc)
  gpu.setBackground(Bc)
end

graffiti.line=function(x0,y0,x1,y1)
  checkArg(1, x0, "number")
  checkArg(2, y0, "number")
  checkArg(3, x1, "number")
  checkArg(4, y1, "number")
  local Fc, Bc = gpu.getForeground(), gpu.getBackground()
  maxX,maxY=gpu.getResolution()
  x0=math.floor(x0+0.5)
  y0=math.floor(y0+0.5)
  dot(x0,y0)
  currentX,currentY = x0,y0
  x1=math.floor(x1+0.5)
  y1=math.floor(y1+0.5)
  move(x1,y1)
  currentX,currentY = x1,y1
  gpu.setForeground(Fc)
  gpu.setBackground(Bc)
end

graffiti.circle=function(xc,yc,r,fillColor) -- модифицированный алгоритм Брезенхема рисования окружности
  checkArg(1, xc, "number")
  checkArg(2, yc, "number")
  checkArg(3, r, "number")
  checkArg(4, fillColor, "number", "boolean", "nil")
  local Fc, Bc = gpu.getForeground(), gpu.getBackground()
  maxX,maxY=gpu.getResolution()
  if fillColor==true then fillColor=Color end
  xc=math.floor(xc+0.5)
  yc=math.floor(yc+0.5)
  z=math.floor(r+0.5)
  local d=3-2*r
  local x,y=0,r
  while(x <= y) do
    dot(xc+x,yc+y)
    dot(xc+x,yc-y)
    dot(xc-x,yc-y)
    dot(xc-x,yc+y)
	if y>x then
      dot(xc+y,yc+x)
      dot(xc+y,yc-x)
      dot(xc-y,yc-x)
      dot(xc-y,yc+x)
	  if fillColor then
	    for i=xc-y+1,xc+y-1 do
	      dot(i,yc+x, fillColor)
		  if x>0 then dot(i,yc-x, fillColor) end
	    end
	  end
	end
    if d<0 then d=d+4*x+6
    else
      d=d+4*(x-y)+10
      y=y-1
	  if fillColor and y>x then
	    for i=xc-x,xc+x do
		  dot(i,yc+y, fillColor)
		  dot(i,yc-y, fillColor)
	    end
	  end
    end
    x=x+1
  end
  gpu.setForeground(Fc)
  gpu.setBackground(Bc)
end

graffiti.fill=function(x,y)
  checkArg(1, x, "number")
  checkArg(2, y, "number")
  local Fc, Bc = gpu.getForeground(), gpu.getBackground()
  maxX,maxY=gpu.getResolution()
  x=math.floor(x+0.5)
  y=math.floor(y+0.5)
  local fillColor=getColor(x,y)
  if fillColor==Color then return end
  local fillArray={{x,y}}
  while fillArray[1] do
    x,y=fillArray[1][1],fillArray[1][2]
	table.remove(fillArray,1)
	if getColor(x,y)==fillColor then
	  dot(x,y,Color)
	  if getColor(x-1,y)==fillColor then table.insert(fillArray,{x-1,y}) end
	  if getColor(x+1,y)==fillColor then table.insert(fillArray,{x+1,y}) end
	  if getColor(x,y-1)==fillColor then table.insert(fillArray,{x,y-1}) end
	  if getColor(x,y+1)==fillColor then table.insert(fillArray,{x,y+1}) end
	end
  end
  gpu.setForeground(Fc)
  gpu.setBackground(Bc)
end

graffiti.polygon=function( ... )
  local Fc, Bc = gpu.getForeground(), gpu.getBackground()
  maxX,maxY=gpu.getResolution()
  local args={...}
  local x={} y={}  
  for i=2,#args,2 do 
    checkArg(i-1,args[i-1], "number")
    checkArg(i,  args[i], "number")
	table.insert(x,math.floor(args[i-1]+0.5))
	table.insert(y,math.floor(args[i]+0.5))
  end
  x[0]=x[#x]
  y[0]=y[#y]

  local fillColor
  if #args % 2 ==1 then fillColor=args[#args] end
  if fillColor==true then fillColor=Color end
  if fillColor then
    checkArg(#args, fillColor, "number")
	local minY,maxY=math.huge,-math.huge
	for i=1,#x do
	  if y[i]<minY then minY=y[i] end
	  if y[i]>maxY then maxY=y[i] end
	end
	for yy=minY,maxY do
	  local xx={}
	  for i=1,#x do
        local c=(y[i]-yy)*(yy-y[i-1])
		if c>0 then
		  xx[#xx+1]=math.floor((x[i-1]-x[i])*(yy-y[i])/(y[i-1]-y[i])+x[i]+0.5)
		end
		if c==0 then
		  if yy>y[i-1] then xx[#xx+1]=x[i] end
		  if yy>y[i] then xx[#xx+1]=x[i-1] end
		end
	  end
	  table.sort(xx)
	  for i=1,#xx,2 do
	    for i=xx[i]+1,xx[i+1]-1 do dot(i,yy, fillColor) end
	  end
	end
  end
  dot(x[0],y[0])
  currentX,currentY = x[0],y[0]
  for i=1,#x do
    move(x[i],y[i])
    currentX,currentY = x[i],y[i]
  end
  gpu.setForeground(Fc)
  gpu.setBackground(Bc)
end


------------------------deflate--------------------------------------------
local band, lshift, rshift                  ----77
band = bit32.band
lshift = bit32.lshift
rshift = bit32.rshift

local function make_outstate(outbs)         ----98
	local outstate = {}
	outstate.outbs = outbs
	outstate.window = {}
	outstate.window_pos = 1
	return outstate
end

local function output(outstate, byte)       ----106
	-- debug('OUTPUT:', s)
	local window_pos = outstate.window_pos
	outstate.outbs(byte)
	outstate.window[window_pos] = byte
	outstate.window_pos = window_pos % 32768 + 1	
end

local function noeof(val, ctx)                     ----114
	return assert(val, 'unexpected end of file with context ' .. tostring(ctx))
end

local function memoize(f)                          ----122
	local mt = {}
	local t = setmetatable({}, mt)
	function mt:__index(k)
		local v = f(k)
		t[k] = v
		return v
	end
	return t
end

-- small optimization (lookup table for powers of 2)
local pow2 = memoize(function(n) return 2^n end)

-- weak metatable marking objects as bitstream type
local is_bitstream = setmetatable({}, {__mode='k'})      ----143

local function bytestream_from_string(s)                 ----154
	local i = 1
	local o = {s=s}
	function o:read()
		local by
		if i <= #self.s then
			by = self.s:byte(i)
			i = i + 1
		end
		return by
	end
	return o
end

local function bitstream_from_bytestream(bys)            ----186
	local buf_byte = 0
	local buf_nbit = 0
	local o = {}

	function o:nbits_left_in_byte()
		return buf_nbit
	end

	function o:read(nbits)
		nbits = nbits or 1
		while buf_nbit < nbits do
			local byte = bys:read()
			if not byte then return end	-- note: more calls also return nil
			buf_byte = buf_byte + lshift(byte, buf_nbit)
			buf_nbit = buf_nbit + 8
		end
		local bits
		if nbits == 0 then
			bits = 0
		elseif nbits == 32 then
			bits = buf_byte
			buf_byte = 0
		else
			bits = band(buf_byte, rshift(0xffffffff, 32 - nbits))
			buf_byte = rshift(buf_byte, nbits)
		end
		
		if nbits == 16 then
			-- bugfix: swap bytes
			bits = rshift(band(bits, 0xFF00), 8) + lshift(band(bits, 0xFF), 8)
		end
		
		buf_nbit = buf_nbit - nbits
		return bits
	end
	
	is_bitstream[o] = true

	return o
end

local function get_bitstream(o)                              ----237
	local bs
	if is_bitstream[o] then	return o
--	elseif io.type(o) == 'file' then
--		bs = bitstream_from_bytestream(bytestream_from_file(o))
	elseif type(o) == 'string' then
		bs = bitstream_from_bytestream(bytestream_from_string(o))
--	elseif type(o) == 'function' then
--		bs = bitstream_from_bytestream(bytestream_from_function(o))
	else
		runtime_error 'unrecognized type'
	end
	return bs
end

local function get_obytestream(o)                              ----254
	local bs
	if io.type(o) == 'file' then
		bs = function(sbyte) o:write(string_char(sbyte)) end
	elseif type(o) == 'function' then
		bs = o
	elseif type(o) == 'table' then
		-- assume __callable table
		bs = o
	else
		runtime_error('unrecognized type: ' .. tostring(o))
	end
	return bs
end

local function HuffmanTable(init, is_full)               ----270
	local t = {}
	if is_full then
		for val,nbits in pairs(init) do
			if nbits ~= 0 then
				t[#t+1] = {val=val, nbits=nbits}
			end
		end
	else
		for i=1,#init-2,2 do
			local firstval, nbits, nextval = init[i], init[i+1], init[i+2]
			if nbits ~= 0 then
				for val=firstval,nextval-1 do
					t[#t+1] = {val=val, nbits=nbits}
				end
			end
		end
	end
	table.sort(t, function(a,b)
		return a.nbits == b.nbits and a.val < b.val or a.nbits < b.nbits
	end)

	-- assign codes
	local code = 1	-- leading 1 marker
	local nbits = 0
	for i,s in ipairs(t) do
		if s.nbits ~= nbits then
			code = code * pow2[s.nbits - nbits]
			nbits = s.nbits
		end
		s.code = code
		code = code + 1
	end

	local minbits = math.huge
	local look = {}
	for i,s in ipairs(t) do
		minbits = math.min(minbits, s.nbits)
		look[s.code] = s.val
	end

	local msb = function(bits, nbits)
		local res = 0
		for i=1,nbits do
			res = lshift(res, 1) + band(bits, 1)
			bits = rshift(bits, 1)
		end
		return res
	end
	
	local tfirstcode = memoize(function(bits)
		return pow2[minbits] + msb(bits, minbits) 
	end)

	function t:read(bs)
		local code = 1 -- leading 1 marker
		local nbits = 0
		while 1 do
			if nbits == 0 then	-- small optimization (optional)
				code = tfirstcode[noeof(bs:read(minbits), 1)]
				nbits = nbits + minbits
			else
				local b = noeof(bs:read(), 2)
				nbits = nbits + 1
				code = lshift(code, 1) + b	 -- MSB first
			end
			local val = look[code]
			if val then
				return val
			end
		end
	end

	return t
end

local function parse_zlib_header(bs)                          ----358
	local cm = bs:read(4) -- Compression Method
	local cinfo = bs:read(4) -- Compression info
	local fcheck = bs:read(5) -- FLaGs: FCHECK (check bits for CMF and FLG)
	local fdict = bs:read(1) -- FLaGs: FDICT (present dictionary)
	local flevel = bs:read(2) -- FLaGs: FLEVEL (compression level)
	local cmf = cinfo * 16	+ cm -- CMF (Compresion Method and flags)
	local flg = fcheck + fdict * 32 + flevel * 64 -- FLaGs
	
	if cm ~= 8 then -- not "deflate"
		error("unrecognized zlib compression method: " + cm)
	end
	if cinfo > 7 then
		error("invalid zlib window size: cinfo=" + cinfo)
	end
	local window_size = 2^(cinfo + 8)
	
	if (cmf*256 + flg) % 31 ~= 0 then
		error("invalid zlib header (bad fcheck sum) - overflow by " .. ((cmf*256 + flg) % 31))
	end
	
	if fdict == 1 then
		error("FIX:TODO - FDICT not currently implemented")
	end
	
	return window_size
end

local function parse_huffmantables(bs)                                      ----451
		local hlit = bs:read(5)	-- # of literal/length codes - 257
		local hdist = bs:read(5) -- # of distance codes - 1
		local hclen = noeof(bs:read(4), 3) -- # of code length codes - 4

		local ncodelen_codes = hclen + 4
		local codelen_init = {}
		local codelen_vals = {
			16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15}
		for i=1,ncodelen_codes do
			local nbits = bs:read(3)
			local val = codelen_vals[i]
			codelen_init[val] = nbits
		end
		local codelentable = HuffmanTable(codelen_init, true)

		local function decode(ncodes)
			local init = {}
			local nbits
			local val = 0
			while val < ncodes do
				local codelen = codelentable:read(bs)
				--FIX:check nil?
				local nrepeat
				if codelen <= 15 then
					nrepeat = 1
					nbits = codelen
					--debug('w', nbits)
				elseif codelen == 16 then
					nrepeat = 3 + noeof(bs:read(2), 4)
					-- nbits unchanged
				elseif codelen == 17 then
					nrepeat = 3 + noeof(bs:read(3), 5)
					nbits = 0
				elseif codelen == 18 then
					nrepeat = 11 + noeof(bs:read(7), 6)
					nbits = 0
				else
					error 'ASSERT'
				end
				for i=1,nrepeat do
					init[val] = nbits
					val = val + 1
				end
			end
			local huffmantable = HuffmanTable(init, true)
			return huffmantable
		end

		local nlit_codes = hlit + 257
		local ndist_codes = hdist + 1

		local littable = decode(nlit_codes)
		local disttable = decode(ndist_codes)

		return littable, disttable
end

local tdecode_len_base
local tdecode_len_nextrabits
local tdecode_dist_base
local tdecode_dist_nextrabits
local function parse_compressed_item(bs, outstate, littable, disttable)
	local val = littable:read(bs)
	if val < 256 then -- literal
		output(outstate, val)
	elseif val == 256 then -- end of block
		return true
	else
		if not tdecode_len_base then
			local t = {[257]=3}
			local skip = 1
			for i=258,285,4 do
				for j=i,i+3 do t[j] = t[j-1] + skip end
				if i ~= 258 then skip = skip * 2 end
			end
			t[285] = 258
			tdecode_len_base = t
		end
		if not tdecode_len_nextrabits then
			local t = {}
			for i=257,285 do
				local j = math.max(i - 261, 0)
				t[i] = rshift(j, 2)
			end
			t[285] = 0
			tdecode_len_nextrabits = t
		end
		local len_base = tdecode_len_base[val]
		local nextrabits = tdecode_len_nextrabits[val]
		local extrabits = bs:read(nextrabits)
		local len = len_base + extrabits

		if not tdecode_dist_base then
			local t = {[0]=1}
			local skip = 1
			for i=1,29,2 do
				for j=i,i+1 do t[j] = t[j-1] + skip end
				if i ~= 1 then skip = skip * 2 end
			end
			tdecode_dist_base = t
		end
		if not tdecode_dist_nextrabits then
			local t = {}
			for i=0,29 do
				local j = math.max(i - 2, 0)
				t[i] = rshift(j, 1)
			end
			tdecode_dist_nextrabits = t
		end
		local dist_val = disttable:read(bs)
		local dist_base = tdecode_dist_base[dist_val]
		local dist_nextrabits = tdecode_dist_nextrabits[dist_val]
		local dist_extrabits = bs:read(dist_nextrabits)
		local dist = dist_base + dist_extrabits

		for i=1,len do
			local pos = (outstate.window_pos - 1 - dist) % 32768 + 1	-- 32K
			output(outstate, assert(outstate.window[pos], 'invalid distance'))
		end
	end
	return false
end

local function parse_block(bs, outstate)                      ----583
	local bfinal = bs:read(1)
	local btype = bs:read(2)

	local BTYPE_NO_COMPRESSION = 0
	local BTYPE_FIXED_HUFFMAN = 1
	local BTYPE_DYNAMIC_HUFFMAN = 2
	local BTYPE_RESERVED_ = 3

	if DEBUG then
		debug('bfinal=', bfinal)
		debug('btype=', btype)
	end

	if btype == BTYPE_NO_COMPRESSION then
		bs:read(bs:nbits_left_in_byte())
		local len = bs:read(16)
		local nlen_ = noeof(bs:read(16), 7)

		for i=1,len do
			local by = noeof(bs:read(8), 8)
			output(outstate, by)
		end
	elseif btype == BTYPE_FIXED_HUFFMAN or btype == BTYPE_DYNAMIC_HUFFMAN then
		local littable, disttable
		if btype == BTYPE_DYNAMIC_HUFFMAN then
			littable, disttable = parse_huffmantables(bs)
		else
			littable	= HuffmanTable {0,8, 144,9, 256,7, 280,8, 288,nil}
			disttable = HuffmanTable {0,5, 32,nil}
		end

		repeat
			local is_done = parse_compressed_item(
				bs, outstate, littable, disttable)
		until is_done
	else
		error 'unrecognized compression type'
	end

	return bfinal ~= 0
end

function inflate(t)                                  ----627
	local bs = get_bitstream(t.input)
	local outbs = get_obytestream(t.output)
	local outstate = make_outstate(outbs)

	repeat
		local is_final = parse_block(bs, outstate)
	until is_final
end

function inflate_zlib(t)
	local bs = get_bitstream(t.input)
	local outbs = get_obytestream(t.output)
	local window_size_ = parse_zlib_header(bs)
	local data_adler32 = 1
	inflate{input=bs, output=outbs}
	bs:read(bs:nbits_left_in_byte())
	
	local b3 = bs:read(8)
	local b2 = bs:read(8)
	local b1 = bs:read(8)
	local b0 = bs:read(8)
	if bs:read() then
		warn 'trailing garbage ignored'
	end
end


--
-- libPNGimage by TehSomeLuigi
-- Revision: 1
--
-- A library to load, edit and save PNGs for OpenComputers
--

--[[
	
	Feel free to use however you wish.
	This header must however be preserved should this be redistributed, even
	if in a modified form.
	
	This software comes with no warranties whatsoever.
	
	2014 TehSomeLuigi

]]--
local PNGImage = {}                                    ----1
local PNGImagemetatable = {}
PNGImagemetatable.__index = PNGImage

local function __unpack_msb_uint32(s)                  ----56
	local a,b,c,d = s:byte(1,#s)
	local num = (((a*256) + b) * 256 + c) * 256 + d
	return num
end

-- Read 32-bit unsigned integer (most-significant-byte, MSB, first) from file.
local function __read_msb_uint32(fh)                                               ----110
	return __unpack_msb_uint32(fh:read(4))
end

-- Read unsigned byte (integer) from file
local function __read_byte(fh)                       ----115
	return fh:read(1):byte()
end

local function getBitWidthPerPixel(ihdr)             ----121
	if ihdr.color_type == 0 then -- Greyscale
		return ihdr.bit_depth
	end
	if ihdr.color_type == 2 then -- Truecolour
		return ihdr.bit_depth * 3
	end
	if ihdr.color_type == 3 then -- Indexed-colour
		return ihdr.bit_depth
	end
	if ihdr.color_type == 4 then -- Greyscale + Alpha
		return ihdr.bit_depth * 2
	end
	if ihdr.color_type == 6 then -- Truecolour + Alpha
		return ihdr.bit_depth * 4
	end
end

local function getByteWidthPerScanline(ihdr)         ----139
	return math.ceil((ihdr.width * getBitWidthPerPixel(ihdr)) / 8)
end

local outssmt = {}                                     ----143

function outssmt:__call(write)
	self.str = self.str .. string.char(write)
end

function outssmt.OutStringStream()
	local outss = {str=""}
	setmetatable(outss, outssmt)
	return outss
end

local function __parse_IHDR(fh, len)                 ----158
	if len ~= 13 then
		error("PNG IHDR Corrupt - should be 13 bytes long")
	end
	
	local ihdr = {}
	
	ihdr.width = __read_msb_uint32(fh)
	ihdr.height = __read_msb_uint32(fh)
	ihdr.bit_depth = __read_byte(fh)
	ihdr.color_type = __read_byte(fh)
	ihdr.compression_method = __read_byte(fh)
	ihdr.filter_method = __read_byte(fh)
	ihdr.interlace_method = __read_byte(fh)
		
	return ihdr
end

local function __parse_IDAT(fh, len, commeth, outss)   ----206
	if commeth ~= 0 then
		error("Only zlib/DEFLATE compression supported")
	end
	local input = fh:read(len)
	local cfg = {input=input, output=outss, disable_crc=true}
	inflate_zlib(cfg)
	return true
end

local function getPNGStdByteAtXY(ihdr, oss, x, y)               ----237
	local bpsl = getByteWidthPerScanline(ihdr) -- don't include filterType byte -- we don't store that after it has been read
	if (x <= 0) or (y <= 0) then
		return 0 -- this is what the spec says we should return when the coordinate is out of bounds -- in this part of the code, the coordinates are ONE-BASED like in good Lua
	end
	local offset_by_y = (y - 1) * bpsl
	-- now read it!
	local idx = offset_by_y + x
	return oss.str:sub(idx, idx):byte()
end

local function __paeth_predictor(a, b, c) --249
	local p = a + b - c
	local pa = math.abs(p - a)
	local pb = math.abs(p - b)
	local pc = math.abs(p - c)
	if pa <= pb and pa <= pc then
		return a
	elseif pb <= pc then
		return b
	else
		return c
	end
end

local function __parse_IDAT_effective_bytes(outss, ihdr)    ----265
	local bpsl = getByteWidthPerScanline(ihdr)
	local bypsl = math.ceil(getBitWidthPerPixel(ihdr) / 8)
	
	if outss.str:len() == 0 then
		error("Empty string: outss")
	end
	
	local bys = bytestream_from_string(outss.str)
	
	if not bys then
		error("Did not get a bytestream from string", bys, outss)
	end
	
	local out2 = outssmt.OutStringStream() -- __callable table with metatable that stores what you give it
	
	local y = 0
	
	-- x the byte being filtered;
	-- a the byte corresponding to x in the pixel immediately before the pixel containing x (or the byte immediately before x, when the bit depth is less than 8);
	-- b the byte corresponding to x in the previous scanline;
	-- c the byte corresponding to b in the pixel immediately before the pixel containing b (or the byte immediately before b, when the bit depth is less than 8).
	
	while true do
		local filterType = bys:read()
		if filterType == nil then
			break
		end
		y = y + 1
		for x = 1, bpsl do
			local a = getPNGStdByteAtXY(ihdr, out2, x - bypsl, y)
			local b = getPNGStdByteAtXY(ihdr, out2, x, y - 1)
			local c = getPNGStdByteAtXY(ihdr, out2, x - bypsl, y - 1)
			
			local outVal = 0
			
			if filterType == 0 then outVal = bys:read()
			elseif filterType == 1 then outVal = bys:read() + a
			elseif filterType == 2 then outVal = bys:read() + b
			elseif filterType == 3 then outVal = bys:read() + math.floor((a + b) / 2)
			elseif filterType == 4 then outVal = bys:read() + __paeth_predictor(a, b, c)
			else
				error("Unsupported Filter Type: " .. tostring(filterType))
			end
			outVal = outVal % 256
			out2(outVal)
		end
	end
	
	return out2
end

-- Warning: Co-ordinates are Zero-based but strings are 1-based
function PNGImage:getByteOffsetForPixel(x, y)      ----498
	return (((y * self.ihdr.width) + x) * 4) + 1
end

function PNGImage:getPixel(x, y)
	local off = self:getByteOffsetForPixel(x, y)
	return self.data:byte(off, off + 3)
end
--[[
function PNGImage:setPixel(x, y, col)
	local off = self:getByteOffsetForPixel(x, y)
	self.data = table.concat({self.data:sub(1, off - 1), string.char(col[1], col[2], col[3], col[4]), self.data:sub(off + 4)})
end

function PNGImage:lineXAB(ax, y, bx, col)
	for x=ax, bx do
		self:setPixel(x, y, col)
	end
end

function PNGImage:lineYAB(x, ay, by, col)
	for y=ay, by do
		self:setPixel(x, y, col)
	end
end

function PNGImage:lineRectangleAB(ax, ay, bx, by, col)
	self:lineXAB(ax, ay, bx, col)
	self:lineXAB(ax, by, bx, col)
	self:lineYAB(ax, ay, by, col)
	self:lineYAB(bx, ay, by, col)
end

function PNGImage:fillRectangleAB(ax, ay, bx, by, col)
	for x=ax, bx do
		for y=ay, by do
			self:setPixel(x, y, col)
		end
	end
end

function PNGImage:saveToFile(fn)
	local fh = io.open(fn, 'wb')
	if not fh then
		error("Could not open for writing: " .. fn)
	end
	self:saveToFileHandle(fh)
	fh:close()
end

function PNGImage:generateRawIDATData(outbuf)
	for y = 0, self.ihdr.height - 1 do
		outbuf(0) -- filter type is 0 (Filt(x) = Orig(x))
		for x = 0, self.ihdr.width - 1 do
			local r, g, b, a = self:getPixel(x, y)
			outbuf(r)
			outbuf(g)
			outbuf(b)
			outbuf(a)
		end
	end
end
]]
function PNGImage:getSize()
	return self.ihdr.width, self.ihdr.height
end

local function newFromFile(fh)
	local fh = io.open(fh, 'rb')
	if not fh then
		error("Could not open PNG file")
	end
	local pngi = {}
	setmetatable(pngi, PNGImagemetatable)
	local expecting = "\137\080\078\071\013\010\026\010"
	if fh:read(8) ~= expecting then -- check the 8-byte PNG header exists
		error("Not a PNG file")
	end
	
	local ihdr
	
	local outss = outssmt.OutStringStream()
	
	while true do
		local len = __read_msb_uint32(fh)
		local stype = fh:read(4)
		if stype == 'IHDR' then
			ihdr, msg = __parse_IHDR(fh, len)
		elseif stype == 'IDAT' then
			local res, msg = __parse_IDAT(fh, len, ihdr.compression_method, outss)
		else
			fh:read(len) -- dummy read
		end
		local crc = __read_msb_uint32(fh)
		if stype == 'IEND' then
			break
		end
	end
	
	fh:close()
	
	if ihdr.filter_method ~= 0 then
		error("Unsupported Filter Method: " .. ihdr.filter_method)
	end
	
	if ihdr.interlace_method ~= 0 then
		error("Unsupported Interlace Method (Interlacing is currently unsupported): " .. ihdr.interlace_method)
	end
	
	if ihdr.color_type ~= 6 --[[TruecolourAlpha]] and ihdr.color_type ~= 2 --[[Truecolour]] then
		error("Currently, only Truecolour and Truecolour+Alpha images are supported.")
	end
	
	if ihdr.bit_depth ~= 8 then
		error("Currently, only images with a bit depth of 8 are supported.")
	end
		
	-- now parse the IDAT chunks
	local out2 = __parse_IDAT_effective_bytes(outss, ihdr)
	
	if ihdr.color_type == 2 --[[Truecolour]] then
		-- add an alpha layer so it effectively becomes RGBA, not RGB
		local inp = out2.str
		out2 = outssmt.OutStringStream()
		
		for i=1, ihdr.width*ihdr.height do
			local b = ((i - 1)*3) + 1
			out2(inp:byte(b)) -- R
			out2(inp:byte(b + 1)) -- G
			out2(inp:byte(b + 2)) -- B
			out2(255) -- A
		end
	end
	
	pngi.ihdr = ihdr
	pngi.data = out2.str
	
	return pngi
end

------------------ End of libPNGImage ----------------------------

function graffiti.load(path)
  checkArg(1,path, "string")
  local success, pngImageOrErrorMessage = pcall(newFromFile, path)
  if not success then
    io.stderr:write(" * PNGView: PNG Loading Error *\n")
    io.stderr:write("While attempting to load '" .. path .. "' as PNG, libPNGImage erred:\n")
    error(pngImageOrErrorMessage)
  end
  return pngImageOrErrorMessage
end

function graffiti.draw(pic,x,y,SizeX,SizeY)
  checkArg(1,pic,"string","table")
  checkArg(2, x, "number")
  checkArg(3, y, "number")
  checkArg(4, SizeX, "number","nil")
  checkArg(5, SizeY, "number","nil")
  if type(pic)=="string" then pic=graffiti.load(pic) end
  
  local function alpha(col,r,g,b,a)
    if a and a > 0 then
      local b0=col % 256
      col=math.floor(col/256)
      local r0, g0 = math.floor(col/256), col % 256
      r0=math.floor(r0+(r-r0)*a/255+0.5)
      g0=math.floor(g0+(g-g0)*a/255+0.5)
      b0=math.floor(b0+(b-b0)*a/255+0.5)
      return (r0*256 + g0)*256 + b0
    end
	return col
  end
  
  local function interpolation(x,y)
    local x,xf=math.modf(x)
    local y,yf=math.modf(y)
	local r1,g1,b1,a1=pic:getPixel(x,y)
    local r4,g4,b4,a4=r1,g1,b1,a1
	local r0,g0,b0,a0=r1,g1,b1,a1
	if xf>0 then
	  local r2,g2,b2,a2=pic:getPixel(x+1,y)
	  if a2 and a2>0 then
	  r4,g4,b4,a4=r4-r2,g4-g2,b4-b2,a4-a2
	  r0,g0,b0,a0=r0+(r2-r1)*xf,g0+(g2-g1)*xf,b0+(b2-b1)*xf,a0+(a2-a1)*xf
	  end
	end
	if yf>0 then
	  local r3,g3,b3,a3=pic:getPixel(x,y+1)
	  if a3 and a3>0 then
	  r4,g4,b4,a4=r4-r3,g4-g3,b4-b3,a4-a3
	  r0,g0,b0,a0=r0+(r3-r1)*yf,g0+(g3-g1)*yf,b0+(b3-b1)*yf,a0+(a3-a1)*yf
	  end
	end
	if xf>0 and yf>0 then
	  local r5,g5,b5,a5=pic:getPixel(x+1,y+1)
	  if a5 and a5>0 then
	  r0,g0,b0,a0=r0+(r4+r5)*xf*yf,g0+(g4+g5)*xf*yf,b0+(b4+b5)*xf*yf,a0+(a4+a5)*xf*yf
	  end
	end
    return r0,g0,b0,a0
  end
    
  local width, height = pic:getSize()
  SizeX=SizeX or width
  SizeY=SizeY or SizeX*height/width
  SizeX=math.floor(SizeX+0.5)
  SizeY=math.floor(SizeY+0.5)
  if SizeX<=1 or SizeY<=1 then return end
  local Fc, Bc = gpu.getForeground(), gpu.getBackground()
  maxX,maxY=gpu.getResolution()
  local ScaleX,ScaleY=(width-1)/(SizeX-1), (height-1)/(SizeY-1)
  local startX,stopX=math.max(1,2-x),math.min(SizeX,maxX-x+1)
  for j=y % 2,SizeY,2 do
    local yy=(y+j)/2
    if yy>=1 and yy<=maxY then
      for i=startX,stopX do
	    local xx=x+i-1
        local c,F,B = gpu.get(xx,yy)
        if c~="▄" then F=B end
        gpu.setForeground(alpha(F, interpolation((i-1)*ScaleX, j*ScaleY)))
        gpu.setBackground(alpha(B, interpolation((i-1)*ScaleX, (j-1)*ScaleY)))
        gpu.set(xx,yy,"▄")
	  end
	end
  end
  gpu.setForeground(Fc)
  gpu.setBackground(Bc)
end

function graffiti.gradient(...)
  local pngi = {}
  setmetatable(pngi, PNGImagemetatable)
  pngi.ihdr={
	width = 2,
	height = 2,
	bit_depth = 8,
	color_type = 6,
	compression_method = 0,
	filter_method = 0,
	interlace_method = 0
  }
  local out2 = outssmt.OutStringStream()
  local Args={...}
  for i=1,4 do
    local col=Args[i]
    checkArg(i, col, "number")
    local b0=col % 256
    col=math.floor(col/256)
	out2(math.floor(col/256)) -- R
	out2(col % 256) -- G
	out2(b0) -- B
	out2(255) -- A
  end
  pngi.data=out2.str
  return pngi
end

return graffiti