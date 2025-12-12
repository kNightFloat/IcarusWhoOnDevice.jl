# Current Conclusion

[Einsum.jl](https://github.com/ahwillia/Einsum.jl/tree/master) can run inside GPU kernel, while [Tullio.jl](https://github.com/mcabbott/Tullio.jl) and [OMEinsum.jl](https://github.com/under-Peter/OMEinsum.jl) can't.

## Phenomenon

```julia
# inside the kernel
@kernel function ker!(data)
    idx::Int = @index(Global)
    a = E2SquareMatrix{2}(idx, 1, data)
    b = E2SquareMatrix{2}(idx, 5, data)
    c = similar(a)
    c .= a
    @einsum a[i, j] = c[i, k] * b[k, j]
end
```

```julia
# launch the kernel
data_cpu = randn(Float32, 3, 8);
data_gpu = oneArray(data_cpu)

ker!(oneAPIBackend(), 3)(data_gpu, ndrange=(3,))
KernelAbstractions.synchronize(oneAPIBackend())
```

Code above can run properly as expected.