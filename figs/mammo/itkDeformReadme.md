itkDeformRegistration summary
---
2. Vanilla Demons algorithm ( preprocess the moving image to match the pixel intensity's distribution to that of the fixed image without the background pixels)
3. Symmetric demons: uses a different formulation for computing the forces to be applied to the image in order to compute the deformation fields. It uses both the gradient of the fixed image and the gradient of the deformed moving image in order to compute the forces. However, this symmetry only holds during the computation of one iteration of the PDE updates. unlikely that total symmetry may be achieved by this mechanism

4. BSplineTransform + LBFGSOptimizer (instead of vanilla gradient descent or a conjugate gradient descent to deal with a large number of parameters) + COrrelationImage metric

5. Levelset motion 

6. BSplineTransform + 3 level of resolution (multi-resolution scheme) 
// The first level of registration is performed with the spline grid of
// low resolution. Then, a common practice is to increase the resolution
// of the B-spline mesh (or, analogously, the control point grid size)
// at each level. 

12. BSplineTrnasofmr + LBFGSBOptimizer

13. BSplineTrnasofmr + Regular Step Gradient Descent Optimizer

16. Demons + 4 multi-resolution level

17. Multi-resolution  symmetric forces demons registration - 4 multi-resolution levels



