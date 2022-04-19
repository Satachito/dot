#include	<iostream>
using namespace std;

#include	<chrono>
using namespace chrono;

template	<typename F>	void
DOT( F* all, F* query, F* result, size_t nDim, size_t x ) {
	result[ x ] = 0;
	auto _ = all + nDim * x;
	for ( int i = 0; i < nDim; i++ ) result[ x ] += query[ i ] * _[ i ]; 
}

template	<typename F>	void
Main( size_t W ) {
cerr << "numData : " << W / ( 1024 * 1024 ) << 'M' << endl;
//	1024 dim の W 個分のデータ
	auto _ = new F[ W * 1024 ];
	for ( size_t i = 0; i < W * 1024; i++ ) _[ i ] = 2;
cerr << "memory  : " << W * sizeof( F ) / ( 1024 * 1024 ) << 'G' << endl;
//	結果
auto start = system_clock::now();
	auto $ = new F[ W ];
#pragma omp parallel for
	for ( size_t i = 0; i < W; i++ ) {
		DOT( _, _, $, 1024, i );
	}
auto duration = duration_cast<milliseconds>( system_clock::now() - start ).count();

cerr << "duration: " << duration << endl;

	for ( size_t x = 0; x < W; x++ ) if ( $[ x ] != 4096 ) {
		cerr << x << ':' << $[ x ] << endl;
		throw "eh?";
	}

	delete[] _;
	delete[] $;
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
