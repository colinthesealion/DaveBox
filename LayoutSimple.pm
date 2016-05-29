package LayoutSimple;

use strict;
use warnings;
no warnings qw(uninitialized);

use Dimensions;
use SVG;

use List::AllUtils qw(
	max
	sum
);

sub Ports {
	my ($key) = @_;

	my $front = SVG::Overlay(
		SVG::RegularHexagon(11.5, { class => 'route' }),
		SVG::Port({
			%{ $Dimensions::IOPorts{mic_4} },
			label => 'cntrl',
		}),
	);

	my $back = SVG::Port({
		%{ $Dimensions::IOPorts{binding_posts} },
		label => '12V',
	});

	my $left = SVG::JoinHorizontal({
		parts => [
			SVG::JoinVertical({
				parts => [
					SVG::Port({
						%{ $Dimensions::IOPorts{mic_3} },
						label => 'gas',
					}),
					SVG::Port({
						%{ $Dimensions::IOPorts{mic_3} },
						label => 'spd',
					}),
				],
			}),
			{
				w => $Dimensions::Padding,
			},
			SVG::Port({
				%{ $Dimensions::IOPorts{inlet_c20} },
				label => 'brk',
			}),
		],
	});

	my $right = SVG::JoinHorizontal({
		parts => [
			SVG::Port({
				%{ $Dimensions::IOPorts{inlet_c20} },
				label => 'brk',
			}),
			{
				w => $Dimensions::Padding,
			},
			SVG::JoinVertical({
				parts => [
					SVG::Port({
						%{ $Dimensions::IOPorts{mic_3} },
						label => 'gas',
					}),
					SVG::Port({
						%{ $Dimensions::IOPorts{mic_3} },
						label => 'spd',
					}),
				],
			}),
		],
	});

	my $max_height = max(map { $_->{h} } $front, $back, $left, $right);
	$front->{h} = $max_height;
	$back->{h} = $max_height;
	$left->{h} = $max_height;
	$right->{h} = $max_height;

	if ($key eq 'front') {
		return $front;
	}
	elsif ($key eq 'back') {
		return $back;
	}
	elsif ($key eq 'left') {
		return $left;
	}
	elsif ($key eq 'right') {
		return $right;
	}

	die "Unknown port: $key";
}

sub Innards {
	my ($key) = @_;
	my $bottom  = SVG::Indent(
		2 * $Dimensions::Padding, 2 * $Dimensions::Padding,
		SVG::JoinVertical({
			parts => [
				SVG::JoinHorizontal({
					align => 'BOTTOM',
					parts => [
						SVG::Part({
							%{ $Dimensions::Parts{perma_proto_quarter} },
							label => '5V',
						}),
						SVG::Part({
							%{ $Dimensions::Parts{arduino} },
							label => 'arduino',
						}),
					],
				}),
				SVG::JoinHorizontal({
					align => 'TOP',
					parts => [
						SVG::Part({
							%{ $Dimensions::Parts{power_bus} },
							label => '12V',
						}),
						SVG::Part({
							%{ $Dimensions::Parts{relay_board} },
							label => 'relays',
						}),
					],
				}),
			],
		}),
	);
	if ($key eq 'bottom') {
		return $bottom;
	}

	if ($key eq 'top') {
		return {
			w => $bottom->{w},
			h => $bottom->{h},
			# Easel doesn't like text
			#svg => SVG::Text('dave', {
			#	position => {
			#		x => $bottom->{w} / 2,
			#		y => $bottom->{h} / 2,
			#	},
			#	class => 'etch'
			#}),
		};
	}

	if ($key eq 'front' || $key eq 'back') {
		return SVG::JoinVertical({
			parts => [
				{
					w => $bottom->{w},
					h => $Dimensions::Padding,
				},
				Ports($key),
				{
					w => $bottom->{w},
					h => $Dimensions::MaxPartsHeight,
				},
				{
					w => $bottom->{w},
					h => 6,
				},
				{
					w => $bottom->{w},
					h => 0.1,
				},
			],
		});
	}

	if ($key eq 'left' || $key eq 'right') {
		return SVG::JoinVertical({
			parts => [
				{
					w => $bottom->{h},
					h => $Dimensions::Padding,
				},
				Ports($key),
				{
					w => $bottom->{h},
					h => $Dimensions::MaxPartsHeight,
				},
				{
					w => $bottom->{h},
					h => 6,
				},
				{
					w => $bottom->{h},
					h => 0.1,
				},
			],
		});
	}

	die "Unknown innards: $key";
}

