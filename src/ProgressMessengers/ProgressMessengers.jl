module ProgressMessengers
using DocStringExtensions

using Printf

import Base: +, *

export AbstractProgressMessenger
export FunctionMessenger
export MaxUVelocity, MaxVVelocity, MaxWVelocity
export MaxVelocities
export Iteration, Time, TimeStep, PercentageProgress, WalltimePerTimestep, Walltime, SimpleTimeMessenger, TimeMessenger, StopwatchMessenger
export MaxViscosity, AdvectiveCFLNumber, DiffusiveCFLNumber, SimpleStabilityMessenger

abstract type AbstractProgressMessenger end

const comma = ", "
const space = ""

#+++ FunctionMessenger
Base.@kwdef struct FunctionMessenger{F} <: AbstractProgressMessenger
    func :: F
end

function (fmessenger::FunctionMessenger)(sim)
    message = fmessenger.func(sim)
    return_or_print(message)
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

return_or_print(message, pm::AbstractProgressMessenger) = pm.print ? (@info message) : (return message)
return_or_print(message) = return message

include("velocities.jl")
include("timing.jl")
include("cfl.jl")

const CourantNumber = AdvectiveCFLNumber
const NormalizedMaxViscosity = DiffusiveCFLNumber

end # module
