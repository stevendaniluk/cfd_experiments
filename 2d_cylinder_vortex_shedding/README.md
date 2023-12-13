# 2D Cylinder Vortex Shedding

This is an OpenFOAM simulation for airflow over a 2 dimensional cylinder under various Reynolds numbers with steady state or transient behaviours. Below you can find results for each flow regime, a grid and time dependence study, and other notes about various experiments.

![Re_200_p_vorticity](img/Re_200_p_vorticity.gif)

[OpenFOAM Version 11](https://openfoam.org/version/11/) was used.

[Octave](https://octave.org/) is also used for some data processing.

## Scenario Overview
The simulated domain is 50 m long and 40 m wide, with the cylinder 20 m from the front and along the centerline.

**Simulation Properties:**
* Medium: Air
* Flow Model: Incompressible
* Solver: PIMPLE
* Mesh Cells: 57k
* Reynolds Numbers: 2, 20, 200

**Boundary Conditions:**

| Parameter | Inlet | Outlet | Walls | Cylinder |
|-|-|-|-|-|
| Pressure | Zero Gradient | 0 [Pa] | Symmetry | Zero Gradient |
| Velocity | 1.0 m/s | Zero Gradient | Symmetry | No Slip |

A freestream velocity of 1.0 m/s was used across all scenarios while kinematic viscosity was varied to achieve target Reynolds numbers.

**Mesh:**  
* Cells: 57,332
* Background cell size: 0.5 m
* Refinement levels: 4
* Surface layers: 10
* Smallest cell size: 0.03125 m (assuming square cell)

The hexahedral mesh was generated with `snappyHexMesh` using a background mesh generated with `blockMesh` and an STL file of the cylinder (under `constant/geometry`). The resulting 3D mesh was then extruded to 2D using the `extrudeMesh` utility.

The mesh was modelled after the example in *Section 9.12.2* of [1].

![mesh_full](img/mesh_full.png)

![mesh_close](img/mesh_close.png)

![mesh_courant](img/mesh_courant.png)

The final image shows the Courant number in each cell from an Re=200 simulation.

See the [Grid and Time Step Dependence](#Grid-and-Time-Step-Dependence) section for an analysis on grid sizing.

## Results

### Re=2
* Flow: Laminar, steady state
* Time Step: 1
* Duration: 1.5e4
* Cd: 7.255

At Re=2 the flow is creeping and has no separation around the cylinder.

![Re_2_p_U](img/Re_2_p_U.png)

### Re=20
* Flow: Laminar, steady state
* Time Step: 1
* Duration: 1e4
* Cd: 2.070

At Re=20 there begins to be some separation around the trailing half of the cylinder producing two circulation zones directly behind the cylinder. The flow is still symmetrical and non-oscillatory.

![Re_20_p_U](img/Re_20_p_U.png)

### Re=200
* Flow: Laminar, transient
* Time Step: 0.01 s
* Duration: 60.0 s
* Cd: 1.3511 +/-0.0481 (min=1.3030, max=1.3993)
* Cl: 0.0005 +/-0.7078 (min=-0.7072, max=0.7083)

At Re=200 the flow become oscillatory. The pressure distribution on each side of the cylinder is no longer symmetric, and instead the lowest pressure zone and separation points shift from side to side creating series of trailing vortices known as a vortex street.

Initially the flow will look similar to the Re=20 case (i.e. steady state), but eventually some perturbation will unsettle the flow inducing this oscillatory pattern which will eventually setting on a steady-state sinusoidal pattern. This simulation artifically induces the instability via some initial conditions to make oscillations appear more quickly. See the [Inducing Instability](#Inducing-Instability) section for more details.

The resulting drag and lift coefficients are in close agreement with the values from *Section 9.12.2* of [1]. Although [1] doesn't quote exact values, the plots indicate Cd values in the range [1.302, 1.398] and Cl values in the range [-0.70, 0.70].

The results quoted here are for an *intermediate* mesh and time step size, one that is not prohibitively expensive to compute. See the [Grid and Time Step Dependence](#Grid-and-Time-Step-Dependence) section for results for the Re=200 case with finer mesh and time step sizes.

![Re_200_p_U](img/Re_200_p_U.gif)

![force_coeffs_Re_200](img/force_coeffs_Re_200.png)

## Running The Simulation
There are a set of scripts under the `scripts` directory for running everything. All scripts accept a `-c` option to clear existing data as well as a `-j <CORES>` option for parallelization. Run any script with the `-h` option for usage.

The following examples assume parallel processing with 12 cores for a high Re flow with oscillations.

To mesh:
```bash
./scripts/mesh.sh -j 12
```

To solve:
```bash
./scripts/solve.sh -s -j 12
```
The `-s` option indicates to run the `setFields` operation which will perturb the velocity field to induce instability in oscillatory flows more quickly. Remove if not desired.

To perform meshing and solving in one command:
```bash
./scripts/run_all.sh -s -j 12
```

Everything is currently configured to be parallelized with 12 threads. To alter the number of threads updated `system/decomposeParDict` and call the above scripts with the matching `-j` option. Or, the simulation can be run single threaded by removing the `-j` option from all commands.

### Initial Conditions
The simulation is configured to easily switch between flow regimes by altering the `initialConditions` file under the `include` directory. This file defines all initial conditions and is included everywhere those properties are needed.

The main entries to vary are:
```
// Configuration parameters
Re 200;
transient true;

dt 0.01;
dt_write 60.0;
t_end 60.0;
```

The `transient` flag will control settings in the `fvSchemes` and `fvSolution` files to switch between transient and steady state solutions. For Re > ~40 `transient` must be set to `true`, lower Re can use either but steady state will converge more quickly.

The remaining settings control simulation time and are used within `controlDict`.

### ParaView Configuration
There is a ParaView configuration present that has various visulations setup. To use it start ParaView with `paraFoam -empty` then select `File-->Load State` and direct it to the appropriate folder.

This state file can be used with either decomposed cases or reconstructed cases. Select the appropriate type in the `Properties` pane of the top pipeline element.

There is also a filter present to compute vorticity from the velocity data that is turned off by default.

### Analysis Scripts
There are also additional scripts for analyzing results.

To view a live plot of force coefficients (similar to `pyFoamPlotWatcher.py`):
```bash
octave scripts/plot_force_coeffs.m postProcessing/forces/0/forceCoeffs.dat -Cd 1.1 1.5 -Cl -0.8 0.8
```
The `-Cd` and `-Cl` options specify axis limits.

To evaluate the minimum, maximum, and mean force coefficient values from a `forceCoeffs.dat` file:
```bash
octave scripts/analyze_force_coeffs.m postProcessing/forces/0/forceCoeffs.dat -t 10.0 30.0
```
This will only consider data between 10.0 s and 30.0 s. The results will look like:
```
Force Coefficient Results:
    Cd=1.3511 +/-0.0481 (min=1.3030, max=1.3993)
    Cl=0.0005 +/-0.7078 (min=-0.7072, max=0.7083)
```

To save a batch of results (no mesh or field data):
```bash
./scripts/save_results.sh my_experiment
```
This will copy plots and log data to a new folder under the `results` directory. Use the `-h` option to see more usage information.

## Additional Details

### Grid and Time Step Dependence
Grid and time dependence was analyzed for the Re=200 case, the results of which are below.

The mesh was altered by changing the size of the background mesh cells while performing 4 levels of refinement. Cell sizes quoted here refer to the size after refining the background mesh. Three mesh sizes were considered:
* Coarse: dx=0.0625, 17k cells
* Medium: dx=0.03125, 57k cells
* Fine: dx=0.015625, 209k cells

Time steps were varied from the smallest value of 0.00125 seconds and increased as long as the Courant number remained below 2 for that particular mesh size.

Process for dependence studies:
1. Mesh at desired cell size
1. Simulate at the largest time step for 60 seconds
1. Halve the time step, simulate for an additional 20 seconds
1. Repeat step 3 for all desired time steps
1. Repeat steps 1-4 for all desired mesh sizes

The plot below shows the change in the drag coefficient mean value and amplitude and the lift coefficient amplitude for all mesh and time step combinations.

Key Takeaways:
* The medium mesh with a time step of 0.01 seconds provides a good compromise between accuracy and computational demand. The error is only ~0.5% compared to the finest mesh and smallest time step size considered.
* The results appear to vary quadratically with both time step size and mesh size, as expected with second-order discretization schemes
* The range of mesh sizes and time step sizes considered seems appropriate, it clearly indicates a convergence towards some final value while the magnitude of difference between configuations is large enough that one can make decisions on how to balance computational cost vs. accuracy (coefficient changes of 0.5 between configurations is not helpful, neither are changes of 1e-5).

![dependence_study](img/dependence_study.png)

The complete data from all runs is below:

| Min Cell Size [m] | Cells | Time Step [s] | Cd | Cl | Co Max |
|-|-|-|-|-|-|
| 0.0625 | 17,392 | 0.04 | 1.3533 +/- 0.0514 | 0.0000 +/- 0.7291 | 1.123 |
| 0.0625 | 17,392 | 0.02 | 1.3372 +/- 0.0455 | 0.0001 +/- 0.6826 | 0.570 |
| 0.0625 | 17,392 | 0.01 | 1.3274 +/- 0.0415 | 0.0004 +/- 0.6530 | 0.287 |
| 0.0625 | 17,392 | 0.005 | 1.3218 +/- 0.0393 | 0.0006 +/- 0.6375 | 0.141 |
| 0.0625 | 17,392 | 0.0025 | 1.3193 +/- 0.0385 | 0.0008 +/- 0.6300 | 0.070 |
| 0.0625 | 17,392 | 0.00125 | 1.3179 +/- 0.0382 | 0.0004 +/- 0.6257 | 0.035 |
| 0.03125 | 57,332 | 0.02 | 1.3599 +/- 0.0518 | 0.0001 +/- 0.7344 | 1.222 |
| 0.03125 | 57,332 | 0.01 | 1.3520 +/- 0.0485 | 0.0001 +/- 0.7093 | 0.618 |
| 0.03125 | 57,332 | 0.005 | 1.3469 +/- 0.0464 | -0.0004 +/- 0.6947 | 0.303 |
| 0.03125 | 57,332 | 0.0025 | 1.3442 +/- 0.0453 | -0.0004 +/- 0.6868 | 0.149 |
| 0.03125 | 57,332 | 0.00125 | 1.3429 +/- 0.0450 | -0.0002 +/- 0.6829 | 0.073 |
| 0.015625 | 209,268 | 0.01 | 1.3528 +/- 0.0487 | 0.0003 +/- 0.7112 | 1.719 |
| 0.015625 | 209,268 | 0.005 | 1.3492 +/- 0.0469 | -0.0004 +/- 0.6990 | 0.852 |
| 0.015625 | 209,268 | 0.0025 | 1.3469 +/- 0.0460 | -0.0002 +/- 0.6917 | 0.406 |
| 0.015625 | 209,268 | 0.00125 | 1.3456 +/- 0.0454 | 0.0003 +/- 0.6877 | 0.199 |

### Inducing Instability
When the domain is initialized with a uniform velocity field the flow will eventually become oscillatory, but it can take a while for this to occur.

![force_coeffs_no_perturb](img/force_coeffs_no_perturb.png)

To induce instability more quickly the velocity field in a 2 m wide strip upstream of the cylinder has a 10 degree rotation applied to it. The result is the flow reaches steady-state oscillations in 1/3 the amount of time.

![force_coeffs_with_perturb](img/force_coeffs_with_perturb.png)

Alternate perturbations were experimented with, but a 10 degree upstream rotation was found to reach steady-state oscillations the quickest. Upstream rotations of 5 and 20 degrees behaved similarly, both taking ~2 seconds longer to reach steady-state than the 10 degree version. A downstream rotation of 5 degrees was also tested and peformed worse than all upstream variations taking ~8 seconds longer.

### Compute
An AMD Ryzen9 3900X CPU (12 cores, 3.8 GHz) was used for all computations. The simulation was parallelized with the domain decomposed into 12 partitions.

Measured computation times for various configurations using the Re=200 case with a time step size of 0.010 s, a duration of 60.0 s, and a single write of data at the end.

| Min Cell Size [m] | Cells | Mesh Time [s] | Simulation Time [s] |
|-|-|-|-|
| 0.125 | 4,426 | 7.8 | 25.2 |
| 0.0625 | 17,392 | 15.5 | 65.1 |
| 0.03125 | 57,332 | 45.6 | 251.0 |
| 0.015625 | 209,268 | 163.8 | 1,552.8 |

## References
[1] *Computational Methods for Fluid Dynamics (Fourth Edition)* - J. Ferziger, M. Peric, R. Street.
