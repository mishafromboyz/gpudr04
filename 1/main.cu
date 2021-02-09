#include <iostream>

using namespace std;

const int vsize = 512;
const int blocksize = 256;

__global__
void vsum(float *x, float *y, float *z)
{
	//int i = blockIdx.x * blockDim.x + threadIdx.x; @ blockdim, not block_size @
	int i = blockIdx.x * blocksize + threadIdx.x;
	if(i < vsize)
		z[i] = x[i]+y[i]; 
}



int main()
{
	float *A = (float*)malloc(vsize*sizeof(float));
	float *B = (float*)malloc(vsize*sizeof(float));
	float *C = (float*)malloc(vsize*sizeof(float));


	for(int i = 1; i<=vsize; i++)
	{
		A[i]=(float)i;
		B[i]=(float)i;
		//C[i]=(float)i;
	}



	float *dA, *dB, *dC;
	cudaMalloc(&dA, vsize * sizeof(float));
	cudaMalloc(&dB, vsize * sizeof(float));
	cudaMalloc(&dC, vsize * sizeof(float));


	cudaMemcpy(dA, A, vsize*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(dB, B, vsize*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(dC, C, vsize*sizeof(float), cudaMemcpyHostToDevice);

	vsum<<<(vsize/blocksize), blocksize>>>(A, B, C); 
	cudaDeviceSynchronize();

	
	for (int i = 0; i<vsize; i+=16)
	{
		for (int j = 0; j<32; j++)
			cout << C[j] << " ";
		cout << endl;
	}

	cudaFree(dA);
	cudaFree(dB);
	cudaFree(dC);
	free(A);
	free(B);
	free(C);

	return 0;
}