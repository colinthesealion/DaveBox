#!/usr/bin/perl

use strict;
use warnings;
no warnings qw(uninitialized);

use File::Slurp qw(slurp);

use Dimensions;
use LayoutSimple;
use SVG;

my ($key) = @ARGV;

my $layout = SVG::Indent(
	$Dimensions::Padding,
	$Dimensions::Padding,
	LayoutSimple::Complete($key),
);

my $css = slurp('style.css');

printf(
	q{<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="%fmm" height="%fmm" viewBox="0 0 %f %f">%s%s</svg>},
	(@$layout{qw(w h)}) x 2,
	qq{
		<defs>
			<style type="text/css"><![CDATA[
				$css
			]]></style>
		</defs>
	},
	$layout->{svg},
);

exit;
