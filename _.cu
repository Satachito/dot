#include	"JP/CUDA/JPCuda.h"
using namespace std;

using namespace nvcuda;

#define	D	1024

template < typename F > __global__ void
DOT( F* all, F* query, F* result, size_t W ) {
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
MTPB	= CudaDeviceProp().maxThreadsPerBlock;

template < typename F > void
Main( size_t W ) {

	cerr << "numData : " << W / ( 1024 * 1024 ) << "MiB" << endl;
	cerr << "memory  : " << W * sizeof( F ) * D / ( 1024 * 1024 * 1024 ) << "GiB" << endl;

	system_clock::time_point start;
	start = system_clock::now();

	CUDAMemory< F > data( W * D );
	DummyData( data  );
//data.DtoH();
//for ( size_t _ = 0; _ < W * D; _ += 1024 * 8 * D ) cerr << _ << ':' << (float)data( _ ) << endl;

	CUDAMemory< F > result( W );

	cerr << "Initialize: " << duration_cast<milliseconds>( system_clock::now() - start ).count() << endl;

	start = system_clock::now();
	DOT<<< ( W + MTPB ) / MTPB, MTPB >>>( data.$, data.$, result.$, W );
	result.DtoH(); //	cudaDeviceSynchronize();
	cerr << "duration first: " << duration_cast<milliseconds>( system_clock::now() - start ).count() << endl;

	start = system_clock::now();
	DOT<<< ( W + MTPB ) / MTPB, MTPB >>>( data.$, data.$, result.$, W );
	result.DtoH(); //	cudaDeviceSynchronize();
	cerr << "duration second: " << duration_cast<milliseconds>( system_clock::now() - start ).count() << endl;

	cerr << "STARING VALIDATION" << endl;
	start = system_clock::now();
	data.DtoH();
	auto p = data.Host();
	for ( size_t _ = 0; _ < W; _++ ) {
		auto q = p + D * _;
		double	$ = 0;
		for ( size_t i = 0; i < D; i++ ) $ += double( p[ i ] ) * double( q[ i ] );
		if ( abs( $ - (double)result( _ ) ) > 0.001 ) cout << _ << ':' << $ << ':' <<  (double)result( _ ) << endl;
	}
	cerr << "validation: " << duration_cast<milliseconds>( system_clock::now() - start ).count() << endl;
}

int
main( int argc, char* argv[] ) {
	try {
		Main< FLOAT_TYPE >( size_t( 1024 * 1024 *  2 ) );
	} catch ( char* ex ) {
		cerr << ex << endl;
	}
}