sub Enclosure {
	my ($key) = @_;

	my $innards = Innards($key);
	if ($key eq 'bottom') {
		return {
			w => $innards->{w} + 2 * $Dimensions::Padding,
			h => $innards->{h} + 2 * $Dimensions::Padding,
			svg => SVG::Rect(
				$innards->{w} + 2 * $Dimensions::Padding,
				$innards->{h} + 2 * $Dimensions::Padding,
				{ class => 'cut' },
			),
		};
	}
	elsif ($key eq 'top') {
		my $w = $innards->{w} + 2 * $Dimensions::Padding + 2 * $Dimensions::Materials{plexiglass}{thickness};
		my $h = $innards->{h} + 2 * $Dimensions::Padding + 2 * $Dimensions::Materials{plexiglass}{thickness};
		return {
			w => $w,
			h => $h,
			svg => SVG::Rect($w, $h, { class => 'cut' }),
		};
	}
	elsif ($key eq 'front' || $key eq 'back') {
		return {
			w => $innards->{w} + 2 * $Dimensions::Padding,
			h => $innards->{h},
			svg => SVG::Rect(
				$innards->{w} + 2 * $Dimensions::Padding,
				$innards->{h},
				{ class => 'cut' },
			),
		};
	}
	elsif ($key eq 'left' || $key eq 'right') {
		my $tab_size = $innards->{h} / 5;
		my $slot_size = ($innards->{w} + 2 * $Dimensions::Padding) / 7;
		return {
			w => $innards->{w} + 2 * $Dimensions::Padding + 2 * $Dimensions::Materials{plexiglass}{thickness},
			h => $innards->{h},
			svg => join('', (
				SVG::Rect(
					$innards->{w} + 2 * $Dimensions::Padding + 2 * $Dimensions::Materials{plexiglass}{thickness},
					$innards->{h},
					{ class => 'cut' },
				),
				map {
					SVG::Circle(
						$Dimensions::Materials{bolts}{r},
						@$_,
						{ class => 'cut' },
					);
				} (
					[$Dimensions::Materials{plexiglass}{thickness} / 2, 3 * $tab_size / 2],
					[$Dimensions::Materials{plexiglass}{thickness} / 2, 7 * $tab_size / 2],
					[$innards->{w} + 2 * $Dimensions::Padding + 3 * $Dimensions::Materials{plexiglass}{thickness} / 2, 3 * $tab_size / 2],
					[$innards->{w} + 2 * $Dimensions::Padding + 3 * $Dimensions::Materials{plexiglass}{thickness} / 2, 7 * $tab_size / 2],
					[$Dimensions::Materials{plexiglass}{thickness} + 3 * $slot_size / 2, $innards->{h} - $Dimensions::Materials{plexiglass}{thickness} - $Dimensions::Padding],
					[$Dimensions::Materials{plexiglass}{thickness} + 7 * $slot_size / 2, $innards->{h} - $Dimensions::Materials{plexiglass}{thickness} - $Dimensions::Padding],
					[$Dimensions::Materials{plexiglass}{thickness} + 11 * $slot_size / 2, $innards->{h} - $Dimensions::Materials{plexiglass}{thickness} - $Dimensions::Padding],
				),
			)),
		};
	}

	die "Unknown enclosure: $key";
}

sub Complete {
	my ($key) = @_;

	return SVG::Overlay(
		Innards($key),
		Enclosure($key),
	);
}

1;
