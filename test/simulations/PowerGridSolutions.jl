using Test: @test, @testset
using PowerDynBase: variable_index, solve, tspan

import PowerDynBase.symbolsof
import PowerDynBase.dimension

using Random: Random, rand

random_seed = 1234
Random.seed!(random_seed)

struct Foo
end

symbolsof(f::Foo) = [:a, :b, :c]
dimension(f::Foo) = 3

@testset "PowerGridSolution should find proper variable_index" begin
        idx = variable_index([Foo()], 1, :c)
        @test idx == 3
        idx = variable_index([Foo(),Foo()], 2, :b)
        @test idx == 5
end

@testset "PowerGridSolution index tests" begin
        nodes = [SwingEqLVS(H=1., P=-1, D=1, Ω=50, Γ=20, V=1), SwingEqLVS(H=1., P=-1, D=1, Ω=50, Γ=20, V=1)]
        graph = SimpleGraph(2)
        add_edge!(graph, 1, 2);
        lines = [StaticLine(Y=-im)]
        grid = PowerGrid(graph, nodes, lines)
        state = State(grid, rand(systemsize(grid)))
        sol = solve(grid, state, (0.,10.))
        @test (0., 10.) == tspan(sol)
        @test (range(0, stop=10, length=1_000) .≈ tspan(sol, 1_000)) |> all

        #single point in time
        @test size(sol(sol.dqsol.t[end], :, :u)) == (2,)
        #time series
        @test size(sol([sol.dqsol.t[1], sol.dqsol.t[end]], :, :u)) == (2,2)
        @test sol(0.1, 1, :int, 3) == sol(0.1, 1, :ω)
end
