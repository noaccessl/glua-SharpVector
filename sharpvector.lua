--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	SharpVector
	 A GLua implementation of Vector
	 with rigorous optimization & high precision because Lua numbers are doubles.

	 GitHub: https://github.com/noaccessl/glua-SharpVector

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metatables
--
local VectorMeta = FindMetaTable( 'Vector' )

local MatrixMeta = FindMetaTable( 'VMatrix' )

--
-- Metamethods
--
local VectorUnpack = VectorMeta.Unpack

--
-- Shared functions
--
local getmetatable = getmetatable
local Format = string.format
local tonumber = tonumber

local NewVector = _G.Vector
local NewAngle = _G.Angle


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Optimized isstring
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local fastisstring; do

	local StringMeta = getmetatable( '' )

	function fastisstring( any ) return getmetatable( any ) == StringMeta end

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Optimized isvector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function fastisvector( any ) return getmetatable( any ) == VectorMeta end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Optimized isnumber
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function fastisnumber( any ) return tonumber( any ) ~= nil end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Optimized ismatrix
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local fastismatrix

if ( MatrixMeta ~= nil ) then
	function fastismatrix( any ) return getmetatable( any ) == MatrixMeta end
else
	function fastismatrix() return false end
end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Preallocated SharpVectors, Vectors, and Angles (Part 1/2)

	Purpose:
	 Make obtaining a new Vector, SharpVector, or Angle at runtime as fast as possible;
	 at least over a short range of calls.

	Note:
	 Preallocation amount initially is a presumed number.
	 Use SharpVector_SetPreallocationAmount() to regulate it.
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local RetrieveFreeUnit

local PerformPreallocation
-- ^ For now just headers for the future functions

local TempSharpVectors = { [0] = 0 }
local TempGModVectors = { [0] = 0 }
local TempAngles = { [0] = 0 }

TempSharpVectors.__prealloc_amount_per_tick = 16
TempGModVectors.__prealloc_amount_per_tick = 1
TempAngles.__prealloc_amount_per_tick = 1


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Common/important definitions, constants, variables
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local CLASSNAME = 'SharpVector'

local FORMAT_SHARPVECTOR = 'SharpVector( %.7f, %.7f, %.7f )'

local DBL_EPSILON = 2 ^ -52

local RNGSEED_INDEX = -1

local TRANSLATE_KEY_TO_COMPONENT = {

	x = 1; X = 1; r = 1;
	y = 2; Y = 2; g = 2;
	z = 3; Z = 3; b = 3

}
-- For the proper translation of a passed key to the correspondent component


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	The class SharpVector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local NewSharpVector -- For now just a header for the future function
local issharpvector -- same as above

