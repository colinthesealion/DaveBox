package SVG;

use strict;
use warnings;
no warnings qw(uninitialized);

use List::AllUtils qw(
	max
	sum
);
use Math::Trig;

sub Path {
	my ($points, $args) = @_;
	return sprintf(
		q{<path d="%s" class="%s" />},
		join(' ', map {
			$#$_
				? "$_->[0]$_->[1] $_->[2]"
				: $_->[0];
		} @$points),
		$args->{class},
	);
}

sub Rect {
	my ($width, $height, $args) = @_;
	return sprintf(
		q{<rect width="%f" height="%f" class="%s" />},
		$width,
		$height,
		$args->{class},
	);
}

sub Text {
	my ($text, $args) = @_;
	return sprintf(
		q{<text x="%f" y="%f" class="%s">%s</text>},
		$args->{position}{x},
		$args->{position}{y},
		$args->{class},
		$text,
	);
}

sub Circle {
	my ($r, $cx, $cy, $args) = @_;
	return sprintf(
		q{<circle r="%f" cx="%f" cy="%f" class="%s" />},
		$r, $cx, $cy, $args->{class},
	);
}

sub Part {
	my ($args) = @_;

	my $svg = Rect(@$args{qw(w h)}, { class => 'etch' });
	# Easel no like tet
	if (0 && $args->{label}) {
		$svg .= Text($args->{label}, {
			position => {
				x => $args->{w} / 2,
				y => $args->{h} / 2,
			},
			class => 'etch',
		});
	}
	foreach my $hole (@{ $args->{holes} || [] }) {
		$svg .= Circle(@$hole{qw(r cx cy)}, { class => 'cut' });
	}

	return {
		w => $args->{w},
		h => $args->{h},
		svg => $svg,
	};
}

sub JoinHorizontal {
	my ($args) = @_;

	my @parts = @{ $args->{parts} };

	my $h = max(
		map { $_->{h} } @parts,
	);
	my $w = sum(
		(map { $_->{w} } @parts),
		($Dimensions::Padding) x $#parts,
	);

	my $x = 0;
	my $svg = join("\n", map {
		my $part = $_;
		my $part_svg = sprintf(
			q{<g transform="translate(%f, %f)">%s</g>},
			$x,
			($args->{align} eq 'BOTTOM')
				? $h - $part->{h}
				: 0,
			$part->{svg},
		);
		$x += $part->{w} + $Dimensions::Padding;
		$part_svg;
	} @parts);

	return {
		h => $h,
		w => $w,
		svg => $svg,
	};

}

sub JoinVertical {
	my ($args) = @_;

	my @parts = @{ $args->{parts} };

	my $h = sum(
		(map { $_->{h} } @parts),
		($Dimensions::Padding) x $#parts,
	);
	my $w = max(
		map { $_->{w} } @parts,
	);

	my $y = 0;
	my $svg = join("\n", map {
		my $part = $_;
		my $part_svg = sprintf(
			q{<g transform="translate(%f, %f)"><g transform="translate(%f,0)">%s</g></g>},
			$w / 2,
			$y,
			-$part->{w} / 2,
			$part->{svg},
		);
		$y += $part->{h} + $Dimensions::Padding;
		$part_svg;
	} @parts);

	return {
		h => $h,
		w => $w,
		svg => $svg,
	};
}

sub Overlay {
	my @parts = @_;

	my $h = max(map { $_->{h} } @parts);
	my $w = max(map { $_->{w} } @parts);
	my $svg = sprintf(
		q{<g transform="translate(%f, %f)">%s</g>},
		$w / 2,
		$h / 2,
		join("\n", map {
			sprintf(
				q{<g transform="translate(%f, %f)">%s</g>},
				-$_->{w} / 2,
				-$_->{h} / 2,
				$_->{svg},
			);
		} @parts),
	);

	return {
		h => $h,
		w => $w,
		svg => $svg,
	};
}

