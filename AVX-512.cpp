#include	<iostream>
using namespace std;

#include	<chrono>
using namespace chrono;

#include <immintrin.h>

#define	D	1024

float
Dot( float* l, float* r, size_t nBlocks, __m512 v = _mm512_setzero_ps() ) {
    for ( auto i = 0; i < nBlocks; i++ ) {
        v = _mm512_fmadd_ps(
            _mm512_load_ps( l + i * 16 )
        ,   _mm512_load_ps( r + i * 16 )
        ,   v
        );
    }
    return _mm512_reduce_add_ps( v );
}

/*
template    < typename T >  T
Dot_MultiAVX512( T* l, T* r, size_t size ) {
    future< T > wVs[ NUM_THREADS ];

    auto    nBlocks = size * sizeof( T ) / 64;

    auto    wR = nBlocks % NUM_THREADS;
    auto    wD = nBlocks / NUM_THREADS;
    size_t  wIndex = 0;
    for ( auto i = 0; i < wR; i++ ) {
        wVs[ i ] = async( [=]{ return MulAdd( l + wIndex, r + wIndex, wD + 1 ); } );
        wIndex += ( wD + 1 ) * ( 64 / sizeof( T ) );
    }
    for ( auto i = wR; i < NUM_THREADS; i++ ) {
        wVs[ i ] = async( [=]{ return MulAdd( l + wIndex, r + wIndex, wD ); } );
        wIndex += wD * ( 64 / sizeof( T ) );
    }

    T   v = 0;
    for ( auto i = nBlocks * ( 64 / sizeof( T ) ); i < size; i++ ) v += l[ i ] * r[ i ];
    for ( auto i = 0; i < NUM_THREADS; i++ ) v += wVs[ i ].get();
    return v;
}
*/

template	<typename F>	void
Main( size_t W ) {
cerr << "numData : " << W / ( 1024 * 1024 ) << 'M' << endl;
cerr << "memory  : " << W * D * sizeof( F ) / ( 1024 * 1024 * 1024 ) << 'G' << endl;

//	D dim の W 個分のデータ
	auto data = new ( align_val_t{ 64 } ) F[ W * D ];
	for ( size_t _ = 0; _ < W * D; _++ ) data[ _ ] = 2;
//	結果
auto start = system_clock::now();
	auto result = new F[ W ];
	for ( size_t _ = 0; _ < W; _++ ) result[ _ ] = Dot( data, data + _ * D, D / 16 );
auto duration = duration_cast<milliseconds>( system_clock::now() - start ).count();

cerr << "duration: " << duration << endl;

	for ( size_t _ = 0; _ < W; _++ ) if ( result[ _ ] != 4096 ) {
		cerr << _ << ':' << result[ _ ] << endl;
		throw "eh?";
	}

	delete[] data;
	delete[] result;
}

int
main( int argc, char* argv[] ) {
//	Main<float>( size_t( 1024 * 1024 *  1 ) );
	Main<float>( size_t( 1024 * 1024 *  2 ) );
//	Main<float>( size_t( 1024 * 1024 *  3 ) );
//	Main<float>( size_t( 1024 * 1024 *  4 ) );
//	Main<float>( size_t( 1024 * 1024 *  5 ) );
//	Main<float>( size_t( 1024 * 1024 *  6 ) );
//	Main<float>( size_t( 1024 * 1024 *  7 ) );
//	Main<float>( size_t( 1024 * 1024 *  8 ) );
//	Main<float>( size_t( 1024 * 1024 *  9 ) );
//	Main<float>( size_t( 1024 * 1024 * 10 ) );
//	Main<float>( size_t( 1024 * 1024 * 11 ) );
}

/*
256K: 1G duration: 235
1024K: 4G duration: 938
8192K: 32G duration: 8825
*/
