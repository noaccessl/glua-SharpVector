--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	SharpVector (https://github.com/noaccessl/glua-SharpVector)
	 A GLua implementation of Vector.
     Featuring rigid optimization & precise calculations due to components being doubles.

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Important shared variables
--
local g_VectorMeta = FindMetaTable( 'Vector' )

--
-- Metamethods: Vector
--
local VectorUnpack = g_VectorMeta.Unpack

--
-- Functions
--
local getmetatable = getmetatable
local Format = string.format
local tonumber = tonumber

local NewVector = Vector
local NewAngle = _G.Angle


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Optimized isstring
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_StringMeta = getmetatable( '' )

local function fastisstring( any ) return getmetatable( any ) == g_StringMeta end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Optimized isvector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function fastisvector( any ) return getmetatable( any ) == g_VectorMeta end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Optimized isnumber
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function fastisnumber( any ) return tonumber( any ) ~= nil end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Preallocated Vectors: 1/2 (+Angles)

	Note #1:
		This is done to make obtaining new (sharp-)vector at the moment as fast as possible.
		At least over a small range of calls.

	Note #2:
		Multiplying by tickrate because preallocation delay is set to 1 second
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
-- do

	local TICKRATE_CEILED = math.ceil( 1 / engine.TickInterval() )

	local g_TempSharpVectors = {

		prealloc_amount = 16 --[[presumed amount of new sharp vectors per tick]] * TICKRATE_CEILED

	}

	local g_TempGModVectors = {

		prealloc_amount = 1 --[[presumed amount of new GMod vectors per tick]] * TICKRATE_CEILED

	}

	local g_TempAngles = {

		prealloc_amount = 1 --[[presumed amount of new angles per tick]] * TICKRATE_CEILED

	}

	local INDEX_SHARPVEC = 0
	local INDEX_GMODVEC = 0
	local INDEX_ANGLE = 0

	local function PreallocateGModVectors()

		if ( INDEX_GMODVEC == g_TempGModVectors.prealloc_amount ) then
			return
		end

		for i = INDEX_GMODVEC == 0 and 1 or INDEX_GMODVEC, g_TempGModVectors.prealloc_amount do

			if ( not g_TempGModVectors[i] ) then

				INDEX_GMODVEC = INDEX_GMODVEC + 1
				g_TempGModVectors[INDEX_GMODVEC] = NewVector( 0, 0, 0 )

			end

		end

	end

	local function AllocGModVector()

		local vec = g_TempGModVectors[INDEX_GMODVEC]

		if ( not vec ) then
			return NewVector( 0, 0, 0 )
		end

		g_TempGModVectors[INDEX_GMODVEC] = nil
		INDEX_GMODVEC = INDEX_GMODVEC - 1

		return vec

	end

	local function PreallocateAngles()

		if ( INDEX_ANGLE == g_TempAngles.prealloc_amount ) then
			return
		end

		for i = INDEX_ANGLE == 0 and 1 or INDEX_ANGLE, g_TempAngles.prealloc_amount do

			if ( not g_TempAngles[i] ) then

				INDEX_ANGLE = INDEX_ANGLE + 1
				g_TempAngles[INDEX_ANGLE] = NewAngle( 0, 0, 0 )

			end

		end

	end

	local function AllocAngle()

		local ang = g_TempAngles[INDEX_ANGLE]

		if ( not ang ) then
			return NewAngle( 0, 0, 0 )
		end

		g_TempAngles[INDEX_ANGLE] = nil
		INDEX_ANGLE = INDEX_ANGLE - 1

		return ang

	end

-- end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Common definitions
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local CLASSNAME = 'SharpVector'

local FORMAT_SHARPVECTOR = 'SharpVector( %.7f, %.7f, %.7f )'


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Constants
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local DBL_EPSILON = 2 ^ -52


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: A common storage for every vector's components
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local VEC_T = setmetatable( {}, { __mode = 'k' } )

local VEC_T_RNGSEED = -1

local INDEXING_TRANSLATE_COMPONENT = {

	['x'] = 1;
	['y'] = 2;
	['z'] = 3;
	[1] = 1;
	[2] = 2;
	[3] = 3;

}


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Class SharpVector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local SharpVector -- Create-function Header

local CSharpVector = FindMetaTable( CLASSNAME ) or {}
do

	local fastisnumber = fastisnumber
	local mathabs = math.abs

	local VectorUnpack = VectorUnpack
	local VectorSetUnpacked = g_VectorMeta.SetUnpacked


	local VEC_T = VEC_T
	local DBL_EPSILON = DBL_EPSILON

	local vector_temp = NewVector()


	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		tostring-metamethod
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	local Format = Format
	local FORMAT_SHARPVECTOR = FORMAT_SHARPVECTOR

	CSharpVector.__tostring = function( this )

		local vec_t = VEC_T[this]
		return Format( FORMAT_SHARPVECTOR, vec_t[1], vec_t[2], vec_t[3] )

	end


	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		newindex-metamethod
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	CSharpVector.newindex = function( this, component, value )

		VEC_T[this][INDEXING_TRANSLATE_COMPONENT[component]] = value

	end


	-- do

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			SetUnpacked
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.SetUnpacked( this, x, y, z )

			local vec_t = VEC_T[this]
			vec_t[1], vec_t[2], vec_t[3] = x, y, z

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Zero
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Zero( this )

			local vec_t = VEC_T[this]
			vec_t[1], vec_t[2], vec_t[3] = 0, 0, 0

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Negate
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Negate( this )

			local vec_t = VEC_T[this]
			vec_t[1], vec_t[2], vec_t[3] = -vec_t[1], -vec_t[2], -vec_t[3]

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			GetNegated
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.GetNegated( this )

			local vec_t = VEC_T[this]
			return SharpVector( -vec_t[1], -vec_t[2], -vec_t[3] )

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Unpack
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Unpack( this )

			local vec_t = VEC_T[this]
			return vec_t[1], vec_t[2], vec_t[3]

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Set
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Set( this, sharpvecOther )

			local vec_t = VEC_T[this]
			local vec2_t = VEC_T[sharpvecOther]

			vec_t[1], vec_t[2], vec_t[3] = vec2_t[1], vec2_t[2], vec2_t[3]

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			SetGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.SetGModVector( this, vec )

			local vec_t = VEC_T[this]
			vec_t[1], vec_t[2], vec_t[3] = VectorUnpack( vec )

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Add
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Add( this, sharpvecOther )

			local vec_t = VEC_T[this]
			local vec2_t = VEC_T[sharpvecOther]

			vec_t[1], vec_t[2], vec_t[3] = vec_t[1] + vec2_t[1], vec_t[2] + vec2_t[2], vec_t[3] + vec2_t[3]

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			AddGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.AddGModVector( this, vec )

			local vec_t = VEC_T[this]
			local x2, y2, z2 = VectorUnpack( vec )

			vec_t[1], vec_t[2], vec_t[3] = vec_t[1] + x2, vec_t[2] + y2, vec_t[3] + z2

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Sub
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Sub( this, sharpvecOther )

			local vec_t = VEC_T[this]
			local vec2_t = VEC_T[sharpvecOther]

			vec_t[1], vec_t[2], vec_t[3] = vec_t[1] - vec2_t[1], vec_t[2] - vec2_t[2], vec_t[3] - vec2_t[3]

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			SubGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.SubGModVector( this, vec )

			local vec_t = VEC_T[this]
			local x2, y2, z2 = VectorUnpack( vec )

			vec_t[1], vec_t[2], vec_t[3] = vec_t[1] - x2, vec_t[2] - y2, vec_t[3] - z2

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Mul
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Mul( this, arg )

			if ( fastisnumber( arg ) ) then

				local multiplier = arg

				local vec_t = VEC_T[this]
				vec_t[1], vec_t[2], vec_t[3] = vec_t[1] * multiplier, vec_t[2] * multiplier, vec_t[3] * multiplier

			else

				local sharpvecOther = arg

				local vec_t = VEC_T[this]
				local vec2_t = VEC_T[sharpvecOther]

				vec_t[1], vec_t[2], vec_t[3] = vec_t[1] * vec2_t[1], vec_t[2] * vec2_t[2], vec_t[3] * vec2_t[3]

			end

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			MulByGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.MulByGModVector( this, vec )

			local vec_t = VEC_T[this]
			local x2, y2, z2 = VectorUnpack( vec )

			vec_t[1], vec_t[2], vec_t[3] = vec_t[1] * x2, vec_t[2] * y2, vec_t[3] * z2

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			MulByMatrix
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		local g_MatrixMeta = FindMetaTable( 'VMatrix' )

		if ( g_MatrixMeta ) then

			local MatrixUnpack = g_MatrixMeta.Unpack

			function CSharpVector.MulByMatrix( this, matrix )

				local vec_t = VEC_T[this]

				local x, y, z = vec_t[1], vec_t[2], vec_t[3]

				local e11, e12, e13, e14,
					e21, e22, e23, e24,
					e31, e32, e33, e34 = MatrixUnpack( matrix )

				x = e11 * x + e12 * y + e13 * z + e14
				y = e21 * x + e22 * y + e23 * z + e24
				z = e31 * x + e32 * y + e33 * z + e34

				vec_t[1], vec_t[2], vec_t[3] = x, y, z

			end

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Div
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Div( this, arg )

			if ( fastisnumber( arg ) ) then

				local divisor_Inv = 1 / arg

				local vec_t = VEC_T[this]
				vec_t[1], vec_t[2], vec_t[3] = vec_t[1] * divisor_Inv, vec_t[2] * divisor_Inv, vec_t[3] * divisor_Inv

			else

				local sharpvecOther = arg

				local vec_t = VEC_T[this]
				local vec2_t = VEC_T[sharpvecOther]

				vec_t[1], vec_t[2], vec_t[3] = vec_t[1] / vec2_t[1], vec_t[2] / vec2_t[2], vec_t[3] / vec2_t[3]

			end

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			DivByGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.DivByGModVector( this, vec )

			local vec_t = VEC_T[this]
			local x2, y2, z2 = VectorUnpack( vec )

			vec_t[1], vec_t[2], vec_t[3] = vec_t[1] / x2, vec_t[2] / y2, vec_t[3] / z2

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Length
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Length( this )

			local vec_t = VEC_T[this]
			local x, y, z = vec_t[1], vec_t[2], vec_t[3]

			return ( x * x + y * y + z * z ) ^ 0.5

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			LengthSqr
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.LengthSqr( this )

			local vec_t = VEC_T[this]
			local x, y, z = vec_t[1], vec_t[2], vec_t[3]

			return x * x + y * y + z * z

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Length2D
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Length2D( this )

			local vec_t = VEC_T[this]
			local x, y = vec_t[1], vec_t[2]

			return ( x * x + y * y ) ^ 0.5

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Length2DSqr
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Length2DSqr( this )

			local vec_t = VEC_T[this]
			local x, y = vec_t[1], vec_t[2]

			return x * x + y * y

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Distance
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Distance( this, sharpvecOther )

			local vec_t = VEC_T[this]
			local vec2_t = VEC_T[sharpvecOther]

			local x, y, z = vec_t[1], vec_t[2], vec_t[3]
			local x2, y2, z2 = vec2_t[1], vec2_t[2], vec2_t[3]

			local x_delta, y_delta, z_delta = x - x2, y - y2, z - z2

			return ( x_delta * x_delta + y_delta * y_delta + z_delta * z_delta ) ^ 0.5

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			DistToSqr
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.DistToSqr( this, sharpvecOther )

			local vec_t = VEC_T[this]
			local vec2_t = VEC_T[sharpvecOther]

			local x, y, z = vec_t[1], vec_t[2], vec_t[3]
			local x2, y2, z2 = vec2_t[1], vec2_t[2], vec2_t[3]

			local x_delta, y_delta, z_delta = x - x2, y - y2, z - z2

			return x_delta * x_delta + y_delta * y_delta + z_delta * z_delta

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Distance2D
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Distance2D( this, sharpvecOther )

			local vec_t = VEC_T[this]
			local vec2_t = VEC_T[sharpvecOther]

			local x, y = vec_t[1], vec_t[2]
			local x2, y2 = vec2_t[1], vec2_t[2]

			local x_delta, y_delta = x - x2, y - y2

			return ( x_delta * x_delta + y_delta * y_delta ) ^ 0.5

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Distance2DSqr
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Distance2DSqr( this, sharpvecOther )

			local vec_t = VEC_T[this]
			local vec2_t = VEC_T[sharpvecOther]

			local x, y = vec_t[1], vec_t[2]
			local x2, y2 = vec2_t[1], vec2_t[2]

			local x_delta, y_delta = x - x2, y - y2

			return x_delta * x_delta + y_delta * y_delta

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Normalize
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Normalize( this )

			local vec_t = VEC_T[this]
			local x, y, z = vec_t[1], vec_t[2], vec_t[3]

			local flLength = ( x * x + y * y + z * z ) ^ 0.5
			local flLength_Inv = 1 / ( flLength + DBL_EPSILON )

			vec_t[1], vec_t[2], vec_t[3] = x * flLength_Inv, y * flLength_Inv, z * flLength_Inv

			return flLength

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			GetNormalized
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.GetNormalized( this )

			local vec_t = VEC_T[this]
			local x, y, z = vec_t[1], vec_t[2], vec_t[3]

			local flLength_Inv = 1 / ( ( x * x + y * y + z * z ) ^ 0.5 + DBL_EPSILON )

			return SharpVector( x * flLength_Inv, y * flLength_Inv, z * flLength_Inv )

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Dot
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Dot( this, sharpvecOther )

			local vec_t = VEC_T[this]
			local vec2_t = VEC_T[sharpvecOther]

			return vec_t[1] * vec2_t[1] + vec_t[2] * vec2_t[2] + vec_t[3] * vec2_t[3]

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Cross
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Cross( this, sharpvecOther, sharpvecOut )

			local vec_t = VEC_T[this]
			local vec2_t = VEC_T[sharpvecOther]

			local x, y, z = vec_t[1], vec_t[2], vec_t[3]
			local x2, y2, z2 = vec2_t[1], vec2_t[2], vec2_t[3]

			local x3 = y * z2 - z * y2
			local y3 = z * x2 - x * z2
			local z3 = x * y2 - y * x2

			if ( sharpvecOut ) then

				local vec3_t = VEC_T[sharpvecOut]
				vec3_t[1], vec3_t[2], vec3_t[3] = x3, y3, z3

				return

			end

			return SharpVector( x3, y3, z3 )

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			IsEqualTol
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.IsEqualTol( this, sharpvecCompare, tolerance )

			tolerance = tolerance or DBL_EPSILON

			local vec_t = VEC_T[this]
			local vec2_t = VEC_T[sharpvecCompare]

			if ( mathabs( vec_t[1] - vec2_t[1] ) > tolerance ) then
				return false
			end

			if ( mathabs( vec_t[2] - vec2_t[2] ) > tolerance ) then
				return false
			end

			return mathabs( vec_t[3] - vec2_t[3] ) <= tolerance

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			IsZero
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.IsZero( this )

			local vec_t = VEC_T[this]
			return vec_t[1] == 0 and vec_t[2] == 0 and vec_t[3] == 0

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			ToScreen

			Note:
				This one is stripped down
				because GLua implementation of Vector:ToScreen
				probably will be larger than all this code without it,
				so it's not worth it
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		if ( CLIENT_DLL ) then

			local VectorToScreen = g_VectorMeta.ToScreen

			function CSharpVector.ToScreen( this )

				local vec_t = VEC_T[this]
				VectorSetUnpacked( vector_temp, vec_t[1], vec_t[2], vec_t[3] )

				return VectorToScreen( vector_temp )

			end

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			ToColor
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		if ( not MENU_DLL ) then

			local NewColor = _G.Color

			function CSharpVector.ToColor( this, colOut )

				local vec_t = VEC_T[this]
				local r, g, b = vec_t[1] * 255, vec_t[2] * 255, vec_t[3] * 255

				if ( colOut ) then

					colOut.r, colOut.g, colOut.b = r, g, b
					return

				else
					return NewColor( r, g, b )
				end

			end

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			ToTable
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.ToTable( this, output )

			local vec_t = VEC_T[this]

			if ( output ) then

				output[1], output[2], output[3] = vec_t[1], vec_t[2], vec_t[3]
				return

			end

			return { vec_t[1], vec_t[2], vec_t[3] }

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			ToGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.ToGModVector( this, vecOut )

			local vec_t = VEC_T[this]

			if ( vecOut ) then

				VectorSetUnpacked( vecOut, vec_t[1], vec_t[2], vec_t[3] )
				return

			end

			local vec = AllocGModVector()
			VectorSetUnpacked( vec, vec_t[1], vec_t[2], vec_t[3] )

			return vec

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Random
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		local mathrandomseed = math.randomseed
		local mathrandom = math.random

		local VEC_T_RNGSEED = VEC_T_RNGSEED

		function CSharpVector.Random( this, min, max )

			local vec_t = VEC_T[this]

			mathrandomseed( vec_t[VEC_T_RNGSEED] )

			local diff = max - min

			vec_t[1] = min + diff * mathrandom()
			vec_t[2] = min + diff * mathrandom()
			vec_t[3] = min + diff * mathrandom()

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			WithinAABox
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.WithinAABox( this, sharpvecBoxMins, sharpvecBoxMaxs )

			local vec_t = VEC_T[this]
			local mins_t = VEC_T[sharpvecBoxMins]
			local maxs_t = VEC_T[sharpvecBoxMaxs]

			local x, y, z = vec_t[1], vec_t[2], vec_t[3]
			local x_min, y_min, z_min = mins_t[1], mins_t[2], mins_t[3]
			local x_max, y_max, z_max = maxs_t[1], maxs_t[2], maxs_t[3]

			return ( x >= x_min ) and ( x <= x_max ) and
				( y >= y_min ) and ( y <= y_max ) and
				( z >= z_min ) and ( z <= z_max )

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			VectorAngles; VectorAnglesEx (calculations algorithms are from Source SDK)
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		local mathatan2 = math.atan2
		local RAD2DEG = 180 / math.pi

		local AngleSetUnpacked = FindMetaTable( 'Angle' ).SetUnpacked

		local function VectorAngles( sharpvecForward, angleOut )

			local yaw, pitch

			local vec_t = VEC_T[sharpvecForward]
			local x, y, z = vec_t[1], vec_t[2], vec_t[3]

			if ( y == 0 and x == 0 ) then

				yaw = 0

				if ( z > 0 ) then
					pitch = 270
				else
					pitch = 90
				end

			else

				yaw = mathatan2( y, x ) * RAD2DEG

				if ( yaw < 0 ) then
					yaw = yaw + 360
				end

				pitch = mathatan2( -z, ( x * x + y * y ) ^ 0.5 ) * RAD2DEG

				if ( pitch < 0 ) then
					pitch = pitch + 360
				end

			end

			AngleSetUnpacked( angleOut, pitch, yaw, 0 )

		end

		local x_left, y_left, z_left = 0, 0, 0

		local function VectorAnglesEx( sharpvecForward, sharpvecRefUp, angleOut )

			local vec_t = VEC_T[sharpvecForward]
			local refup_t = VEC_T[sharpvecRefUp]

			local x_fwd, y_fwd, z_fwd = vec_t[1], vec_t[2], vec_t[3]
			local x_refup, y_refup, z_refup = refup_t[1], refup_t[2], refup_t[3]

			--
			-- sharpvecRefUp:Cross( sharpvecForward, left )
			--
			x_left = y_refup * z_fwd - z_refup * y_fwd
			y_left = z_refup * x_fwd - x_refup * z_fwd
			z_left = x_refup * y_fwd - y_refup * x_fwd

			--
			-- left:Normalize()
			--
			local flLength_Inv = 1 / ( ( x_left * x_left + y_left * y_left + z_left * z_left ) ^ 0.5 + DBL_EPSILON )
			x_left, y_left, z_left = x_left * flLength_Inv, y_left * flLength_Inv, z_left * flLength_Inv

			local xyDist = ( x_fwd * x_fwd + y_fwd * y_fwd ) ^ 0.5

			local pitch, yaw, roll

			if ( xyDist > 0.001 ) then

				yaw = mathatan2( y_fwd, x_fwd ) * RAD2DEG
				pitch = mathatan2( -z_fwd, xyDist ) * RAD2DEG

				local z_up = ( y_left * x_fwd ) - ( x_left * y_fwd )

				roll = mathatan2( z_left, z_up ) * RAD2DEG

			else

				yaw = mathatan2( -x_left, y_left ) * RAD2DEG
				pitch = mathatan2( -z_fwd, xyDist ) * RAD2DEG
				roll = 0

			end

			AngleSetUnpacked( angleOut, pitch, yaw, roll )

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Angle; AngleEx
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector.Angle( this, angleOut )

			if ( angleOut ) then

				VectorAngles( this, angleOut )
				return

			end

			angleOut = AllocAngle()
			VectorAngles( this, angleOut )

			return angleOut

		end

		function CSharpVector.AngleEx( this, up, angleOut )

			if ( angleOut ) then

				VectorAnglesEx( this, up, angleOut )
				return

			end

			angleOut = AllocAngle()
			VectorAnglesEx( this, up, angleOut )

			return angleOut

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Rotate
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		local AngleUnpack = FindMetaTable( 'Angle' ).Unpack

		local sin = math.sin
		local cos = math.cos

		local DEG2RAD = math.pi / 180

		-- 3x3 Raw Matrix decomposed into locals for fast access
		local e11, e12, e13 = 0, 0, 0
		local e21, e22, e23 = 0, 0, 0
		local e31, e32, e33 = 0, 0, 0

		function CSharpVector.Rotate( this, angle, sharpvecOut )

			sharpvecOut = sharpvecOut or this

			-- do

				local sp, sy, sr
				local cp, cy, cr

				local pitch, yaw, roll = AngleUnpack( angle )
				pitch, yaw, roll = pitch * DEG2RAD, yaw * DEG2RAD, roll * DEG2RAD

				sp, sy, sr = sin( pitch ), sin( yaw ), sin( roll )
				cp, cy, cr = cos( pitch ), cos( yaw ), cos( roll )

				e11 = cp * cy
				e21 = cp * sy
				e31 = -sp

				local crcy = cr * cy
				local crsy = cr * sy
				local srcy = sr * cy
				local srsy = sr * sy

				e12 = sp * srcy - crsy
				e22 = sp * srsy + crcy
				e32 = sr * cp

				e13 = sp * crcy + srsy
				e23 = sp * crsy - srcy
				e33 = cr * cp

			-- end

			local vec_t = VEC_T[sharpvecOut]
			local x, y, z = vec_t[1], vec_t[2], vec_t[3]

			vec_t[1] = x * e11 + y * e12 + z * e13
			vec_t[2] = x * e21 + y * e22 + z * e23
			vec_t[3] = x * e31 + y * e32 + z * e33

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Lerp
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		local PerformLerp = _G.Lerp

		function CSharpVector.Lerp( this, sharpvecTarget, fraction, sharpvecOut )

			local vec_t = VEC_T[this]
			local vec2_t = VEC_T[sharpvecTarget]

			local x, y, z = vec_t[1], vec_t[2], vec_t[3]
			local x2, y2, z2 = vec2_t[1], vec2_t[2], vec2_t[3]

			local x3 = PerformLerp( fraction, x, x2 )
			local y3 = PerformLerp( fraction, y, y2 )
			local z3 = PerformLerp( fraction, z, z2 )

			if ( sharpvecOut ) then

				local vec3_t = VEC_T[sharpvecOut]
				vec3_t[1], vec3_t[2], vec3_t[3] = x3, y3, z3

				return

			end

			return SharpVector( x3, y3, z3 )

		end

	-- end


	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Support for arithmetic operators

		Note:
			Creating a new SharpVector is much more expensive than Vector
			So if you're gonna frequently and numerously use arithmetic operators with sharp vectors,
			you will probably have to raise preallocation amount.

			Also, retrieving allocated SharpVector is also not that fast,
			it's somewhat faster than creating a new Vector.

			Overall, in most cases, using metamethods is the optimal option.
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	-- do

		CSharpVector.__add = function( a, b )

			local vec_t = VEC_T[a]
			local vec2_t = VEC_T[b]

			return SharpVector( vec_t[1] + vec2_t[1], vec_t[2] + vec2_t[2], vec_t[3] + vec2_t[3] )

		end

		CSharpVector.__sub = function( a, b )

			local vec_t = VEC_T[a]
			local vec2_t = VEC_T[b]

			return SharpVector( vec_t[1] - vec2_t[1], vec_t[2] - vec2_t[2], vec_t[3] - vec2_t[3] )

		end

		CSharpVector.__mul = function( this, arg )

			if ( fastisnumber( arg ) ) then

				local multiplier = arg

				local vec_t = VEC_T[this]
				return SharpVector( vec_t[1] * multiplier, vec_t[2] * multiplier, vec_t[3] * multiplier )

			else

				local sharpvecOther = arg

				local vec_t = VEC_T[this]
				local vec2_t = VEC_T[sharpvecOther]

				return SharpVector( vec_t[1] * vec2_t[1], vec_t[2] * vec2_t[2], vec_t[3] * vec2_t[3] )

			end

		end

		CSharpVector.__div = function( this, arg )

			if ( fastisnumber( arg ) ) then

				local divisor_Inv = 1 / arg

				local vec_t = VEC_T[this]
				return SharpVector( vec_t[1] * divisor_Inv, vec_t[2] * divisor_Inv, vec_t[3] * divisor_Inv )

			else

				local sharpvecOther = arg

				local vec_t = VEC_T[this]
				local vec2_t = VEC_T[sharpvecOther]

				return SharpVector( vec_t[1] / vec2_t[1], vec_t[2] / vec2_t[2], vec_t[3] / vec2_t[3] )

			end

		end

		CSharpVector.__unm = function( this )

			local vec_t = VEC_T[this]
			return SharpVector( -vec_t[1], -vec_t[2], -vec_t[3] )

		end

	-- end


	-- Store the meta in the registry
	RegisterMetaTable( CLASSNAME, CSharpVector )

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Returns if the passed object is an SharpVector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_SharpVectorMetaID = CSharpVector.MetaID

function issharpvector( any )

	local any_mt = getmetatable( any )

	if ( any_mt ) then
		return any_mt.MetaID == g_SharpVectorMetaID
	end

	return false

end

local issharpvector = issharpvector


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Accepts the passed arguments and extracts x, y, z
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local GetXYZ do

	local strmatch = string.match

	function GetXYZ( arg, ... )

		if ( not arg ) then
			return 0, 0, 0
		end

		if ( fastisnumber( arg ) ) then

			local x, y, z = arg, ...
			return x, y or 0, z or 0

		end

		if ( issharpvector( arg ) ) then

			local vec_t = VEC_T[arg]
			return vec_t[1], vec_t[2], vec_t[3]

		end

		if ( fastisstring( arg ) ) then

			-- Supports both Vector-string and SharpVector-string
			local x, y, z = strmatch( arg, '(-?%d+.?%d*),? (-?%d+.?%d*),? (-?%d+.?%d*)' )

			if ( not x ) then
				return 0, 0, 0
			end

			return tonumber( x ), tonumber( y ), tonumber( z )

		end

		if ( fastisvector( arg ) ) then
			return VectorUnpack( arg )
		end

	end

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	ComponentsAccessor
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function ComponentsAccessor( thisMeta, component )

	local vec_t = VEC_T[thisMeta.m_MyVector]

	return vec_t[INDEXING_TRANSLATE_COMPONENT[component]]

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Generates a proxy for the class

	Note:
		This is done intentionally to make access to metamethod at the moment as fast as possible.
		A priori and a posteriori, the use of metamethods is prioritized.
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local GenerateClassProxy do

	local SetUnpacked = CSharpVector.SetUnpacked
	local Zero = CSharpVector.Zero
	local Negate = CSharpVector.Negate
	local GetNegated = CSharpVector.GetNegated
	local Unpack = CSharpVector.Unpack

	local Set = CSharpVector.Set
	local SetGModVector = CSharpVector.SetGModVector

	local Add = CSharpVector.Add
	local AddGModVector = CSharpVector.AddGModVector
	local Sub = CSharpVector.Sub
	local SubGModVector = CSharpVector.SubGModVector
	local Mul = CSharpVector.Mul
	local MulByGModVector = CSharpVector.MulByGModVector
	local MulByMatrix = CSharpVector.MulByMatrix
	local Div = CSharpVector.Div
	local DivByGModVector = CSharpVector.DivByGModVector

	local Length = CSharpVector.Length
	local LengthSqr = CSharpVector.LengthSqr
	local Length2D = CSharpVector.Length2D
	local Length2DSqr = CSharpVector.Length2DSqr

	local Distance = CSharpVector.Distance
	local DistToSqr = CSharpVector.DistToSqr
	local Distance2D = CSharpVector.Distance2D
	local Distance2DSqr = CSharpVector.Distance2DSqr

	local Normalize = CSharpVector.Normalize
	local GetNormalized = CSharpVector.GetNormalized

	local Dot = CSharpVector.Dot
	local Cross = CSharpVector.Cross

	local IsEqualTol = CSharpVector.IsEqualTol
	local IsZero = CSharpVector.IsZero

	local ToScreen = CSharpVector.ToScreen
	local ToColor = CSharpVector.ToColor
	local ToTable = CSharpVector.ToTable
	local ToGModVector = CSharpVector.ToGModVector

	local Random = CSharpVector.Random

	local WithinAABox = CSharpVector.WithinAABox

	local Angle = CSharpVector.Angle
	local AngleEx = CSharpVector.AngleEx

	local Rotate = CSharpVector.Rotate

	local Lerp = CSharpVector.Lerp

	local setmetatable = setmetatable
	local proxy_mt = { __index = ComponentsAccessor }

	function GenerateClassProxy( sharpvec )

		local proxy_class = {

			m_MyVector = sharpvec;

			SetUnpacked = SetUnpacked;
			Zero = Zero;
			Negate = Negate;
			GetNegated = GetNegated;
			Unpack = Unpack;

			Set = Set;
			SetGModVector = SetGModVector;

			Add = Add;
			AddGModVector = AddGModVector;
			Sub = Sub;
			SubGModVector = SubGModVector;
			Mul = Mul;
			MulByGModVector = MulByGModVector;
			MulByMatrix = MulByMatrix;
			Div = Div;
			DivByGModVector = DivByGModVector;

			Length = Length;
			LengthSqr = LengthSqr;
			Length2D = Length2D;
			Length2DSqr = Length2DSqr;

			Distance = Distance;
			DistToSqr = DistToSqr;
			Distance2D = Distance2D;
			Distance2DSqr = Distance2DSqr;

			Normalize = Normalize;
			GetNormalized = GetNormalized;

			Dot = Dot;
			Cross = Cross;

			IsEqualTol = IsEqualTol;
			IsZero = IsZero;

			ToScreen = ToScreen;
			ToColor = ToColor;
			ToTable = ToTable;
			ToGModVector = ToGModVector;

			Random = Random;

			WithinAABox = WithinAABox;

			Angle = Angle;
			AngleEx = AngleEx;

			Rotate = Rotate;

			Lerp = Lerp;

		}

		setmetatable( proxy_class, proxy_mt )

		return proxy_class

	end

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Establishes the given new SharpVector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local Sharpen do

	local MetaName = CSharpVector.MetaName
	local MetaID = CSharpVector.MetaID
	local __tostring = CSharpVector.__tostring
	local __newindex = CSharpVector.__newindex
	local __add = CSharpVector.__add
	local __sub = CSharpVector.__sub
	local __mul = CSharpVector.__mul
	local __div = CSharpVector.__div
	local __unm = CSharpVector.__unm

	local forcesetmetatable = debug.setmetatable

	function Sharpen( sharpvec, proxy_class )

		forcesetmetatable( sharpvec, {

			MetaName = MetaName;
			MetaID = MetaID;

			__tostring = __tostring;

			__index = proxy_class;
			__newindex = __newindex;

			__add = __add;
			__sub = __sub;
			__mul = __mul;
			__div = __div;
			__unm = __unm

		} )

	end

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Forms a unique RNG seed for the given vector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function FormRNGSeed( sharpvec )

	return tonumber( Format( '%p', sharpvec ) )

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Preallocated Vectors: 2/2
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
-- do

	local newproxy = newproxy

	function AllocSharpVector()

		local sharpvec = newproxy()

		local vec_t = { 0; 0; 0 }
		vec_t[VEC_T_RNGSEED] = FormRNGSeed( sharpvec )

		VEC_T[sharpvec] = vec_t

		local proxy_class = GenerateClassProxy( sharpvec )
		Sharpen( sharpvec, proxy_class )

		INDEX_SHARPVEC = INDEX_SHARPVEC + 1
		g_TempSharpVectors[INDEX_SHARPVEC] = sharpvec

		return sharpvec

	end

	local function PreallocateSharpVectors()

		if ( INDEX_SHARPVEC == g_TempSharpVectors.prealloc_amount ) then
			return
		end

		for i = INDEX_SHARPVEC == 0 and 1 or INDEX_SHARPVEC, g_TempSharpVectors.prealloc_amount do

			if ( not g_TempSharpVectors[i] ) then
				AllocSharpVector()
			end

		end

	end

	local function Timer_SharpVector_Preallocation()

		PreallocateSharpVectors()
		PreallocateGModVectors()
		PreallocateAngles()

	end

	Timer_SharpVector_Preallocation()
	timer.Create( 'SharpVector_Preallocation', 1, 0, Timer_SharpVector_Preallocation )

	function SharpVector_SetMaxPreallocAmount( num1, num2, num3 )

		if ( num1 == nil ) then
			num1 = 16 * TICKRATE_CEILED
		end

		if ( num2 == nil ) then
			num2 = 1 * TICKRATE_CEILED
		end

		if ( num3 == nil ) then
			num3 = 1 * TICKRATE_CEILED
		end

		--
		-- Free some memory if indexes exceed the new limits
		--
		for i = INDEX_SHARPVEC, num1 + 1, -1 do
			g_TempSharpVectors[i] = nil
		end

		for i = INDEX_GMODVEC, num2 + 1, -1 do
			g_TempGModVectors[i] = nil
		end

		for i = INDEX_ANGLE, num3 + 1, -1 do
			g_TempAngles[i] = nil
		end

		INDEX_SHARPVEC = math.min( INDEX_SHARPVEC, num1 )
		INDEX_GMODVEC = math.min( INDEX_GMODVEC, num2 )
		INDEX_ANGLE = math.min( INDEX_ANGLE, num3 )

		g_TempSharpVectors.prealloc_amount = num1
		g_TempGModVectors.prealloc_amount = num2
		g_TempAngles.prealloc_amount = num3

		Timer_SharpVector_Preallocation()

	end

-- end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Retrieves one preallocated or creates new SharpVector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function SharpVector( arg, ... )

	local sharpvec = g_TempSharpVectors[INDEX_SHARPVEC]

	if ( not sharpvec ) then
		sharpvec = AllocSharpVector()
	end

	g_TempSharpVectors[INDEX_SHARPVEC] = nil
	INDEX_SHARPVEC = INDEX_SHARPVEC - 1

	local vec_t = VEC_T[sharpvec]
	vec_t[1], vec_t[2], vec_t[3] = GetXYZ( arg, ... )

	return sharpvec

end

_G.SharpVector = SharpVector


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Extend Vector's functionality
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function g_VectorMeta:Sharpened()

	return SharpVector( VectorUnpack( self ) )

end