sub Tabs {
	my ($args) = @_;

	my @path;
	push(@path, ['M', $Dimensions::Materials{plexiglass}{thickness}, $Dimensions::Materials{plexiglass}{thickness}]);

	my $tab_width = $args->{w} / $args->{count}{w};
	push(@path, ['l', $tab_width, 0]);
	my $direction = -1;
	for (my $i = 1; $i < $args->{count}{w}; $i++) {
		push(@path, ['l', 0, $direction * $Dimensions::Materials{plexiglass}{thickness}]);
		push(@path, ['l', $tab_width, 0]);
		$direction *= -1;
	}

	my $tab_height = $args->{h} / $args->{count}{h};
	push(@path, ['l', 0, $tab_height]);
	$direction = 1;
	for (my $i = 1; $i < $args->{count}{h}; $i++) {
		push(@path, ['l', $direction * $Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@path, ['l', 0, $tab_height]);
		$direction *= -1;
	}

	push(@path, ['l', -$tab_width, 0]);
	$direction = 1;
	for (my $i = 1; $i < $args->{count}{w}; $i++) {
		push(@path, ['l', 0, $direction * $Dimensions::Materials{plexiglass}{thickness}]);
		push(@path, ['l', -$tab_width, 0]);
		$direction *= -1;
	}

	push(@path, ['l', 0, -$tab_height]);
	$direction = -1;
	for (my $i = 1; $i < $args->{count}{h}; $i++) {
		push(@path, ['l', $direction * $Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@path, ['l', 0, -$tab_height]);
		$direction *= -1;
	}
	push(@path, ['Z']);

	return {
		h => $args->{h} + 2 * $Dimensions::Materials{plexiglass}{thickness},
		w => $args->{w} + 2 * $Dimensions::Materials{plexiglass}{thickness},
		svg => Path(\@path, $args),
	};
}

sub Indent {
	my ($x, $y, $svg) = @_;
	return {
		w => $svg->{w} + 2 * $x,
		h => $svg->{h} + 2 * $y,
		svg => sprintf(q{<g transform="translate(%f, %f)">%s</g>}, $x, $y, $svg->{svg}),
	};
}

sub Dovetail {
	my ($args) = @_;
	if ($args->{innie}) {
		return DovetailIn($args);
	}
	else {
		return DovetailOut($args);
	}
}

sub BoltSlot {
	my ($slot_height, $direction) = @_;

	my $bolt_slot_height = 2 * $Dimensions::Materials{bolts}{r};
	my $bolt_offset_h = ($slot_height - $bolt_slot_height) / 2;
	my $nut_slot_height = $Dimensions::Materials{nuts}{h};
	my $nut_slot_width = $Dimensions::Materials{nuts}{d};
	my $bolt_slot_width = $Dimensions::Materials{bolts}{l} - $Dimensions::Materials{plexiglass}{thickness};
	my $nut_offset_w = ($bolt_slot_width - $nut_slot_width) / 2;
	my $nut_offset_h = ($nut_slot_height - $bolt_slot_height) / 2;

	return (
		['l', 0, $direction * $bolt_offset_h],
		['l', -$direction * $nut_offset_w, 0],
		['l', 0, -$direction * $nut_offset_h],
		['l', -$direction * $nut_slot_width, 0],
		['l', 0, $direction * $nut_offset_h],
		['l', -$direction * $nut_offset_w, 0],
		['l', 0, $direction * $bolt_slot_height],
		['l', $direction * $nut_offset_w, 0],
		['l', 0, $direction * $nut_offset_h],
		['l', $direction * $nut_slot_width, 0],
		['l', 0, -$direction * $nut_offset_h],
		['l', $direction * $nut_offset_w, 0],
		['l', 0, $direction * $bolt_offset_h],
	);
}

sub BoltSlot2 {
	my ($slot_height, $direction) = @_;

	my $bolt_slot_height = 2 * $Dimensions::Materials{bolts}{r};
	my $bolt_offset_h = ($slot_height - $bolt_slot_height) / 2;
	my $nut_slot_height = $Dimensions::Materials{nuts}{h};
	my $nut_slot_width = $Dimensions::Materials{nuts}{d};
	my $bolt_slot_width = $Dimensions::Materials{bolts}{l} - $Dimensions::Materials{plexiglass}{thickness};
	my $nut_offset_w = ($bolt_slot_width - $nut_slot_width) / 2;
	my $nut_offset_h = ($nut_slot_height - $bolt_slot_height) / 2;

	return (
		['l', 0, $direction * $bolt_offset_h],
		['l', -$direction * ($nut_offset_w + $Dimensions::BitSize), 0],
		['l', 0, -$direction * $nut_offset_h],
		['l', -$direction * ($nut_slot_width - $Dimensions::BitSize), 0],
		['l', 0, $direction * $nut_offset_h],
		['l', -$direction * $nut_offset_w, 0],
		['l', 0, $direction * ($bolt_slot_height - $Dimensions::BitSize)],
		['l', $direction * $nut_offset_w, 0],
		['l', 0, $direction * $nut_offset_h],
		['l', $direction * ($nut_slot_width - $Dimensions::BitSize), 0],
		['l', 0, -$direction * $nut_offset_h],
		['l', $direction * ($nut_offset_w + $Dimensions::BitSize), 0],
		['l', 0, $direction * $bolt_offset_h],
	);
}

sub DovetailOut {
	my ($args) = @_;

	my @path;
	push(@path, ['M', $Dimensions::Materials{plexiglass}{thickness}, 0]);
	push(@path, ['l', $args->{w}, 0]);

	my $tab_size = $args->{h} / (2 * $args->{count} + 1);
	for (my $i = 0; $i < $args->{count}; $i++) {
		push(@path, BoltSlot($tab_size, 1));
		push(@path, ['l', 0, $Dimensions::Tolerance]);
		push(@path, ['l', $Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@path, ['l', 0, $tab_size - 2 * $Dimensions::Tolerance]);
		push(@path, ['l', -$Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@path, ['l', 0, $Dimensions::Tolerance]);
	}
	push(@path, BoltSlot($tab_size, 1));
	push(@path, ['l', -$args->{w}, 0]);
	for (my $i = 0; $i < $args->{count}; $i++) {
		push(@path, BoltSlot($tab_size, -1));
		push(@path, ['l', 0, -$Dimensions::Tolerance]);
		push(@path, ['l', -$Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@path, ['l', 0, -$tab_size + 2 * $Dimensions::Tolerance]);
		push(@path, ['l', $Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@path, ['l', 0, -$Dimensions::Tolerance]);
	}
	push(@path, BoltSlot($tab_size, -1));
	push(@path, ['Z']);

	my @new_path;
	push(@new_path, ['M', $Dimensions::Materials{plexiglass}{thickness} - $Dimensions::BitSize / 2, - $Dimensions::BitSize / 2]);
	push(@new_path, ['l', $args->{w} + $Dimensions::BitSize, 0]);
	push(@new_path, ['l', 0, $Dimensions::BitSize]); # Because all of the rest of the slots will be offset this much
	for (my $i = 0; $i < $args->{count}; $i++) {
		push(@new_path, BoltSlot2($tab_size, 1));
		push(@new_path, ['l', 0, $Dimensions::Tolerance]);
		push(@new_path, ['l', $Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@new_path, ['l', 0, $tab_size - 2 * $Dimensions::Tolerance + $Dimensions::BitSize]);
		push(@new_path, ['l', -$Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@new_path, ['l', 0, $Dimensions::Tolerance]);
	}
	push(@new_path, BoltSlot2($tab_size, 1));
	push(@new_path, ['l', 0, $Dimensions::BitSize]);
	push(@new_path, ['l', -$args->{w} - $Dimensions::BitSize, 0]);
	push(@new_path, ['l', 0, -$Dimensions::BitSize]); # Because all of the rest of the slots will be offset this much
	for (my $i = 0; $i < $args->{count}; $i++) {
		push(@new_path, BoltSlot2($tab_size, -1));
		push(@new_path, ['l', 0, -$Dimensions::Tolerance]);
		push(@new_path, ['l', -$Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@new_path, ['l', 0, -$tab_size + 2 * $Dimensions::Tolerance - $Dimensions::BitSize]);
		push(@new_path, ['l', $Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@new_path, ['l', 0, -$Dimensions::Tolerance]);
	}
	push(@new_path, BoltSlot2($tab_size, -1));
	push(@new_path, ['Z']);

	return {
		w => $args->{w} + 2 * $Dimensions::Materials{plexiglass}{thickness},
		h => $args->{h},
		svg => join("\n", (
			Path(\@path, $args),
			Path(\@new_path, $args),
			map {
				Circle(
					$Dimensions::Materials{bolts}{r},
					@$_,
					{ class => 'cut' },
				);
			} (
				[$Dimensions::Materials{plexiglass}{thickness} / 2, 3 * $tab_size / 2],
				[$Dimensions::Materials{plexiglass}{thickness} / 2, 7 * $tab_size / 2],
				[$args->{w} + 3 * $Dimensions::Materials{plexiglass}{thickness} / 2, 3 * $tab_size / 2],
				[$args->{w} + 3 * $Dimensions::Materials{plexiglass}{thickness} / 2, 7 * $tab_size / 2],
			),
		)),
	};
}

sub DovetailIn {
	my ($args) = @_;

	my @path;
	push(@path, ['M', 0, 0]);
	push(@path, ['l', $args->{w}, 0]);

	my $tab_size = $args->{h} / (2 * $args->{count} + 1);
	for (my $i = 0; $i < $args->{count}; $i++) {
		push(@path, ['l', 0, $tab_size]);
		push(@path, ['l', -$Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@path, BoltSlot($tab_size, 1));
		push(@path, ['l', $Dimensions::Materials{plexiglass}{thickness}, 0]);
	}
	push(@path, ['l', 0, $tab_size]);
	push(@path, ['l', -$args->{w}, 0]);
	for (my $i = 0; $i < $args->{count}; $i++) {
		push(@path, ['l', 0, -$tab_size]);
		push(@path, ['l', $Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@path, BoltSlot($tab_size, -1));
		push(@path, ['l', -$Dimensions::Materials{plexiglass}{thickness}, 0]);
	}
	push(@path, ['Z']);

	my @new_path;
	push(@new_path, ['M', -$Dimensions::BitSize / 2, -$Dimensions::BitSize / 2]);
	push(@new_path, ['l', $args->{w} + $Dimensions::BitSize, 0]);
	for (my $i = 0; $i < $args->{count}; $i++) {
		push(@new_path, ['l', 0, $tab_size + $Dimensions::BitSize]);
		push(@new_path, ['l', -$Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@new_path, BoltSlot2($tab_size, 1));
		push(@new_path, ['l', $Dimensions::Materials{plexiglass}{thickness}, 0]);
	}
	push(@new_path, ['l', 0, $tab_size + $Dimensions::BitSize]);
	push(@new_path, ['l', -$args->{w} - $Dimensions::BitSize, 0]);
	for (my $i = 0; $i < $args->{count}; $i++) {
		push(@new_path, ['l', 0, -$tab_size - $Dimensions::BitSize]);
		push(@new_path, ['l', $Dimensions::Materials{plexiglass}{thickness}, 0]);
		push(@new_path, BoltSlot2($tab_size, -1));
		push(@new_path, ['l', -$Dimensions::Materials{plexiglass}{thickness}, 0]);
	}
	push(@new_path, ['Z']);

	return {
		w => $args->{w},
		h => $args->{h},
		svg => join("\n", (
			Path(\@path, $args),
			Path(\@new_path, $args),
			map {
				Circle(
					$Dimensions::Materials{bolts}{r},
					@$_,
					{ class => 'cut' },
				);
			} (
				[$Dimensions::Materials{plexiglass}{thickness} / 2, 1 * $tab_size / 2],
				[$Dimensions::Materials{plexiglass}{thickness} / 2, 5 * $tab_size / 2],
				[$Dimensions::Materials{plexiglass}{thickness} / 2, 9 * $tab_size / 2],
				[$args->{w} - $Dimensions::Materials{plexiglass}{thickness} / 2, 1 * $tab_size / 2],
				[$args->{w} - $Dimensions::Materials{plexiglass}{thickness} / 2, 5 * $tab_size / 2],
				[$args->{w} - $Dimensions::Materials{plexiglass}{thickness} / 2, 9 * $tab_size / 2],
			),
		)),
	};
}

sub Slots {
	my ($args) = @_;

	my $tab_width = $args->{w} / $args->{count};
	my $slot = Rect($tab_width + $Dimensions::Tolerance, $Dimensions::Materials{plexiglass}{thickness} + $Dimensions::Tolerance, $args);

	return {
		w => $args->{w},
		h => $Dimensions::Materials{plexiglass}{thickness} + $Dimensions::Tolerance,
		svg => join("\n", map {
			sprintf(
				q{<g transform="translate(%f, 0)">%s</g>},
				(2 * $_ + 1) * $tab_width - $Dimensions::Tolerance / 2, $slot,
			);
		} (0..($args->{count}-1)/2 - 1)),
	};
}

sub Port {
	my ($args) = @_;

	my %port = (%$args);
	$port{svg} = join("\n", map {
		my $hole = $_;
		$hole->{r}
			? Circle(@$hole{qw(r cx cy)}, { class => 'cut' })
			: sprintf(
				q{<g transform="translate(%f, %f)"><g transform="translate(%f, %f)">%s</g></g>},
				@$hole{qw(x y)},
				-$hole->{w} / 2,
				-$hole->{h} / 2,
				Rect(@$hole{qw(w h)}, { class => 'cut' }),
			);
	} @{ $port{holes} || [] });

	# Easel no like text
	if (0 && $args->{label}) {
		$port{h} += $Dimensions::FontSize / 2;
		$port{svg} = sprintf(
			q{%s<g transform="translate(0, %f)">%s</g>},
			Text($args->{label}, {
				position => {
					x => $port{w} / 2,
				},
				class => 'etch',
			}),
			$Dimensions::FontSize / 2,
			$port{svg},
		);
	}

	return \%port;
}

sub RegularHexagon {
	my ($l, $args) = @_;

	my @path = (
		['M', $l * cos(pi/6), 0],
		['l', $l * cos(pi/6), $l * sin(pi/6)],
		['l', 0, $l],
		['l', -$l * cos(pi/6), $l * sin(pi/6)],
		['l', -$l * cos(pi/6), -$l * sin(pi/6)],
		['l', 0, -$l],
		['Z'],
	);

	return {
		w => 2 * $l * cos(pi/6),
		h => 2 * $l * sin(pi/6) + $l,
		svg => Path(\@path, $args),
	};
}

1;