local CSharpVector = FindMetaTable( CLASSNAME ) or {}
do

	-- Shared function
	local VectorSetUnpacked = VectorMeta.SetUnpacked


	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		tostring-metamethod
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function CSharpVector:__tostring()

		return Format( FORMAT_SHARPVECTOR, self[1], self[2], self[3] )

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		newindex-metamethod
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	function CSharpVector:__newindex( key, value )

		self[TRANSLATE_KEY_TO_COMPONENT[key]] = value

	end

	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		eq-metamethod
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	local rawequal = rawequal

	function CSharpVector:__eq( any )

		if ( issharpvector( any ) ) then

			local other = any
			return self[1] == other[1] and self[2] == other[2] and self[3] == other[3]

		end

		return rawequal( self, any )

	end


	-- The main methods
	do

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			SetUnpacked
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:SetUnpacked( x, y, z )

			self[1], self[2], self[3] = x, y, z

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Set
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Set( sharpvec )

			self[1], self[2], self[3] = sharpvec[1], sharpvec[2], sharpvec[3]

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			SetGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:SetGModVector( vec )

			self[1], self[2], self[3] = VectorUnpack( vec )

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Zero
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Zero()

			self[1], self[2], self[3] = 0, 0, 0

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Negate
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Negate()

			self[1], self[2], self[3] = -self[1], -self[2], -self[3]

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			GetNegated
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:GetNegated()

			local sharpvec = NewSharpVector()

			sharpvec[1], sharpvec[2], sharpvec[3] = -self[1], -self[2], -self[3]

			return sharpvec

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Unpack
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Unpack()

			return self[1], self[2], self[3]

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Add
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Add( sharpvec )

			self[1], self[2], self[3] = self[1] + sharpvec[1], self[2] + sharpvec[2], self[3] + sharpvec[3]

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			AddGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:AddGModVector( vec )

			local x2, y2, z2 = VectorUnpack( vec )
			self[1], self[2], self[3] = self[1] + x2, self[2] + y2, self[3] + z2

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Sub
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Sub( sharpvec )

			self[1], self[2], self[3] = self[1] - sharpvec[1], self[2] - sharpvec[2], self[3] - sharpvec[3]

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			SubGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:SubGModVector( vec )

			local x2, y2, z2 = VectorUnpack( vec )
			self[1], self[2], self[3] = self[1] - x2, self[2] - y2, self[3] - z2

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Mul
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		local MatrixUnpack = MatrixMeta ~= nil and MatrixMeta.Unpack or nil

		function CSharpVector:Mul( arg )

			if ( fastisnumber( arg ) ) then

				local multiplier = arg
				self[1], self[2], self[3] = self[1] * multiplier, self[2] * multiplier, self[3] * multiplier

				return

			end

			if ( issharpvector( arg ) ) then

				local sharpvec = arg
				self[1], self[2], self[3] = self[1] * sharpvec[1], self[2] * sharpvec[2], self[3] * sharpvec[3]

				return

			end

			if ( fastismatrix( arg ) ) then

				local matrix = arg

				local x, y, z = self[1], self[2], self[3]

				local e11, e12, e13, e14,
					e21, e22, e23, e24,
					e31, e32, e33, e34 = MatrixUnpack( matrix )

				x = e11 * x + e12 * y + e13 * z + e14
				y = e21 * x + e22 * y + e23 * z + e24
				z = e31 * x + e32 * y + e33 * z + e34

				self[1], self[2], self[3] = x, y, z

			end

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			MulByGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:MulByGModVector( vec )

			local x2, y2, z2 = VectorUnpack( vec )
			self[1], self[2], self[3] = self[1] * x2, self[2] * y2, self[3] * z2

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Div
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Div( arg )

			if ( fastisnumber( arg ) ) then

				local divisor_i = 1 / arg
				self[1], self[2], self[3] = self[1] * divisor_i, self[2] * divisor_i, self[3] * divisor_i

				return

			end

			local sharpvec = arg
			self[1], self[2], self[3] = self[1] / sharpvec[1], self[2] / sharpvec[2], self[3] / sharpvec[3]

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			DivByGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:DivByGModVector( vec )

			local x2, y2, z2 = VectorUnpack( vec )
			self[1], self[2], self[3] = self[1] / x2, self[2] / y2, self[3] / z2

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Length
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Length()

			local x, y, z = self[1], self[2], self[3]
			return ( x * x + y * y + z * z ) ^ 0.5

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			LengthSqr
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:LengthSqr()

			local x, y, z = self[1], self[2], self[3]
			return x * x + y * y + z * z

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Length2D
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Length2D()

			local x, y = self[1], self[2]
			return ( x * x + y * y ) ^ 0.5

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Length2DSqr
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Length2DSqr()

			local x, y = self[1], self[2]
			return x * x + y * y

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Distance
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Distance( sharpvec )

			local x, y, z = self[1], self[2], self[3]
			local x2, y2, z2 = sharpvec[1], sharpvec[2], sharpvec[3]

			local x_delta, y_delta, z_delta = x - x2, y - y2, z - z2

			return ( x_delta * x_delta + y_delta * y_delta + z_delta * z_delta ) ^ 0.5

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			DistToSqr
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:DistToSqr( sharpvec )

			local x, y, z = self[1], self[2], self[3]
			local x2, y2, z2 = sharpvec[1], sharpvec[2], sharpvec[3]

			local x_delta, y_delta, z_delta = x - x2, y - y2, z - z2

			return x_delta * x_delta + y_delta * y_delta + z_delta * z_delta

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Distance2D
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Distance2D( sharpvec )

			local x, y = self[1], self[2]
			local x2, y2 = sharpvec[1], sharpvec[2]

			local x_delta, y_delta = x - x2, y - y2

			return ( x_delta * x_delta + y_delta * y_delta ) ^ 0.5

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Distance2DSqr
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Distance2DSqr( sharpvec )

			local x, y = self[1], self[2]
			local x2, y2 = sharpvec[1], sharpvec[2]

			local x_delta, y_delta = x - x2, y - y2

			return x_delta * x_delta + y_delta * y_delta

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Normalize
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Normalize()

			local x, y, z = self[1], self[2], self[3]

			local flLength = ( x * x + y * y + z * z ) ^ 0.5
			local flLength_i = 1 / ( flLength + DBL_EPSILON )

			self[1], self[2], self[3] = x * flLength_i, y * flLength_i, z * flLength_i

			return flLength

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			GetNormalized
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:GetNormalized()

			local x, y, z = self[1], self[2], self[3]

			local flLength = ( x * x + y * y + z * z ) ^ 0.5
			local flLength_i = 1 / ( flLength + DBL_EPSILON )

			local sharpvec = NewSharpVector()

			sharpvec[1], sharpvec[2], sharpvec[3] = x * flLength_i, y * flLength_i, z * flLength_i

			return sharpvec

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Dot
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Dot( sharpvec )

			return self[1] * sharpvec[1] + self[2] * sharpvec[2] + self[3] * sharpvec[3]

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Cross
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Cross( sharpvec, sharpvecOutput )

			local x, y, z = self[1], self[2], self[3]
			local x2, y2, z2 = sharpvec[1], sharpvec[2], sharpvec[3]

			local x3 = y * z2 - z * y2
			local y3 = z * x2 - x * z2
			local z3 = x * y2 - y * x2

			if ( sharpvecOutput ) then

				sharpvecOutput[1], sharpvecOutput[2], sharpvecOutput[3] = x3, y3, z3
				return

			end

			return NewSharpVector( x3, y3, z3 )

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			IsEqualTol
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		local mathabs = math.abs

		function CSharpVector:IsEqualTol( sharpvec, tolerance )

			tolerance = tolerance or DBL_EPSILON

			if ( mathabs( self[1] - sharpvec[1] ) > tolerance ) then return false end
			if ( mathabs( self[2] - sharpvec[2] ) > tolerance ) then return false end

			return mathabs( self[3] - sharpvec[3] ) <= tolerance

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			IsZero
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:IsZero()

			return self[1] == 0 and self[2] == 0 and self[3] == 0

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			ToScreen

			Note:
			 This one is stripped down because GLua implementation of Vector:ToScreen
			 probably will take about as much space as all this code,
			 so it ain't worthwhile or resourceful.
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		if ( CLIENT_DLL ) then

			local VectorToScreen = VectorMeta.ToScreen

			local g_vecProxy = NewVector()

			function CSharpVector:ToScreen()

				VectorSetUnpacked( g_vecProxy, self[1], self[2], self[3] )
				return VectorToScreen( g_vecProxy )

			end

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			ToColor
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		if ( not MENU_DLL ) then

			local NewColor = _G.Color

			function CSharpVector:ToColor( colOutput )

				local r, g, b = self[1] * 255, self[2] * 255, self[3] * 255

				if ( colOutput ) then

					colOutput.r, colOutput.g, colOutput.b = r, g, b
					return

				end

				return NewColor( r, g, b )

			end

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			ToTable
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:ToTable( output )

			if ( output ) then

				output[1], output[2], output[3] = self[1], self[2], self[3]
				return

			end

			return { self[1]; self[2]; self[3] }

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			AsGModVector
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:AsGModVector( vecOutput )

			if ( vecOutput ) then

				VectorSetUnpacked( vecOutput, self[1], self[2], self[3] )
				return

			end

			local vec = RetrieveFreeUnit( TempGModVectors, NewVector )
			VectorSetUnpacked( vec, self[1], self[2], self[3] )

			return vec

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Random
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		local mathrandomseed = math.randomseed
		local mathrandom = math.random

		function CSharpVector:Random( min, max )

			local iRNGSeed = self[RNGSEED_INDEX]

			if ( iRNGSeed == RNGSEED_INDEX ) then

				-- Form a unique RNG seed for this vector
				iRNGSeed = tonumber( Format( '%p', self ) )
				self[RNGSEED_INDEX] = iRNGSeed

			end

			mathrandomseed( iRNGSeed )

			local diff = max - min

			self[1] = min + diff * mathrandom()
			self[2] = min + diff * mathrandom()
			self[3] = min + diff * mathrandom()

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			WithinAABox
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:WithinAABox( sharpvecBoxMins, sharpvecBoxMaxs )

			local x, y, z = self[1], self[2], self[3]
			local mins_x, mins_y, mins_z = sharpvecBoxMins[1], sharpvecBoxMins[2], sharpvecBoxMins[3]
			local maxs_x, maxs_y, maxs_z = sharpvecBoxMaxs[1], sharpvecBoxMaxs[2], sharpvecBoxMaxs[3]

			return ( x >= mins_x ) and ( x <= maxs_x ) and
				( y >= mins_y ) and ( y <= maxs_y ) and
				( z >= mins_z ) and ( z <= maxs_z )

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			(Internal) VectorAngles; VectorAnglesEx
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		local VectorAngles
		local VectorAnglesEx

		do

			local mathatan2 = math.atan2
			local RAD2DEG = 180 / math.pi

			local AngleSetUnpacked = FindMetaTable( 'Angle' ).SetUnpacked

			function VectorAngles( sharpvecForward, angOutput )

				local yaw, pitch

				local x, y, z = sharpvecForward[1], sharpvecForward[2], sharpvecForward[3]

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

				AngleSetUnpacked( angOutput, pitch, yaw, 0 )

			end

			function VectorAnglesEx( sharpvecForward, sharpvecRefUp, angOutput )

				local fwd_x, fwd_y, fwd_z = sharpvecForward[1], sharpvecForward[2], sharpvecForward[3]
				local refup_x, refup_y, refup_z = sharpvecRefUp[1], sharpvecRefUp[2], sharpvecRefUp[3]

				local left_x, left_y, left_z = 0, 0, 0 -- decomposed into upvalues abstract vector

				--
				-- sharpvecRefUp:Cross( sharpvecForward, left )
				--
				left_x = refup_y * fwd_z - refup_z * fwd_y
				left_y = refup_z * fwd_x - refup_x * fwd_z
				left_z = refup_x * fwd_y - refup_y * fwd_x

				--
				-- left:Normalize()
				--
				local flLength = ( left_x * left_x + left_y * left_y + left_z * left_z ) ^ 0.5
				local flLength_i = 1 / ( flLength + DBL_EPSILON )

				left_x, left_y, left_z = left_x * flLength_i, left_y * flLength_i, left_z * flLength_i

				local xyDist = ( fwd_x * fwd_x + fwd_y * fwd_y ) ^ 0.5

				local pitch, yaw, roll

				if ( xyDist > 0.001 ) then

					yaw = mathatan2( fwd_y, fwd_x ) * RAD2DEG
					pitch = mathatan2( -fwd_z, xyDist ) * RAD2DEG

					local up_z = ( left_y * fwd_x ) - ( left_x * fwd_y )
					roll = mathatan2( left_z, up_z ) * RAD2DEG

				else

					yaw = mathatan2( -left_x, left_y ) * RAD2DEG
					pitch = mathatan2( -fwd_z, xyDist ) * RAD2DEG
					roll = 0

				end

				AngleSetUnpacked( angOutput, pitch, yaw, roll )

			end

		end

		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Angle; AngleEx
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		function CSharpVector:Angle( angOutput )

			if ( angOutput ) then

				VectorAngles( self, angOutput )
				return

			end

			angOutput = RetrieveFreeUnit( TempAngles, NewAngle )
			VectorAngles( self, angOutput )

			return angOutput

		end

		function CSharpVector:AngleEx( up, angOutput )

			if ( angOutput ) then

				VectorAnglesEx( self, up, angOutput )
				return

			end

			angOutput = RetrieveFreeUnit( TempAngles, NewAngle )
			VectorAnglesEx( self, up, angOutput )

			return angOutput

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Rotate
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		do

			local AngleUnpack = FindMetaTable( 'Angle' ).Unpack

			local sin = math.sin
			local cos = math.cos

			local DEG2RAD = math.pi / 180

			-- 3x3 matrix decomposed into upvalues
			local e11, e12, e13 = 0, 0, 0
			local e21, e22, e23 = 0, 0, 0
			local e31, e32, e33 = 0, 0, 0

			function CSharpVector:Rotate( ang, sharpvecOutput )

				sharpvecOutput = sharpvecOutput or self

				do

					local sp, sy, sr
					local cp, cy, cr

					local pitch, yaw, roll = AngleUnpack( ang )
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

				end

				local x, y, z = sharpvecOutput[1], sharpvecOutput[2], sharpvecOutput[3]

				sharpvecOutput[1] = x * e11 + y * e12 + z * e13
				sharpvecOutput[2] = x * e21 + y * e22 + z * e23
				sharpvecOutput[3] = x * e31 + y * e32 + z * e33

			end

		end


		--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
			Lerp
		–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
		local PerformLerp = Lerp

		function CSharpVector:Lerp( sharpvecTarget, fraction, sharpvecOutput )

			local x, y, z = self[1], self[2], self[3]
			local x2, y2, z2 = sharpvecTarget[1], sharpvecTarget[2], sharpvecTarget[3]

			local x3 = PerformLerp( fraction, x, x2 )
			local y3 = PerformLerp( fraction, y, y2 )
			local z3 = PerformLerp( fraction, z, z2 )

			if ( sharpvecOutput ) then

				sharpvecOutput[1], sharpvecOutput[2], sharpvecOutput[3] = x3, y3, z3
				return

			end

			local sharpvec = NewSharpVector()

			sharpvec[1], sharpvec[2], sharpvec[3] = x3, y3, z3

			return sharpvec

		end

	end


	--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
		Support for arithmetic operators

		Note:
		 Creating SharpVector is slower than Vector;
		 so if you're gonna frequently and numerously use arithmetic operators,
		 perhaps you'll have to raise preallocation amount
		 if high performance is a priority there.

		 By and large, using metamethods is the optimal option.
	–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
	do

		CSharpVector.__add = function( a, b )

			local sharpvec = NewSharpVector()

			sharpvec[1], sharpvec[2], sharpvec[3] = a[1] + b[1], a[2] + b[2], a[3] + b[3]

			return sharpvec

		end

		CSharpVector.__sub = function( a, b )

			local sharpvec = NewSharpVector()

			sharpvec[1], sharpvec[2], sharpvec[3] = a[1] - b[1], a[2] - b[2], a[3] - b[3]

			return sharpvec

		end

		CSharpVector.__mul = function( a, b )

			local sharpvec = NewSharpVector()

			if ( fastisnumber( b ) ) then

				local multiplier = b
				sharpvec[1], sharpvec[2], sharpvec[3] = a[1] * multiplier, a[2] * multiplier, a[3] * multiplier

				return sharpvec

			end

			sharpvec[1], sharpvec[2], sharpvec[3] = a[1] * b[1], a[2] * b[2], a[3] * b[3]

			return sharpvec

		end

		CSharpVector.__div = function( a, b )

			local sharpvec = NewSharpVector()

			if ( fastisnumber( b ) ) then

				local divisor_i = 1 / b
				sharpvec[1], sharpvec[2], sharpvec[3] = a[1] * divisor_i, a[2] * divisor_i, a[3] * divisor_i

				return sharpvec

			end

			sharpvec[1], sharpvec[2], sharpvec[3] = a[1] / b[1], a[2] / b[2], a[3] / b[3]

			return sharpvec

		end

		CSharpVector.__unm = function( self )

			local sharpvec = NewSharpVector()

			sharpvec[1], sharpvec[2], sharpvec[3] = -self[1], -self[2], -self[3]

			return sharpvec

		end

	end


	-- Store the class in the registry
	RegisterMetaTable( CLASSNAME, CSharpVector )

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Returns if the passed object is an SharpVector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function issharpvector( any )

	return getmetatable( any ) == CSharpVector

