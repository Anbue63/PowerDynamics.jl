using Pkg
Pkg.instantiate()
using PowerDynamics
using Revise

perturbed_node=2

# per unit transformation base values
V_base_kV = 0.4
S_base_kW = 1
Y_base = S_base_kW*1000/(V_base_kV*1000)^2

# line paramterization
Y_12 = (1/(0.25+1im*0.98*1e-6))/Y_base
# node paramterization
P_2 = -16.67/S_base_kW
Q_2 = 0/S_base_kW


node_list=[]
    append!(node_list,[SlackAlgebraic(U=1.)])
    #append!(node_list,[PQAlgebraic(P=P_2,Q=Q_2)])
    append!(node_list,[VoltageDependentLoad(P=P_2,Q=Q_2,U=1,A=0.,B=0.)])
line_list=[]
    append!(line_list,[StaticLine(from=1,to=2,Y=Y_12)])

powergrid = PowerGrid(node_list,line_list)
operationpoint = find_operationpoint(powergrid,sol_method = :dynamic)

timespan = (0., 22.)

pd = PowerPerturbation(
    node = perturbed_node,
    fault_power = -11.11/S_base_kW,
    tspan_fault = (9.,18.),
    var = :P)

result_pd = simulate(pd, operationpoint, timespan)

include("../../plotting.jl")
plot_res(result_pd,powergrid,perturbed_node)
