
local frames = 66--[[tickrate]] * 50--[[cycles-samples]]
local iterations_per_frame = 64


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function raise_preallocation_1()

	SharpVector_SetPreallocationAmount( ( frames + 1 ) * ( iterations_per_frame + 1 ), nil, nil )

end

local function raise_preallocation_3()

	SharpVector_SetPreallocationAmount( nil, nil, ( frames + 1 ) * ( iterations_per_frame + 1 ) )

end

local Tests = {

	Create = {

		{

			name = 'new Vector';
			standard = true;

			main = function() Vector() end

		};

		{

			name = 'new SharpVector';

			setup = raise_preallocation_1;

			main = function() SharpVector() end;

			after = SharpVector_SetPreallocationAmount

		};

		{

			name = 'new SharpVector; no preallocation';

			setup = function()

				SharpVector_SetPreallocationAmount( 0, nil, nil )

			end;

			main = function() SharpVector() end;

			after = SharpVector_SetPreallocationAmount

		}

	};


	SetUnpacked = {

		{

			name = 'Vector:SetUnpacked';
			standard = true;

			setup = function() return Vector() end;

			main = function( vec ) vec:SetUnpacked( 3.14, 1.618, 37 ) end

		};

		{

			name = 'SharpVector:SetUnpacked';

			setup = function() return SharpVector() end;

			main = function( vec ) vec:SetUnpacked( 3.14, 1.618, 37 ) end

		}

	};
	Zero = {

		{

			name = 'Vector:Zero';
			standard = true;

			setup = function() return Vector( 1, 1, 1 ) end;

			main = function( vec ) vec:Zero() end

		};

		{

			name = 'SharpVector:Zero';

			setup = function() return SharpVector( 1, 1, 1 ) end;

			main = function( vec ) vec:Zero() end

		}

	};
	Negate = {

		{

			name = 'Vector:Negate';
			standard = true;

			setup = function() return Vector( 1, 1, 1 ) end;

			main = function( vec ) vec:Negate() end

		};

		{

			name = 'SharpVector:Negate';

			setup = function() return SharpVector( 1, 1, 1 ) end;

			main = function( vec ) vec:Negate() end

		}

	};
	GetNegated = {

		{

			name = 'Vector:GetNegated';
			standard = true;

			setup = function() return Vector( 1, 1, 1 ) end;

			main = function( vec ) vec:GetNegated() end

		};

		{

			name = 'SharpVector:GetNegated';

			setup = function() raise_preallocation_1() return SharpVector( 1, 1, 1 ) end;

			main = function( vec ) vec:GetNegated() end;

			after = SharpVector_SetPreallocationAmount

		}

	};
	Unpack = {

		{

			name = 'Vector:Unpack';
			standard = true;

			setup = function() return Vector( 1, 1, 1 ) end;

			main = function( vec ) vec:Unpack() end

		};

		{

			name = 'SharpVector:Unpack';

			setup = function() return SharpVector( 1, 1, 1 ) end;

			main = function( vec ) vec:Unpack() end

		}

	};

	Set = {

		{

			name = 'Vector:Set';
			standard = true;

			setup = function() return Vector(), Vector() end;

			main = function( vec1, vec2 ) vec1:Set( vec2 ) end

		};

		{

			name = 'SharpVector:Set';

			setup = function() return SharpVector(), SharpVector() end;

			main = function( vec1, vec2 ) vec1:Set( vec2 ) end

		}

	};
	Add = {

		{

			name = 'Vector:Add';
			standard = true;

			setup = function() return Vector(), Vector() end;

			main = function( vec1, vec2 ) vec1:Add( vec2 ) end

		};

		{

			name = 'SharpVector:Add';

			setup = function() return SharpVector(), SharpVector() end;

			main = function( vec1, vec2 ) vec1:Add( vec2 ) end

		}

	};
	Mul = {

		{

			name = 'Vector:Mul( number )';
			standard = true;

			setup = function() return Vector() end;

			main = function( vec ) vec:Mul( 1 ) end

		};

		{

			name = 'SharpVector:Mul( number )';

			setup = function() return SharpVector() end;

			main = function( vec ) vec:Mul( 1 ) end

		};

		{

			name = 'Vector:Mul( vector )';
			standard = true;

			setup = function() return Vector(), Vector() end;

			main = function( vec1, vec2 ) vec1:Mul( vec2 ) end

		};

		{

			name = 'SharpVector:Mul( vector )';

			setup = function() return SharpVector(), SharpVector() end;

			main = function( vec1, vec2 ) vec1:Mul( vec2 ) end

		}

	};
	['Mul( matrix )'] = {

		{

			name = 'Vector:Mul( matrix )';
			standard = true;

			setup = function() return Vector(), Matrix() end;

			main = function( vec, matrix ) vec:Mul( matrix ) end

		};

		{

			name = 'SharpVector:Mul( matrix )';

			setup = function() return SharpVector(), Matrix() end;

			main = function( vec, matrix ) vec:Mul( matrix ) end

		}

	};

	Length = {

		{

			name = 'Vector:Length';
			standard = true;

			setup = function() return Vector( 3, 4, 5 ) end;

			main = function( vec ) vec:Length() end

		};

		{

			name = 'SharpVector:Length';

			setup = function() return SharpVector( 3, 4, 5 ) end;

			main = function( vec ) vec:Length() end

		}

	};
	Distance = {

		{

			name = 'Vector:Distance';
			standard = true;

			setup = function()

				local vec1 = Vector();
				local vec2 = Vector()

				vec1:Random( -16384, 16384 )
				vec2:Random( -16384, 16384 )

				return vec1, vec2

			end;

			main = function( vec1, vec2 ) vec1:Distance( vec2 ) end

		};

		{

			name = 'SharpVector:Distance';

			setup = function()

				local vec1 = SharpVector();
				local vec2 = SharpVector()

				vec1:Random( -16384, 16384 )
				vec2:Random( -16384, 16384 )

				return vec1, vec2

			end;

			main = function( vec1, vec2 ) vec1:Distance( vec2 ) end

		}

	};

	Normalize = {

		{

			name = 'Vector:Normalize';
			standard = true;

			setup = function() return Vector( 1, 1, 1 ) end;

			main = function( vec ) vec:Normalize() end

		};

		{

			name = 'SharpVector:Normalize';

			setup = function() return SharpVector( 1, 1, 1 ) end;

			main = function( vec ) vec:Normalize() end

		}

	};
	GetNormalized = {

		{

			name = 'Vector:GetNormalized';
			standard = true;

			setup = function() return Vector( 1, 1, 1 ) end;

			main = function( vec ) vec:GetNormalized() end

		};

		{

			name = 'SharpVector:GetNormalized';

			setup = function() raise_preallocation_1() return SharpVector( 1, 1, 1 ) end;

			main = function( vec ) vec:GetNormalized() end;

			after = SharpVector_SetPreallocationAmount

		}

	};

	Dot = {

		{

			name = 'Vector:Dot';
			standard = true;

			setup = function()

				local vec1 = Vector( 0, 1, 0 )
				local vec2 = Vector( 0, -1, 0 )

				return vec1, vec2

			end;

			main = function( vec1, vec2 ) vec1:Dot( vec2 ) end

		};

		{

			name = 'SharpVector:Dot';

			setup = function()

				local vec1 = SharpVector( 0, 1, 0 )
				local vec2 = SharpVector( 0, -1, 0 )

				return vec1, vec2

			end;

			main = function( vec1, vec2 ) vec1:Dot( vec2 ) end

		}

	};
	Cross = {

		{

			name = 'Vector:Cross';
			standard = true;

			setup = function()

				local vecUp = Vector( 0, 0, 1 )
				local vecForward = Vector( 100, 0, 0 )

				return vecUp, vecForward

			end;

			main = function( vecUp, vecForward ) vecUp:Cross( vecForward ) end

		};

		{

			name = 'SharpVector:Cross';

			setup = function()

				local vecUp = SharpVector( 0, 0, 1 )
				local vecForward = SharpVector( 100, 0, 0 )

				raise_preallocation_1()

				return vecUp, vecForward

			end;

			main = function( vecUp, vecForward ) vecUp:Cross( vecForward ) end;

			after = SharpVector_SetPreallocationAmount

		};

		{

			name = 'SharpVector:Cross; output specified';

			setup = function()

				local vecUp = SharpVector( 0, 0, 1 )
				local vecForward = SharpVector( 100, 0, 0 )

				return vecUp, vecForward, SharpVector()

			end;

			main = function( vecUp, vecForward, output ) vecUp:Cross( vecForward, output ) end

		}

	};

	IsEqualTol = {

		{

			name = 'Vector:IsEqualTol';
			standard = true;

			setup = function()

				local tolerance = 0.5

				local vec1 = Vector( 0, 0, 0 )
				local vec2 = Vector( 0, 0, tolerance * 2 )

				return vec1, vec2, tolerance

			end;

			main = function( vec1, vec2, tolerance ) vec1:IsEqualTol( vec2, tolerance ) end

		};

		{

			name = 'SharpVector:IsEqualTol';

			setup = function()

				local tolerance = 0.5

				local vec1 = SharpVector( 0, 0, 0 )
				local vec2 = SharpVector( 0, 0, tolerance * 2 )

				return vec1, vec2, tolerance

			end;

			main = function( vec1, vec2, tolerance ) vec1:IsEqualTol( vec2, tolerance ) end

		}

	};
	IsZero = {

		{

			name = 'Vector:IsZero';
			standard = true;

			setup = function() return Vector() end;

			main = function( vec ) vec:IsZero() end

		};

		{

			name = 'SharpVector:IsZero';

			setup = function() return SharpVector() end;

			main = function( vec ) vec:IsZero() end

		}

	};

	ToTable = {

		{

			name = 'Vector:ToTable';
			standard = true;

			setup = function() return Vector() end;

			main = function( vec ) vec:ToTable() end

		};

		{

			name = 'SharpVector:ToTable';

			setup = function() return SharpVector() end;

			main = function( vec ) vec:ToTable() end

		};

		{

			name = 'SharpVector:ToTable; output specified';

			setup = function() return SharpVector(), { 0; 0; 0 } end;

			main = function( vec, output ) vec:ToTable( output ) end

		}

	};

	Random = {

		{

			name = 'Vector:Random';
			standard = true;

			setup = function() return Vector() end;

			main = function( vec ) vec:Random( -1, 1 ) end

		};

		{

			name = 'SharpVector:Random';

			setup = function() return SharpVector() end;

			main = function( vec ) vec:Random( -1, 1 ) end

		}

	};

	WithinAABox = {

		{

			name = 'Vector:WithinAABox';
			standard = true;

			setup = function()

				local vec = Vector()

				local mins = Vector( -1, -1, -1 )
				local maxs = mins:GetNegated()

				return vec, mins, maxs

			end;

			main = function( vec, mins, maxs ) vec:WithinAABox( mins, maxs ) end;

		};

		{

			name = 'SharpVector:WithinAABox';

			setup = function()

				local vec = SharpVector()

				local mins = SharpVector( -1, -1, -1 )
				local maxs = mins:GetNegated()

				return vec, mins, maxs

			end;

			main = function( vec, mins, maxs ) vec:WithinAABox( mins, maxs ) end;

		}

	};

	Angle = {

		{

			name = 'Vector:Angle';
			standard = true;

			setup = function() return Vector( 3, 4, 5 ) end;

			main = function( vec ) vec:Angle() end

		};

		{

			name = 'SharpVector:Angle';

			setup = function() raise_preallocation_3() return SharpVector( 3, 4, 5 ) end;

			main = function( vec ) vec:Angle() end

		};

		{

			name = 'SharpVector:Angle; output specified';

			setup = function() raise_preallocation_3() return SharpVector( 3, 4, 5 ), Angle() end;

			main = function( vec, output ) vec:Angle( output ) end;

			after = SharpVector_SetPreallocationAmount

		}

	};
	AngleEx = {

		{

			name = 'Vector:AngleEx';
			standard = true;

			setup = function() return Vector( 3, 4, 5 ), Vector( 1, 0, 0 ) end;

			main = function( vec, vecUp ) vec:AngleEx( vecUp ) end

		};

		{

			name = 'SharpVector:AngleEx';

			setup = function() raise_preallocation_3() return SharpVector( 3, 4, 5 ), SharpVector( 1, 0, 0 ) end;

			main = function( vec, vecUp ) vec:AngleEx( vecUp ) end

		};

		{

			name = 'SharpVector:AngleEx; output specified';

			setup = function() raise_preallocation_3() return SharpVector( 3, 4, 5 ), SharpVector( 1, 0, 0 ), Angle() end;

			main = function( vec, vecUp, output ) vec:AngleEx( vecUp, output ) end;

			after = SharpVector_SetPreallocationAmount

		}

	};

	Rotate = {

		{

			name = 'Vector:Rotate';
			standard = true;

			setup = function() return Vector( 3, 4, 5 ), Angle( 45, 15, 30 ) end;

			main = function( vec, ang ) vec:Rotate( ang ) end

		};

		{

			name = 'SharpVector:Rotate';

			setup = function() return SharpVector( 3, 4, 5 ), Angle( 45, 15, 30 ) end;

			main = function( vec, ang ) vec:Rotate( ang ) end

		}

	};

	Lerp = {

		{

			name = 'LerpVector';
			standard = true;

			setup = function() return Vector(), Vector( 1, 1, 1 ) end;

			main = function( vec1, vec2 ) LerpVector( 0.00001, vec1, vec2 ) end

		};

		{

			name = 'SharpVector:Lerp';

			setup = function() raise_preallocation_1() return SharpVector(), SharpVector( 1, 1, 1 ) end;

			main = function( vec1, vec2 ) vec1:Lerp( vec2, 0.00001 ) end;

			after = SharpVector_SetPreallocationAmount

		};

		{

			name = 'SharpVector:Lerp; output specified';

			setup = function() return SharpVector(), SharpVector( 1, 1, 1 ) end;

			main = function( vec1, vec2 ) vec1:Lerp( vec2, 0.00001, vec1 ) end

		}

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
	-- 'Mul( matrix )'; -- not for the Menu realm

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

	-- 'Lerp'

}

local Shared_JIT_Off = false

for _, name in ipairs( SelectedTests ) do

	for _, budgetedfunc in ipairs( Tests[name] ) do
		budgetedfunc.jit_off = Shared_JIT_Off
	end

end


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Act
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
gluafuncbudget.Configure( {

	frames = frames;
	iterations_per_frame = iterations_per_frame;

	digit = 7;

	measure_unit = 'ms';
	comparison_basis = 'average';

	shown_categories = 'median average avgfps'

} )

for _, name in ipairs( SelectedTests ) do

	for _, budgetedfunc in ipairs( Tests[name] ) do
		gluafuncbudget.Queue( budgetedfunc )
	end

end
