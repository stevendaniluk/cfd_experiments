# Ahmed Body
This is an OpenFOAM case to similuate an Ahmed body in a wind tunnel. The original experiment is from [1], while [2] is used for more recent experiments and CFD results.

![ahmed_body](img/ahmed_body.png)

## Running the Case
The following scripts are available to execute the case:
* `clean.bash`: Remove all run artifacts
* `mesh.bash`: Generates the mesh (includes reconstruction)
* `solve.bash`: Executes the solver (include reconstruction)
* `run_all.bash`: Runs the 3 scripts above

The case is setup to be decomposed into 10 partitions. To alter this you will need to edit the value of `numberOfSubdomains` in `system/decomposeParDict`, as well as the `CORES` variable in `mesh.bash` and `solve.bash`.

There is a ParaView state file, `analysis.pvsm`, that will generate all visualations presented below.

## Simulation Setup

* Flow Speed: 40 m/s
* Reynolds Number: 4,290,000
* Kinematic Viscosity: 1.5e-5 m^2/s
* Temporal: Steady State
* Solver: SIMPLE
* Turbulence Model: k-omega SST
* Turbulence Intensity: 1%
* Iterations: 1,400
* CPU Time: 3.5 hours (350 core hours)

### Boundary Conditions

| Parameter | Inlet | Outlet | Floor | Roof/Walls | Body |
|-|-|-|-|-|-|
| Velocity | Fixed Value | Zero Gradient | No Slip | Symmetry | No Slip |
| Pressure | Zero Gradient | Fixed Value | Zero Gradient | Symmetry | Zero Gradient |
| *k* | Fixed Value | Zero Gradient | Wall Function | Symmetry | Wall Function |
| *omega* | Fixed Value | Zero Gradient | Wall Function | Symmetry | Wall Function |

The length of the tunnel ahead of the body positioned to achieve a boundary layer thickness of 30mm at the front most point of the Ahmed body. Using the Blasius solution this distance was computed to be 1,749 mm. A simulation with an empty tunnel was run, and the resulting boundary layer height was within 5% of the target.

The size of virtual tunnel was decreased slightly relative to [2] and [3] due to limited computational ability.

### Mesh
SnappyHexMesh was used to generate the mesh:
* Tunnel dimensions: 10.0x3.0x2.0 m (length x width x height)
* Background mesh cell size: 10mm
* 5 levels of refinement around the Ahmed body (final layer size of 3.125mm)
* Refinement box of size 1.2x0.39x0.36m (length x width x height) behind Ahmed body with a refinement level of 5 (3.125mm cell size)
* 2 levels of refinement above ground plane, extending 0.25m

Cells: 9.124 million
* Hexahedra: 8.98e6
* Polyhedra: 1.35e5
* Prism: 1.02e4

The boundary layer refinement was tuned to keep the y-plus values in an appropriate range. The resulting values were:
* Minimum: 5.6
* Average: 44.5
* Maximum:170.0

![mesh_large_view](img/mesh_large_view.png)

![mesh_mid_view](img/mesh_mid_view.png)

![mesh_boundary_layer](img/mesh_boundary_layer.png)

### Compute:
The simulation was decomposed into 10 partitions. It was run on an AMD Ryzen9 3900X CPU.

## Results

|Parameter| CFD | Wind Tunnel - *Meile* [2] | CFD - *Meile* [2] |
|-|-|-|-|
|**Cd**| 0.292 | 0.299 | 0.295 |
|**Cl**| 0.405 | 0.345 | 0.387 |

In [1] the vortex structure in the wake of the vehicle is shown as having one vortex induced by the slant edges, then two horseshoe vortices behind the flat back of the body.

![ahmed_vortex_system](img/ahmed_vortex_system.png)

The trailing vortices due to the slant edges were properly captured by the CFD simulation.

![exp_slant_edge_vortex_1](img/exp_slant_edge_vortex_1.png)

![exp_slant_edge_vortex_2](img/exp_slant_edge_vortex_2.png)

|Distance| *Ahmed* [1] | CFD |
|-|-|-|
| x=0.08 m | ![ahmed_wake_lateral_v_field_08](img/ahmed_wake_lateral_v_field_08.png)|![exp_wake_lateral_v_field_08](img/exp_wake_lateral_v_field_08.png) |
| x=0.20 m | ![ahmed_wake_lateral_v_field_20](img/ahmed_wake_lateral_v_field_20.png)|![exp_wake_lateral_v_field_20](img/exp_wake_lateral_v_field_20.png) |
| x=0.50 m | ![ahmed_wake_lateral_v_field_50](img/ahmed_wake_lateral_v_field_50.png)|![exp_wake_lateral_v_field_50](img/exp_wake_lateral_v_field_50.png) |

The two horseshoe vortices behind the vehicle where generated (A and B in the figure from [1]) in CFD, however the lower vortex, B, is substantially less developed in the CFD solution compared to the experimental results from [1]. The benchmark cases from [3] and [4] also shows the lower vortex substantially more developed than what was produced here.

![exp_streamlines_side_view](img/exp_streamlines_side_view.png)

![exp_wake_longitudinal_v_field](img/exp_wake_longitudinal_v_field.png)

The separation of the trailing vortices also matches the results from the TCFD case [3].

![exp_streamlines_rear_view](img/exp_streamlines_rear_view.png)

![exp_streamlines_top_view](img/exp_streamlines_top_view.png)

Some additional flow visualizations:

![exp_surface_vectors_front](img/exp_surface_vectors_front.png)

![exp_surface_vectors_rear](img/exp_surface_vectors_rear.png)

![exp_surface_vectors_bottom](img/exp_surface_vectors_bottom.png)

## References

[1] *S.R. Ahmed, G. Ramm, Some Salient Features of the Time-Averaged Ground Vehicle Wake, SAE-Paper 840300,
1984*

[2] *W. Meile, G. Brenn, A. Reppenhagen, B. Lechner, A. Fuchs, Experiments and numerical simulations on the aerodynamics of the Ahmed body, CFD Letters 3(1), 2011*

[3] [*TCFD, Ahmed Body External Aerodynamics
CFD Benchmark using TCFD*](https://www.cfdsupport.com/download/TCFD-CFDSUPPORT-Ahmed-Body-External-Aerodynamics-Benchmark.pdf)

[4] [*SimFlow, Flow around the Ahmed body - CFD Simulation, SimFlow Validation Case*](https://help.sim-flow.com/validation/ahmed-body)
