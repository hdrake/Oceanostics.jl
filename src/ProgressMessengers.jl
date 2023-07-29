module ProgressMessengers
using Printf
import Base: +, *

export AbstractProgressMessenger
export MaxUVelocity, MaxVVelocity, MaxWVelocity
export MaxVelocities
export FunctionMessenger

abstract type AbstractProgressMessenger end
 
const comma = ", "
const space = " "

#+++ FunctionMessenger
Base.@kwdef struct FunctionMessenger{F} <: AbstractProgressMessenger
    func :: F
end

function (fmessenger::FunctionMessenger)(sim)
    message = fmessenger.func(sim)
    return message
end
#---

#+++ Basic operations with functions and strings
@inline +(a::AbstractProgressMessenger,   b::AbstractProgressMessenger)   = FunctionMessenger(sim -> a(sim) * comma * b(sim))
@inline *(a::AbstractProgressMessenger,   b::AbstractProgressMessenger)   = FunctionMessenger(sim -> a(sim) * space * b(sim))

const FunctionOrProgressMessenger = Union{Function, AbstractProgressMessenger}
@inline +(a::AbstractProgressMessenger,   b::FunctionOrProgressMessenger) = FunctionMessenger(sim -> a(sim) * comma * b(sim))
@inline +(a::FunctionOrProgressMessenger, b::AbstractProgressMessenger)   = FunctionMessenger(sim -> a(sim) * comma * b(sim))
@inline *(a::AbstractProgressMessenger,   b::FunctionOrProgressMessenger) = FunctionMessenger(sim -> a(sim) * space * b(sim))
@inline *(a::FunctionOrProgressMessenger, b::AbstractProgressMessenger)   = FunctionMessenger(sim -> a(sim) * space * b(sim))

const StringOrProgressMessenger = Union{String, AbstractProgressMessenger}
@inline +(a::AbstractProgressMessenger, b::StringOrProgressMessenger) = FunctionMessenger(sim -> a(sim) * comma * b)
@inline +(a::StringOrProgressMessenger, b::AbstractProgressMessenger) = FunctionMessenger(sim -> a      * comma * b(sim))
@inline *(a::AbstractProgressMessenger, b::StringOrProgressMessenger) = FunctionMessenger(sim -> a(sim) * space * b)
@inline *(a::StringOrProgressMessenger, b::AbstractProgressMessenger) = FunctionMessenger(sim -> a      * space * b(sim))
#---

#+++ Basic definitions
Base.@kwdef struct MaxUVelocity <: AbstractProgressMessenger
    with_prefix :: Bool = true
    with_units  :: Bool = true
end

Base.@kwdef struct MaxVVelocity <: AbstractProgressMessenger
    with_prefix :: Bool = true
    with_units  :: Bool = true
end

Base.@kwdef struct MaxWVelocity <: AbstractProgressMessenger
    with_prefix :: Bool = true
    with_units  :: Bool = true
end

@inline function (mu::MaxUVelocity)(sim)
    u_max = maximum(abs, sim.model.velocities.u)
    message = @sprintf("%.2e", u_max)
    mu.with_prefix     && (message = "|u|ₘₐₓ = " * message)
    mu.with_units && (message = message * " m/s")
    return message
end

@inline function (mv::MaxVVelocity)(sim)
    v_max = maximum(abs, sim.model.velocities.v)
    message = @sprintf("%.2e", v_max)
    mv.with_prefix     && (message = "|v|ₘₐₓ = " * message)
    mv.with_units && (message = message * " m/s")
    return message
end

@inline function (mw::MaxWVelocity)(sim)
    w_max = maximum(abs, sim.model.velocities.w)
    message = @sprintf("%.2e", w_max)
    mw.with_prefix     && (message = "|w|ₘₐₓ = " * message)
    mw.with_units && (message = message * " m/s")
    return message
end
#---

#+++ MaxVelocities
function MaxVelocities(; with_prefix = true, with_units = true)
    max_u = MaxUVelocity(with_prefix = false, with_units = false)
    max_v = MaxVVelocity(with_prefix = false, with_units = false)
    max_w = MaxWVelocity(with_prefix = false, with_units = false)

    message = "[" * max_u + max_v + max_w * "]"
    with_prefix && (message = "|u⃗|ₘₐₓ =" * message)
    with_units  && (message = message * "m/s")
    return message
end
#---

#+++ Stopwatch
Base.@kwdef mutable struct Stopwatch{T, I, L} <: AbstractProgressMessenger
    wall_time₀  :: T  # Wall time at simulation start
    wall_time⁻  :: T  # Wall time at previous calback
    iteration⁻  :: I  # Iteration at previous calback
    with_prefix :: Bool = true
    with_units  :: Bool = true
end

"""
    $(SIGNATURES)

Return a `Stopwatch`, where the time per model time step is calculated.
"""
Stopwatch(; wall_time₀ = 1e-9*time_ns(), 
            wall_time⁻ = 1e-9*time_ns(),
            iteration⁻ = 0) = Stopwatch(wall_time₀, wall_time⁻, iteration⁻, LES)

function (pm::Stopwatch)(simulation)
    iter = iteration(simulation)

    time_since_last_callback = 1e-9 * time_ns() - pm.wall_time⁻
    iterations_since_last_callback = iter==0 ? Inf : iter - pm.iteration⁻
    wall_time_per_step = time_since_last_callback / iterations_since_last_callback
    pm.wall_time⁻ = 1e-9 * time_ns()
    pm.iteration⁻ = iter
end
#---


end # module
