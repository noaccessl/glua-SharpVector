# glua-SharpVector
 A GLua implementation of [Vector] with rigorous optimization & high precision because Lua numbers are doubles.

#### My initial motive
> The original idea was to write a GLua variant of [Vector] because in Lua numbers are stored as _doubles_ (_[Double-precision floating-point format](https://en.wikipedia.org/wiki/Double-precision_floating-point_format)_) while in the engine [Vector]'s components are stored as _floats_ (_32 bits long; higher probability of precision loss on very small scales_).
>
> This script can be very handy if you need performant and high-precision vectors.

## Doc
 All pivotal details are concisely described/explained in the code.

 All default [Vector] functions are present. `SharpVector()` features the same argument overload as `Vector()`.

 Functions compatible with [Vector]:
 * `SharpVector:SetGModVector( vec )`
 * `SharpVector:AddGModVector( vec )`
 * `SharpVector:SubGModVector( vec )`
 * `SharpVector:MulByGModVector( vec )`
 * `SharpVector:DivByGModVector( vec )`

 Extensions:
 * `Vector?` `SharpVector:AsGModVector( [vecOutput] )`
 * `SharpVector` `Vector:Sharpened()`
 * `SharpVector?` `SharpVector:Lerp( sharpvecTarget, fraction[, sharpvecOutput] )`

 Features:
 * `SharpVector:Normalize()` returns the length in addition.
 * Functions returning a new object have additional final argument as the output for it (where reasonable). </br>
 <sub>(`Cross`, `ToColor`, `ToTable`, `Angle`, `AngleEx`)</sub>
 * `SharpVector:Rotate` has a second argument as the output for transformation.

---

### [Performance Test](./perftest/PerfTest.md)



[Vector]: https://wiki.facepunch.com/gmod/Vector
