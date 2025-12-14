# Current Conclusion

## Phenomenon

Define functions and prepare data.

```julia
@inline function f(x)
    T = promote_type(Tf, eltype(x))
    return MVector{2, T}(x[1] * x[2], x[1] + x[2]) # xy, x+y
end

data_cpu = zeros(Tf, 2, 6)
data_cpu[1, 1] = 1
data_cpu[1, 2] = 2
data_cpu[2, 1] = 3
data_cpu[2, 2] = 4
data_gpu = Tcontainer(data_cpu)
```

$$
\begin{equation}
    \frac{\partial(xy, x+y)}{\partial(x,y)}=
    \begin{pmatrix}
        y & x\\
        1 & 1
    \end{pmatrix}
\end{equation}
$$

Define kernel functions, jacobian.

```julia
@kernel function test_forwarddiff!(data)
    idx = @index(Global)
    vec = E2Vector{2}(idx, 1, data)
    mat = E2SquareMatrix{2}(idx, 3, data)
    jac = ForwardDiff.jacobian(f, vec)
    mat .= jac
end

test_forwarddiff!(kBackend, 2)(data_gpu, ndrange=(2,))
KernelAbstractions.synchronize(kBackend)
```

The result is stored in col-major order `(y, 1, x, 1)`.

$$
\begin{equation}
    \frac{\partial u^i}{\partial x^l} = u^i_{l,x}
\end{equation}
$$

compromises the tensor-einstein notation.

```julia
data_gpu
2×6 oneArray{Float32, 2, oneAPI.oneL0.DeviceBuffer}:
 1.0  2.0  2.0  1.0  1.0  1.0
 3.0  4.0  4.0  1.0  3.0  1.0
```

`ForwardDiff.jl` can run on gpu!

## Reflection

Can other `autograd` packages run on GPU?