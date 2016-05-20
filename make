#!/bin/bash

perl draw_layout.pl all > DaveBox.html
sides=(bottom top front back left right)
for side in ${sides[@]}
do
	perl draw_layout.pl $side > $side.html
	perl draw_layout_img.pl $side > $side.svg
done