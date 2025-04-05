
include( 'custom/gluafuncbudget.lua' )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
include( 'custom/sharpvector.lua' )

local Vector = Vector
local SharpVector = SharpVector

local RaisePreallocation

local Tests = {

	Create = {

		{ name = 'new Vector'; func = function()

			Vector()

		end; standard = true };

		{ name = 'new SharpVector'; setup = function()

			RaisePreallocation( 'sharpvec' )

		end; func = function()

			SharpVector()

		end }

	};

	SetUnpacked = {

		{ name = 'Vector:SetUnpacked'; setup = function()

			local vec = Vector()

			return vec

		end; func = function( vec )

			vec:SetUnpacked( 3.14, 1.618, 37 )

		end; standard = true };

		{ name = 'SharpVector:SetUnpacked'; setup = function()

			local sharpvec = SharpVector()

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:SetUnpacked( 3.14, 1.618, 37 )

		end }

	};
	Zero = {

		{ name = 'Vector:Zero'; setup = function()

			local vec = Vector()

			return vec

		end; func = function( vec )

			vec:Zero()

		end; standard = true };

		{ name = 'SharpVector:Zero'; setup = function()

			local sharpvec = SharpVector()

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:Zero()

		end }

	};
	Negate = {

		{ name = 'Vector:Negate'; setup = function()

			local vec = Vector( 1, 1, 1 )

			return vec

		end; func = function( vec )

			vec:Negate()

		end; standard = true };

		{ name = 'SharpVector:Negate'; setup = function()

			local sharpvec = SharpVector( 1, 1, 1 )

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:Negate()

		end }

	};
	GetNegated = {

		{ name = 'Vector:GetNegated'; setup = function()

			local vec = Vector( 1, 1, 1 )

			return vec

		end; func = function( vec )

			vec:GetNegated()

		end; standard = true };

		{ name = 'SharpVector:GetNegated'; setup = function()

			local sharpvec = SharpVector( 1, 1, 1 )

			RaisePreallocation( 'sharpvec' )

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:GetNegated()

		end }

	};
	Unpack = {

		{ name = 'Vector:Unpack'; setup = function()

			local vec = Vector( 3.14, 1.618, 37 )

			return vec

		end; func = function( vec )

			vec:Unpack()

		end; standard = true };

		{ name = 'SharpVector:Unpack'; setup = function()

			local sharpvec = SharpVector( 3.14, 1.618, 37 )

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:Unpack()

		end }

	};

	Set = {

		{ name = 'Vector:Set'; setup = function()

			local vec = Vector( 3.14, 1.618, 37 )
			local vec2 = Vector()

			return vec, vec2

		end; func = function( vec, vec2 )

			vec2:Set( vec )

		end; standard = true };

		{ name = 'SharpVector:Set'; setup = function()

			local sharpvec = SharpVector( 3.14, 1.618, 37 )
			local sharpvec2 = SharpVector()

			return sharpvec, sharpvec2

		end; func = function( sharpvec, sharpvec2 )

			sharpvec2:Set( sharpvec )

		end }

	};
	Add = {

		{ name = 'Vector:Add'; setup = function()

			local vec = Vector( 1, 1, 1 )
			local vec2 = Vector()

			return vec, vec2

		end; func = function( vec, vec2 )

			vec2:Add( vec )

		end; standard = true };

		{ name = 'SharpVector:Add'; setup = function()

			local sharpvec = SharpVector( 1, 1, 1 )
			local sharpvec2 = SharpVector()

			return sharpvec, sharpvec2

		end; func = function( sharpvec, sharpvec2 )

			sharpvec2:Add( sharpvec )

		end }

	};
	Mul = {

		{ name = 'Vector:Mul( multiplier )'; setup = function()

			local vec = Vector( 1, 1, 1 )

			return vec, 2.718

		end; func = function( vec, multiplier )

			vec:Mul( multiplier )

		end; standard = true };

		{ name = 'SharpVector:Mul( multiplier )'; setup = function()

			local sharpvec = SharpVector( 1, 1, 1 )

			return sharpvec, 2.718

		end; func = function( sharpvec, multiplier )

			sharpvec:Mul( multiplier )

		end };

		{ name = 'Vector:Mul( vector )'; setup = function()

			local vec = Vector( 1, 1, 1 )
			local vec2 = Vector( 2.718, 2.718, 2.718 )

			return vec, vec2

		end; func = function( vec, vec2 )

			vec:Mul( vec2 )

		end; standard = true };

		{ name = 'SharpVector:Mul( sharpvector )'; setup = function()

			local sharpvec = SharpVector( 1, 1, 1 )
			local sharpvec2 = SharpVector( 2.718, 2.718, 2.718 )

			return sharpvec, sharpvec2

		end; func = function( sharpvec, sharpvec2 )

			sharpvec:Mul( sharpvec2 )

		end }

	};

	Length = {

		{ name = 'Vector:Length'; setup = function()

			local vec = Vector( 3, 4, 5 )

			return vec

		end; func = function( vec )

			vec:Length()

		end; standard = true };

		{ name = 'SharpVector:Length'; setup = function()

			local sharpvec = SharpVector( 3, 4, 5 )

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:Length()

		end }

	};
	Distance = {

		{ name = 'Vector:Distance'; setup = function()

			local vec = Vector()
			local vec2 = Vector()

			vec:Random( -16384, 16384 )
			vec2:Random( -16384, 16384 )

			return vec, vec2

		end; func = function( vec, vec2 )

			vec:Distance( vec2 )

		end; standard = true };

		{ name = 'SharpVector:Distance'; setup = function()

			local sharpvec = SharpVector()
			local sharpvec2 = SharpVector()

			sharpvec:Random( -16384, 16384 )
			sharpvec2:Random( -16384, 16384 )

			return sharpvec, sharpvec2

		end; func = function( sharpvec, sharpvec2 )

			sharpvec:Distance( sharpvec2 )

		end }

	};

	Normalize = {

		{ name = 'Vector:Normalize'; setup = function()

			local vec = Vector( 3, 4, 5 )

			return vec

		end; func = function( vec )

			vec:Normalize()

		end; standard = true };

		{ name = 'SharpVector:Normalize'; setup = function()

			local sharpvec = SharpVector( 3, 4, 5 )

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:Normalize()

		end }

	};
	GetNormalized = {

		{ name = 'Vector:GetNormalized'; setup = function()

			local vec = Vector( 3, 4, 5 )

			return vec

		end; func = function( vec )

			vec:GetNormalized()

		end; standard = true };

		{ name = 'SharpVector:GetNormalized'; setup = function()

			local sharpvec = SharpVector( 3, 4, 5 )

			RaisePreallocation( 'sharpvec' )

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:GetNormalized()

		end }

	};

	Dot = {

		{ name = 'Vector:Dot'; setup = function()

			local vec = Vector( 0, 1, 0 )
			local vec2 = Vector( 0, -1, 0 )

			return vec, vec2

		end; func = function( vec, vec2 )

			vec:Dot( vec2 )

		end; standard = true };

		{ name = 'SharpVector:Dot'; setup = function()

			local sharpvec = SharpVector( 0, 1, 0 )
			local sharpvec2 = SharpVector( 0, -1, 0 )

			return sharpvec, sharpvec2

		end; func = function( sharpvec, sharpvec2 )

			sharpvec:Dot( sharpvec2 )

		end }

	};
	Cross = {

		{ name = 'Vector:Cross'; setup = function()

			local vecUp = Vector( 0, 0, 1 )
			local vecForward = Vector( 100, 0, 0 )

			return vecUp, vecForward

		end; func = function( vecUp, vecForward )

			vecUp:Cross( vecForward )

		end; standard = true };

		{ name = 'SharpVector:Cross'; setup = function()

			local sharpvecUp = SharpVector( 0, 0, 1 )
			local sharpvecForward = SharpVector( 100, 0, 0 )

			RaisePreallocation( 'sharpvec' )

			return sharpvecUp, sharpvecForward

		end; func = function( sharpvecUp, sharpvecForward )

			sharpvecUp:Cross( sharpvecForward )

		end };

		{ name = 'SharpVector:Cross; output specified'; setup = function()

			local sharpvecUp = SharpVector( 0, 0, 1 )
			local sharpvecForward = SharpVector( 100, 0, 0 )

			local out = SharpVector()

			return sharpvecUp, sharpvecForward, out

		end; func = function( sharpvecUp, sharpvecForward, out )

			sharpvecUp:Cross( sharpvecForward, out )

		end }

	};

	IsEqualTol = {

		{ name = 'Vector:IsEqualTol'; setup = function()

			local tolerance = 0.5

			local vec = Vector( 0, 0, 0 )
			local vec2 = Vector( 0, 0, tolerance * 2 )

			return vec, vec2, tolerance

		end; func = function( vec, vec2, tolerance )

			vec:IsEqualTol( vec2, tolerance )

		end; standard = true };

		{ name = 'SharpVector:IsEqualTol'; setup = function()

			local tolerance = 0.5

			local sharpvec = SharpVector( 0, 0, 0 )
			local sharpvec2 = SharpVector( 0, 0, tolerance * 2 )

			return sharpvec, sharpvec2, tolerance

		end; func = function( sharpvec, sharpvec2, tolerance )

			sharpvec:IsEqualTol( sharpvec2, tolerance )

		end }

	};
	IsZero = {

		{ name = 'Vector:IsZero'; setup = function()

			local vec = Vector( 0, 0, 0 )

			return vec

		end; func = function( vec )

			vec:IsZero()

		end; standard = true };

		{ name = 'SharpVector:IsZero'; setup = function()

			local sharpvec = SharpVector( 0, 0, 0 )

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:IsZero()

		end }

	};

	ToTable = {

		{ name = 'Vector:ToTable'; setup = function()

			local vec = Vector( 6.28, 0.382, 37 ^ 0.5 )

			return vec

		end; func = function( vec )

			vec:ToTable()

		end; standard = true };

		{ name = 'SharpVector:ToTable'; setup = function()

			local sharpvec = SharpVector( 6.28, 0.382, 37 ^ 0.5 )

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:ToTable()

		end };

		{ name = 'SharpVector:ToTable; output specified'; setup = function()

			local sharpvec = SharpVector( 6.28, 0.382, 37 ^ 0.5 )
			local out = { true; true; true }

			return sharpvec, out

		end; func = function( sharpvec, out )

			sharpvec:ToTable( out )

		end }

	};

	Random = {

		{ name = 'Vector:Random'; setup = function()

			local vec = Vector()

			return vec

		end; func = function( vec )

			vec:Random( -16384, 16384 )

		end; standard = true };

		{ name = 'SharpVector:Random'; setup = function()

			local sharpvec = SharpVector()

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:Random( -16384, 16384 )

		end }

	};

	WithinAABox = {

		{ name = 'Vector:WithinAABox'; setup = function()

			local vec = Vector()

			local boxMins = Vector( -16384, -16384, -16384 )
			local boxMaxs = boxMins:GetNegated()

			return vec, boxMins, boxMaxs

		end; func = function( vec, boxMins, boxMaxs )

			vec:WithinAABox( boxMins, boxMaxs )

		end; standard = true };

		{ name = 'SharpVector:WithinAABox'; setup = function()

			local sharpvec = SharpVector()

			local boxMins = SharpVector( -16384, -16384, -16384 )
			local boxMaxs = boxMins:GetNegated()

			return sharpvec, boxMins, boxMaxs

		end; func = function( sharpvec, boxMins, boxMaxs )

			sharpvec:WithinAABox( boxMins, boxMaxs )

		end }

	};

	Angle = {

		{ name = 'Vector:Angle'; setup = function()

			local vec = Vector( 3, 4, 5 )

			return vec

		end; func = function( vec )

			vec:Angle()

		end; standard = true };

		{ name = 'SharpVector:Angle'; setup = function()

			local sharpvec = SharpVector( 3, 4, 5 )

			RaisePreallocation( 'angle' )

			return sharpvec

		end; func = function( sharpvec )

			sharpvec:Angle()

		end };

		{ name = 'SharpVector:Angle; output specified'; setup = function()

			local sharpvec = SharpVector( 3, 4, 5 )

			local out = Angle()

			return sharpvec, out

		end; func = function( sharpvec, out )

			sharpvec:Angle( out )

		end }

	};
	AngleEx = {

		{ name = 'Vector:AngleEx'; setup = function()

			local vec = Vector( 3, 4, 5 )
			local vecUp = Vector( 1, 0, 0 )

			return vec, vecUp

		end; func = function( vec, vecUp )

			vec:AngleEx( vecUp )

		end; standard = true };

		{ name = 'SharpVector:AngleEx'; setup = function()

			local sharpvec = SharpVector( 3, 4, 5 )
			local sharpvecUp = SharpVector( 1, 0, 0 )

			RaisePreallocation( 'angle' )

			return sharpvec, sharpvecUp

		end; func = function( sharpvec, sharpvecUp )

			sharpvec:AngleEx( sharpvecUp )

		end };

		{ name = 'SharpVector:AngleEx; output specified'; setup = function()

			local sharpvec = SharpVector( 3, 4, 5 )
			local sharpvecUp = SharpVector( 1, 0, 0 )

			local out = Angle()

			return sharpvec, sharpvecUp, out

		end; func = function( sharpvec, sharpvecUp, out )

			sharpvec:AngleEx( sharpvecUp, out )

		end }

	};

	Rotate = {

		{ name = 'Vector:Rotate'; setup = function()

			local vec = Vector( 3, 4, 5 )

			return vec, Angle( 45, 15, 30 )

		end; func = function( vec, ang )

			vec:Rotate( ang )

		end; standard = true };

		{ name = 'SharpVector:Rotate'; setup = function()

			local sharpvec = SharpVector( 3, 4, 5 )

			return sharpvec, Angle( 45, 15, 30 )

		end; func = function( sharpvec, ang )

			sharpvec:Rotate( ang )

		end }

	};

	Lerp = {

		{ name = 'LerpVector'; setup = function()

			local vecStart = Vector( 0, 0, 0 )

			local vecTarget = Vector()
			vecTarget:Random( -16384, 16384 )

			return vecStart, vecTarget

		end; func = function( vecStart, vecTarget )

			LerpVector( 0.5, vecStart, vecTarget )

		end; standard = true };

		{ name = 'SharpVector:Lerp'; setup = function()

			local sharpvecStart = SharpVector( 0, 0, 0 )

			local sharpvecTarget = SharpVector()
			sharpvecTarget:Random( -16384, 16384 )

			RaisePreallocation( 'sharpvec' )

			return sharpvecStart, sharpvecTarget

		end; func = function( sharpvecStart, sharpvecTarget )

			sharpvecStart:Lerp( sharpvecTarget, 0.5 )

		end };

		{ name = 'SharpVector:Lerp; output specified'; setup = function()

			local sharpvecCurrent = SharpVector( 0, 0, 0 )

			local sharpvecTarget = SharpVector()
			sharpvecTarget:Random( -16384, 16384 )

			return sharpvecCurrent, sharpvecTarget

		end; func = function( sharpvecCurrent, sharpvecTarget )

			sharpvecCurrent:Lerp( sharpvecTarget, 0.5, sharpvecCurrent )

		end }

	}

}

