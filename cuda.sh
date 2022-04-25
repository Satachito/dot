echo "LEGACY double"
nvcc -arch=sm_86 -lcublas -lcurand -DCUDA_LEGACY -DFLOAT_TYPE=double _.cu
./a.out
echo

echo "MANAGED double"
nvcc -arch=sm_86 -lcublas -lcurand -DCUDA_MANAGED -DFLOAT_TYPE=double _.cu
./a.out
echo

echo "LEGACY float"
nvcc -arch=sm_86 -lcublas -lcurand -DCUDA_LEGACY -DFLOAT_TYPE=float _.cu
./a.out
echo

echo "MANAGED float"
nvcc -arch=sm_86 -lcublas -lcurand -DCUDA_MANAGED -DFLOAT_TYPE=float _.cu
./a.out
echo

echo "LEGACY half"
nvcc -arch=sm_86 -lcublas -lcurand -DCUDA_LEGACY -DFLOAT_TYPE=half _.cu
./a.out
echo

echo "MANAGED half"
nvcc -arch=sm_86 -lcublas -lcurand -DCUDA_MANAGED -DFLOAT_TYPE=half _.cu
./a.out
echo