end

_G.issharpvector = issharpvector


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose:
	 Fallback-index-metamethod in case a component is accessed
	 via other but correspondent key
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function fnComponentAccessor( thisproxy, key )

	return thisproxy.__vector[TRANSLATE_KEY_TO_COMPONENT[key]]

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Generates a proxy for the class

	Note:
	 This is done intentionally to make accessing a metamethod
	 at runtime as fast as possible.
	 A priori and a posteriori, the use of metamethods is prioritized.
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local GenerateClassProxy; do

	local setmetatable = setmetatable
	local next = next

	local g_classproxy_mt = { __index = fnComponentAccessor }

	function GenerateClassProxy( sharpvec )

		-- Generate a proxy
		local classproxy = { __vector = sharpvec }

		-- Make components accessible via other but correspondent keys
		setmetatable( classproxy, g_classproxy_mt )

		-- Copy the original class
		for k, v in next, CSharpVector do classproxy[k] = v end

		-- Make it refer to itself
		classproxy.__index = classproxy

		-- Redirect to the original class
		classproxy.__metatable = CSharpVector

		return classproxy

	end

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Creates a new SharpVector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local CreateSharpVector; do

	local setmetatable = setmetatable

	function CreateSharpVector()

		-- Create an object
		local sharpvec = { 0; 0; 0; [RNGSEED_INDEX] = RNGSEED_INDEX }

		-- Initialize the object
		setmetatable( sharpvec, GenerateClassProxy( sharpvec ) )

		return sharpvec

	end

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Preallocated SharpVectors, Vectors, and Angles (Part 2/2)
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
do

	function RetrieveFreeUnit( pTable, pfnFallbackUnitCreator )

		local i = pTable[0]

		if ( i == 0 ) then
			return pfnFallbackUnitCreator()
		end

		local pUnit = pTable[i]

		if ( not pUnit ) then
			return pfnFallbackUnitCreator()
		end

		pTable[i] = nil
		pTable[0] = i - 1

		return pUnit

	end


	function PerformPreallocation( pTable, pfnUnitCreator )

		local i, amount = pTable[0], pTable.__prealloc_amount_per_tick

		if ( i ~= amount ) then

			::alloc::
			i = i + 1

				pTable[i] = pfnUnitCreator()
				pTable[0] = i

			if ( i ~= amount ) then goto alloc end

		end

	end

	local function Timer_SharpVector_Preallocation()

		PerformPreallocation( TempSharpVectors, CreateSharpVector )
		PerformPreallocation( TempGModVectors, NewVector )
		PerformPreallocation( TempAngles, NewAngle )

	end

	timer.Create( 'SharpVector_Preallocation', 0, 0, Timer_SharpVector_Preallocation )


	function SharpVector_SetPreallocationAmount( num1, num2, num3 )

		if ( num1 == nil ) then num1 = 16 end
		if ( num2 == nil ) then num2 = 1 end
		if ( num3 == nil ) then num3 = 1 end

		--
		-- Free some memory if indexes exceed the new limits
		--
		for i = TempSharpVectors[0], num1 + 1, -1 do TempSharpVectors[i] = nil end
		for i = TempGModVectors[0], num2 + 1, -1 do TempGModVectors[i] = nil end
		for i = TempAngles[0], num3 + 1, -1 do TempAngles[i] = nil end

		--
		-- Clamp
		--
		TempSharpVectors[0] = math.min( TempSharpVectors[0], num1 )
		TempGModVectors[0] = math.min( TempGModVectors[0], num2 )
		TempAngles[0] = math.min( TempAngles[0], num3 )

		--
		-- Update
		--
		TempSharpVectors.__prealloc_amount_per_tick = num1
		TempGModVectors.__prealloc_amount_per_tick = num2
		TempAngles.__prealloc_amount_per_tick = num3

		--
		-- Fill
		--
		PerformPreallocation( TempSharpVectors, CreateSharpVector )
		PerformPreallocation( TempGModVectors, NewVector )
		PerformPreallocation( TempAngles, NewAngle )

	end

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: (Internal) Attempts to extract x, y, and z from the passed argument(-s)
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local ExtractXYZ; do

	local strmatch = string.match

	function ExtractXYZ( arg, ... )

		if ( fastisnumber( arg ) ) then

			local x, y, z = arg, ...
			return x, y or 0, z or 0

		end

		if ( issharpvector( arg ) ) then

			local sharpvec = arg
			return sharpvec[1], sharpvec[2], sharpvec[3]

		end

		if ( fastisstring( arg ) ) then

			local x, y, z = strmatch( arg, '(-?%d+.?%d*),? (-?%d+.?%d*),? (-?%d+.?%d*)' )
			-- Works both with Vector-string and SharpVector-string

			if ( not x ) then
				return 0, 0, 0
			end

			return tonumber( x ), tonumber( y ), tonumber( z )

		end

		if ( fastisvector( arg ) ) then

			local vec = arg
			return VectorUnpack( vec )

		end

	end

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Gets a new SharpVector
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function NewSharpVector( arg, ... )

	local sharpvec = RetrieveFreeUnit( TempSharpVectors, CreateSharpVector )

	if ( arg ) then
		sharpvec[1], sharpvec[2], sharpvec[3] = ExtractXYZ( arg, ... )
	end

	return sharpvec

end



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Finish
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
PerformPreallocation( TempSharpVectors, CreateSharpVector )
PerformPreallocation( TempGModVectors, NewVector )
PerformPreallocation( TempAngles, NewAngle )

_G.SharpVector = NewSharpVector

--
-- Extend Vector's functionality
--
function VectorMeta:Sharpened()

	return NewSharpVector( VectorUnpack( self ) )

end
