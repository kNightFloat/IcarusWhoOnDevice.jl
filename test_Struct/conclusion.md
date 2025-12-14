# Struct made up by StaticArrays can run on GPUs!

## Phenomenon

```julia
# the struct definition
struct Par{N, T}
    mass::StaticScalar{T}
    rho::StaticScalar{T}
    pos::StaticVector{N, T}
    vel::StaticVector{N, T}
    acc::StaticVector{N, T}
    stress::StaticMatrix{N, N, T}
end
```

```julia
@kernel function par_ker!(data)
    idx::Int = @index(Global)
    mass = E2Scalar(idx, nt.mass, data)
    rho = E2Scalar(idx, nt.rho, data)
    pos = E2Vector{2}(idx, nt.pos, data)
    vel = E2Vector{2}(idx, nt.vel, data)
    acc = E2Vector{2}(idx, nt.acc, data)
    stress = E2SquareMatrix{2}(idx, nt.stress, data)
    vel .+= acc * 0.1f0
    par = Par{2, Tf}(mass, rho, pos, vel, acc, stress)
    par.pos .+= par.vel * 1.0f0
end
```

This can work!

```julia
cpu_struct = [
    Par{2, Tf}(
        Scalar{Tf}(1.0),
        Scalar{Tf}(1.0),
        SVector{2, Tf}(1.0, 2.0),
        SVector{2, Tf}(3.0, 4.0),
        SVector{2, Tf}(5.0, 6.0),
        SMatrix{2, 2, Tf}(7.0, 8.0, 9.0, 10.0)
    )
    for _ in 1:3
]

gpu_struct = oneAPI.oneArray(cpu_struct)

@kernel function ker!(gpu_s)
    idx = @index(Global)
    gpu_s[idx].pos += gpu_s[idx].vel
end

ker!(oneAPIBackend(), 3)(gpu_struct, ndrange=(3,))
```

Direct wrapper of `oneArray{struct}` can't work in kernel programming.

## Reflection

Does such struct is a must?...

May be not.