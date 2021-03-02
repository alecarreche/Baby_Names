# Similar Baby Names over Time

## similar_names.jl

`julia similar_names.jl`

**Note on Parallelization:**

In part 9, the computation of dot products is performed using matrix multiplication instead of individual dot product computation. 
By using matrix multiplication using the `mul!` function in the LinearAlgebra library, we are able to access the benefits 
of the multithreading used in the BLAS implementation without explicitely using multithreading in our code. 
This can be verified by observing execution time with `BLAS.set_num_threads(1)` versus the default setting. 
As an extra precaution, however, we explicitely set BLAS to 8 threads using `BLAS.set_num_threads(8)`.
Lastly, we further enhance execution time by splitting the multiplication into 100 smaller matrix multiplications, since matrix multiplication occurs in greater than linear time. 