local SelectedTests = {

	-- 'Create';

	-- 'SetUnpacked';
	-- 'Zero';
	-- 'Negate';
	-- 'GetNegated';
	-- 'Unpack';

	-- 'Set';
	-- 'Add';
	-- 'Mul';

	-- 'Length';
	-- 'Distance';

	-- 'Normalize';
	-- 'GetNormalized';

	-- 'Dot';
	-- 'Cross';

	-- 'IsEqualTol';
	-- 'IsZero';

	-- 'ToTable';

	-- 'Random';

	-- 'WithinAABox';

	-- 'Angle';
	-- 'AngleEx';

	-- 'Rotate';

	-- 'Lerp';

}


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Benchmark
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local SHARED_JIT_OFF = false

for _, name in ipairs( SelectedTests ) do

	for _, funcbench in ipairs( Tests[name] ) do
		Tests[name].jit_off = SHARED_JIT_OFF
	end

end

local frames = 1000
local iterations_per_frame = 250

gluafuncbudget.Configure( {

	frames = frames;
	iterations_per_frame = iterations_per_frame;

	digit = 4;

	measure_unit = 'ms';
	comparison_basis = 'average'

} )

RaisePreallocation = function( of )

	timer.Pause( 'SharpVector_Preallocation' )

	local prealloc_amount = frames * iterations_per_frame + frames + 1
	SharpVector_SetMaxPreallocAmount( of:find('sharpvec') ~= nil and prealloc_amount or nil, nil, of:find('angle') ~= nil and prealloc_amount or nil )

	timer.Create( 'SharpVector_SetMaxPreallocAmount()', 0, 1, function()

		SharpVector_SetMaxPreallocAmount()
		timer.UnPause( 'SharpVector_Preallocation' )

	end )

end

for _, name in ipairs( SelectedTests ) do

	for _, funcbench in ipairs( Tests[name] ) do
		gluafuncbudget.Queue( funcbench )
	end

end
