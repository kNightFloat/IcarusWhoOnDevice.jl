# Current Conclusion

## Phenomenon

We have a function with Tuple{data_type...}:

```julia
@inline function test_vis_force(
    mass::NTuple{2, <:Real},
    rho::NTuple{2, <:Real},
    x::Tuple{<:StaticVector{2, <:Real}, <:StaticVector{2, <:Real}},
    u::Tuple{<:StaticVector{2, <:Real}, <:StaticVector{2, <:Real}}
)
    rvec = x[1] .- x[2]
    r = StaticArrays.norm(rvec)
    vij = u[1] .- u[2]
    ai = (mass[2] / rho[2]) .* (vij ./ (r .^ 2 .+ 0.01)) .* rvec
    return ai
end
```

```julia
@kernel function par_ker!(data)
    idx::Int = @index(Global)
    @inbounds m1 = data[idx, nt.mass]
    @inbounds rho1 = data[idx, nt.rho]
    x1 = E2Vector{2}(idx, nt.pos, data)
    u1 = E2Vector{2}(idx, nt.vel, data)
    a1 = E2Vector{2}(idx, nt.acc, data)
    jdx::Int = 2 * idx
    @inbounds m2 = data[jdx, nt.mass]
    @inbounds rho2 = data[jdx, nt.rho]
    x2 = E2Vector{2}(jdx, nt.pos, data)
    u2 = E2Vector{2}(jdx, nt.vel, data)
    a2 = E2Vector{2}(jdx, nt.acc, data)

    ai = test_vis_force((m1, m2), (rho1, rho2), (x1, x2), (u1, u2))
    a1 .+= ai
end
```

The function is quite straight-forward and easy to read. In kernel functions we just need to define the vector and matrix.

## Reflection

Maybe currently it's the best way...I guess.

I achieve a balance between between `straight-forward` - `performance` - `readability` - `extension` by such way.