## BEE 4750 Lab 3: Mixed Integer Programming and Facility Siting in JuMP
##
## Plain-script version of lab03.ipynb, for anyone who prefers working in a
## script rather than a notebook. See lab03.qmd / lab03.ipynb for the full
## problem statements, and activity-sheet.pdf for the written parts.
##
## Run this top to bottom in the Julia REPL (e.g. `include("lab03.jl")`) or
## a cell-by-cell VS Code session.

import Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using JuMP    # optimization modeling syntax
using HiGHS   # the solver

## --- The county --------------------------------------------------------
##
## A county's four towns collect organic matter (food scraps and yard
## waste) every week, and the county wants to compost all of it. It has
## three candidate sites. Each site can compost up to its capacity; each
## site that is built has a fixed cost per week (building it, spread over
## its life, plus staffing and running it); and hauling a ton of organic
## matter from a town to a site has a transport cost. We assume composting
## costs the same per ton everywhere, so it is left out. Sites A, B and C
## are sites 1, 2 and 3 in the code.

town_names = ["Town 1", "Town 2", "Town 3", "Town 4"]
site_names = ["A", "B", "C"]
n_towns = length(town_names)
n_sites = length(site_names)

organic_matter = [60, 140, 80, 100]  # collected by each town [tons/week]
capacity = [300, 200, 250]           # most a site can take [tons/week]
fixed_cost = [2800, 2200, 2600]      # if the site is built [$/week]

# transport_cost[i, j]: hauling one ton from town i to site j [$/ton]
transport_cost = [5 17 22;
                  4 10 18;
                  12 6 22;
                  22 20 6]

## --- The model ----------------------------------------------------------
##
## x[i, j] >= 0: organic matter hauled from town i to site j [tons/week]
## y[j] in {0, 1}: 1 if site j is built, 0 if not
##
## minimize   sum over i, j of c[i, j] x[i, j]  +  sum over j of F[j] y[j]
## subject to sum over j of x[i, j] = d[i]          for each town i
##            sum over i of x[i, j] <= C[j] y[j]    for each site j
##
## d: organic_matter, C: capacity, F: fixed_cost, c: transport_cost. The
## second set says that a site that is built takes at most its capacity,
## and a site that is not built takes nothing.

## --- Step 1: Build Every Site -------------------------------------------
##
## With every y[j] = 1, the fixed costs are a constant (F_A + F_B + F_C)
## and the capacity constraints become plain capacity limits: an LP.
## shipped[i, j] is x[i, j]. If you change the model, re-run this whole
## block from `all_built = Model(...)`.

all_built = Model(HiGHS.Optimizer)
set_silent(all_built)

# Organic matter hauled from town i to site j [tons/week]
@variable(all_built, shipped[1:n_towns, 1:n_sites] >= 0)

# TODO: the objective, the total cost [$/week]: the transport cost of every
# shipment, plus the fixed costs of all three sites
# @objective(all_built, Min, ...)

# TODO: one constraint per town: all its organic matter goes to some site
# @constraint(all_built, [i in 1:n_towns], ...)

# TODO: one constraint per site: it takes no more than its capacity
# @constraint(all_built, [j in 1:n_sites], ...)

print(all_built)

optimize!(all_built)
println(termination_status(all_built))   # should be OPTIMAL

@show objective_value(all_built);
display(value.(shipped))

## If your model is right, the total cost is $9,540 per week. If not,
## compare print(all_built) with the LP. Record the plan on the Activity
## Sheet.

## --- Step 2: Let the Model Choose the Sites -----------------------------
##
## Now each y[j] is an indicator decision variable. Code and solve the
## model below; site_open[j] is y[j]. If you change the model, re-run this
## whole block from `siting = Model(...)`.

siting = Model(HiGHS.Optimizer)
set_silent(siting)

# Organic matter hauled from town i to site j [tons/week]
@variable(siting, shipped[1:n_towns, 1:n_sites] >= 0)
# 1 if the site is built, 0 if not
@variable(siting, site_open[1:n_sites], Bin)

# TODO: the objective, the total cost [$/week]: the transport cost of
# every shipment, plus the fixed cost of each site that is built
# @objective(siting, Min, ...)

# TODO: one constraint per town: all its organic matter goes to some site
# @constraint(siting, [i in 1:n_towns], ...)

# TODO: one capacity constraint per site: it takes no more than its
# capacity times site_open
# @constraint(siting, [j in 1:n_sites], ...)

print(siting)

optimize!(siting)
println(termination_status(siting))   # should be OPTIMAL

# TODO: as in Step 1, query the total cost, the shipments, and the values
# of site_open

## This model's variables are also called `shipped`, so value.(shipped) now
## gives this model's shipments, not Step 1's. Values like -0.0 or
## -5.68434e-14 are 0: these are rounding artifacts. Record the plan on the
## Activity Sheet and answer the Step 2 questions there.

## --- Step 3: A Watershed Rule -------------------------------------------
##
## Sites A and C both drain to the same creek, a few miles upstream of a
## drinking-water intake. Runoff from compost piles carries nutrients, so
## the state will permit at most one composting site in that creek's
## watershed. Write the rule as a constraint on the y[j] (Step 3a on the
## Activity Sheet). Then build the Step 2 model again below as a new
## model, with_rule: copy in your Step 2 objective and constraints,
## changing `siting` to `with_rule`, and add the rule; name the capacity
## constraints and the rule as the comments say, for Step 4. Sites A, B and
## C are 1, 2 and 3. If you change the model, re-run this whole block.

with_rule = Model(HiGHS.Optimizer)
set_silent(with_rule)

# Organic matter hauled from town i to site j [tons/week]
@variable(with_rule, shipped[1:n_towns, 1:n_sites] >= 0)
# 1 if the site is built, 0 if not
@variable(with_rule, site_open[1:n_sites], Bin)

# TODO: the objective and constraints from Step 2, on with_rule. Name the
# capacity constraints capacity_limit, for Step 4:
# @constraint(with_rule, capacity_limit[j in 1:n_sites], ...)

# TODO: the watershed rule, named watershed: at most one of Sites A and C
# @constraint(with_rule, watershed, ...)

print(with_rule)

optimize!(with_rule)
println(termination_status(with_rule))

# TODO: query the new plan as in Step 2

## Record the plan on the Activity Sheet and answer the Step 3 question.

## --- Step 4: Shadow Prices ---------------------------------------------
##
## A mixed integer program has no shadow prices of its own.
## fix_discrete_variables fixes each indicator variable at its optimal
## value, so that solving again gives an LP with the same solution. Its
## shadow prices are conditional on that choice: they describe small changes
## to the outcome assuming the indicator variables have the same values as
## in the optimal solution.

fix_discrete_variables(with_rule)
optimize!(with_rule)
println(termination_status(with_rule))

# TODO: query the shadow prices of capacity_limit and watershed.
# shadow_price. works on an array of constraints as value. does on an array
# of variables.

## Record them on the Activity Sheet and answer the Step 4 questions there.
