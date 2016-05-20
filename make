#!/bin/bash

sides=(bottom top front back left right)
for side in ${sides[@]}
do
	perl draw_layout_img.pl $side > $side.svg
done
