#include	"JP/CUDA/JPCuda.h"
using namespace std;

using namespace nvcuda;

#define	D	1024

__constant__ FLOAT_TYPE
query[ D ];

__global__ void
DOT( FLOAT_TYPE* all, FLOAT_TYPE* result, size_t W ) {
	auto x = size_t( blockIdx.x * blockDim.x + threadIdx.x );
	if ( x < W ) {
		result[ x ] = 0;
		auto _ = all + D * x;
		for ( int i = 0; i < D; i++ ) result[ x ] += query[ i ] * _[ i ]; 
	}
}

#include	<chrono>
using namespace chrono;

const size_t
BLOCK_SIZE	= CudaDeviceProp().maxThreadsPerBlock;

void
Main( size_t W ) {

	cerr << "numData : " << W / ( 1024 * 1024 ) << "MiB" << endl;
	cerr << "memory  : " << W * sizeof( FLOAT_TYPE ) * D / ( 1024 * 1024 * 1024 ) << "GiB" << endl;

	system_clock::time_point start;
	start = system_clock::now();

	FLOAT_TYPE queryHOST[ D ];
	for ( size_t _ = 0; _ < D; _++ ) queryHOST[ _ ] = (FLOAT_TYPE)( 1. / D );
	C( cudaMemcpyToSymbol( query, queryHOST, sizeof( FLOAT_TYPE ) * D ) );

	CUDAMemory< FLOAT_TYPE > data( W * D );
	DummyData( data  );
//data.DtoH();
//for ( size_t _ = 0; _ < W * D; _ += 1024 * 8 * D ) cerr << _ << ':' << (float)data( _ ) << endl;

	CUDAMemory< FLOAT_TYPE > result( W );

	cerr << "Initialize: " << duration_cast<milliseconds>( system_clock::now() - start ).count() << endl;

	start = system_clock::now();
	DOT<<< ( W + BLOCK_SIZE ) / BLOCK_SIZE, BLOCK_SIZE >>>( data.$, result.$, W );
	result.DtoH(); //	cudaDeviceSynchronize();
	cerr << "duration first: " << duration_cast<milliseconds>( system_clock::now() - start ).count() << endl;

	start = system_clock::now();
	DOT<<< ( W + BLOCK_SIZE ) / BLOCK_SIZE, BLOCK_SIZE >>>( data.$, result.$, W );
	result.DtoH(); //	cudaDeviceSynchronize();
	cerr << "duration second: " << duration_cast<milliseconds>( system_clock::now() - start ).count() << endl;

/*
	cerr << "STARING VALIDATION" << endl;
	start = system_clock::now();
	data.DtoH();
	auto p = data.Host();
	for ( size_t _ = 0; _ < W; _++ ) {
		auto q = p + D * _;
		double	$ = 0;
		for ( size_t i = 0; i < D; i++ ) $ += double( queryHOST[ i ] ) * double( q[ i ] );
		if ( abs( $ - (double)result( _ ) ) > 0.001 ) cout << _ << ':' << $ << ':' <<  (double)result( _ ) << endl;
	}
	cerr << "validation: " << duration_cast<milliseconds>( system_clock::now() - start ).count() << endl;
*/
}

int
main( int argc, char* argv[] ) {
	try {
		Main( size_t( 1024 * 1024 *  2 ) );
	} catch ( char* ex ) {
		cerr << ex << endl;
	}
}
