# glua-SharpVector
 A GLua implementation of Vector.

 Featuring rigid optimization & precise calculations due to components being doubles.

### My initial motive
> The original idea was to write a GLua variant of Vector because in Lua numbers are stored as _doubles_ (_[Double-precision floating-point format](https://en.wikipedia.org/wiki/Double-precision_floating-point_format)_) while in the engine Vector's components are stored as _floats_ (_32 bits long; higher probability of precision loss on very small scales_).
>
> This script can be very handy if you need performant and high-precision vectors.

## Doc
 All pivotal details are concisely described/explained in the code.

 All Vector functions are present. `SharpVector()` possesses the same argument overload as `Vector()`.

 Functions compatible with `Vector`:
 * `SharpVector:SetGModVector( vec )`
 * `SharpVector:AddGModVector( vec )`
 * `SharpVector:SubGModVector( vec )`
 * `SharpVector:MulByGModVector( vec )`
 * `SharpVector:DivByGModVector( vec )`

 Multiplication by `Matrix` is moved to `SharpVector:MulByMatrix( matrix )`

 Extensions:
 * `Vector?` `SharpVector:ToGModVector( [vecOut] )`
 * `SharpVector` `Vector:Sharpened()`
 * `SharpVector?` `SharpVector:Lerp( sharpvecTarget, fraction[, sharpvecOut] )`

### Features
 Functions that by design return new vector/angle/color/table as the result have the last argument as the output for the result (where reasonable). (`Cross`, `ToColor`, `ToTable`, `Angle`, `AngleEx`, `Rotate`)

---

### [Performance Test](./perftest/PerfTest.md)
