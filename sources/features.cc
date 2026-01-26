/** @file features.cc
 *
 *   Utility code for printing available features.
 */
/* #[ License : */
/*
 *   Copyright (C) 1984-2026 J.A.M. Vermaseren
 *   When using this file you are requested to refer to the publication
 *   J.A.M.Vermaseren "New features of FORM" math-ph/0010025
 *   This is considered a matter of courtesy as the development was paid
 *   for by FOM the Dutch physics granting agency and we would like to
 *   be able to track its scientific use to convince FOM of its value
 *   for the community.
 *
 *   This file is part of FORM.
 *
 *   FORM is free software: you can redistribute it and/or modify it under the
 *   terms of the GNU General Public License as published by the Free Software
 *   Foundation, either version 3 of the License, or (at your option) any later
 *   version.
 *
 *   FORM is distributed in the hope that it will be useful, but WITHOUT ANY
 *   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 *   details.
 *
 *   You should have received a copy of the GNU General Public License along
 *   with FORM.  If not, see <http://www.gnu.org/licenses/>.
 */
/* #] License : */
//	#[ Includes :

extern "C" {
#include "form3.h"
}

#include <algorithm>
#include <string>
#include <vector>

#ifdef WITHFLINT
#include <flint/flint.h>
#endif

#ifdef WITHGMP
#include <gmp.h>
#endif

#ifdef WITHMPFR
#include <mpfr.h>
#endif

#ifdef WITHZLIB
#include <zlib.h>
#endif

#ifdef WITHZSTD
#include <zstd.h>
#endif

//	#] Includes : 
//	#[ PrintFeatureList :

/**
 * Prints a list of strings in multiple columns to fit within the line length.
 *
 * @param lines  List of strings to print.
 */
static void PrintMulticolumn(const std::vector<std::string>& lines)
{
	const std::size_t n_lines = lines.size();

	if ( n_lines == 0 ) return;

	const std::size_t line_len = AC.LineLength > 0 ? AC.LineLength : 79;
	constexpr std::size_t max_cols = 6;
	constexpr std::size_t col_spacing = 2;

	std::vector<std::size_t> col_lens(max_cols);

	for ( std::size_t n_cols = max_cols; n_cols >= 2; n_cols-- ) {
		const std::size_t n_rows = (n_lines - 1) / n_cols + 1;

		// Check whether `n_cols` columns fit within the line length.
		// Columns are filled top-to-bottom, then left-to-right.

		std::fill(col_lens.begin(),col_lens.begin()+n_cols,0);

		std::size_t total_len = 0;
		for ( std::size_t  j = 0; j < n_cols; j++ ) {
			for ( std::size_t i = 0; i < n_rows; i++ ) {
				const std::size_t k = i + j * n_rows;
				if ( k >= n_lines ) break;
				col_lens[j] = std::max(col_lens[j],lines[k].size());
			}
			total_len += col_lens[j];
		}
		total_len += (n_cols - 1) * col_spacing;

		if ( total_len > line_len ) continue;

		// Output using `n_cols` columns.

		std::string line;
		line.reserve(line_len);
		for ( std::size_t i = 0; i < n_rows; i++ ) {
			line.clear();
			for ( std::size_t j = 0; j < n_cols; j++ ) {
				const std::size_t k = i + j * n_rows;
				if ( k >= n_lines ) break;
				line += lines[k];
				if ( j < n_cols - 1 ) {
					line += std::string(col_lens[j]-lines[k].size()+col_spacing,' ');
				}
			}
			MesPrint("%s",line.c_str());
		}
		return;
	}

	// Fallback to a single column.

	for ( const auto& f : lines ) {
		MesPrint("%s",f.c_str());
	}
}

/**
 * Prints the list of available features.
 */
void PrintFeatureList(void)
{
	std::vector<std::string> feature_list = {

#ifdef ENABLE_BACKTRACE
		"+backtrace",
#else
		"-backtrace",
#endif

#ifdef DEBUGGING
		"+debugging",
#else
		"-debugging",
#endif

#ifdef WITHFLINT
		"+flint=" + std::string(flint_version),
#else
		"-flint",
#endif

#ifdef WITHFLOAT
		"+float",
#else
		"-float",
#endif

#ifdef WITHGMP
		"+gmp=" + std::string(gmp_version),
#else
		"-gmp",
#endif

#ifdef WITHMPFR
		"+mpfr=" + std::string(mpfr_get_version()),
#else
		"-mpfr",
#endif

#ifdef WITHMPI
		"+mpi",
#else
		"-mpi",
#endif

#ifdef UNIX
		"+posix",
#else
		"-posix",
#endif

#ifdef WITHPTHREADS
		"+pthreads",
#else
		"-pthreads",
#endif

#ifdef WINDOWS
		"+windows",
#else
		"-windows",
#endif

#ifdef WITHZLIB
		"+zlib=" + std::string(zlibVersion()),
#else
		"-zlib",
#endif

#ifdef WITHZSTD
		"+zstd=" + std::string(ZSTD_versionString()),
#else
		"-zstd",
#endif

	};

	PrintMulticolumn(feature_list);
}

//	#] PrintFeatureList : 
