package Dimensions;

use strict;
use warnings;
no warnings qw(uninitialized);

use List::AllUtils qw(
	max
	sum
);

# All measurements in mm
our %Parts = (
	arduino => {
		w => 53.3,
		h => 68.6,
		holes => [
			{
				r => 1.25,
				cx => 2.5,
				cy => 14,
			},
			{
				r => 1.25,
				cx => 53.3 - 2.5,
				cy => 15.3,
			},
			{
				r => 1.25,
				cx => 7.6,
				cy => 15.3 + 50.8,
			},
			{
				r => 1.25,
				cx => 35.5,
				cy => 15.3 + 50.8,
			},
		],
	},
	perma_proto_quarter => {
		h => 55,
		w => 44,
		holes => [
			{
				r => 1.25,
				cx => 4.22,
				cy => 27.5,
			},
			{
				r => 1.25,
				cx => 44 - 4.22,
				cy => 27.5,
			},
		],
	},
	power_bus => {
		w => 46.4,
		h => 76.5,
		holes => [
			{
				r => 1.25,
				cx => 46.4 / 2,
				cy => 9.35,
			},
			{
				r => 1.25,
				cx => 46.4 / 2,
				cy => 76.5 - 9.35,
			},
		],
	},
	relay_board => {
		w => 55,
		h => 75,
		holes => [
			{
				r => 1.25,
				cx => 2.935,
				# 75 is the height of the board
				# 72 - 3.2 is the distance between the holes
				cy => (75 - (72 - 3.2)) / 2,
			},
			{
				r => 1.25,
				cx => 55 - 2.935,
				cy => (75 - (72 - 3.2)) / 2,
			},
			{
				r => 1.25,
				cx => 55 - 2.935,
				cy => 75 - (75 - (72 - 3.2)) / 2,
			},
			{
				r => 1.25,
				cx => 2.935,
				cy => 75 - (75 - (72 - 3.2)) / 2,
			},
		],
	},
);

our %IOPorts = (
	mic_3 => {
		w => 25.75,
		h => 31.78,
		holes => [
			{
				r => 11.5,
				cx => 25.75 / 2,
				cy => 31.78 / 2,
			},
			{
				r => 2.7,
				cx => 3.8,
				cy => 3.8,
			},
			{
				r => 2.7,
				cx => 25.75 - 3.8,
				cy => 31.78 - 3.8,
			},
		],
	},
	mic_4 => {
		h => 18.6,
		w => 18.6,
		holes => [
			{
				r => 8,
				cx => 9.3,
				cy => 9.3,
			},
		],
	},
	binding_posts => {
		h => 15,
		w => 33,
		holes => [
			{
				r => 2.1,
				cx => 7,
				cy => 7.5,
			},
			{
				r => 2.1,
				cx => 33 - 7,
				cy => 7.5,
			},
		],
	},
	inlet_c20 => {
		h => 30.2,
		w => 52.77,
		holes => [
			{
				w => 32.6 + 1,
				h => 24.1 + 1,
				x => 52.77 / 2,
				y => 30.2 / 2,
			},
			{
				r => 1.75,
				cx => (52.77 - 42.75) / 2,
				cy => 30.2 / 2,
			},
			{
				r => 1.75,
				cx => (52.77 + 42.75) / 2,
				cy => 30.2 / 2,
			},
		],
	},
);

our %Materials = (
	plexiglass => {
		thickness => 6.3,
	},
	bolts => {
		r => 1.9,
		l => 25.4,
	},
	nuts => {
		h => 8.1,
		w => 8.1,
		d => 3,
	},
);

our $Padding = 5;
our $Tolerance = 1;
our $MaxPartsHeight = 40;
our $FontSize = 15;
our $BitSize = 3.175; # mm = 0.125in
