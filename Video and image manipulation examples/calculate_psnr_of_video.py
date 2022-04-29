"""
Video Quality Metrics
Copyright (c) 2014 Alex Izvorski <aizvorski@gmail.com>
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""


import cv2
import numpy
import math
import os
from os.path import isfile, join


pathIn = os.path.abspath("monodepth2/assets/hail_frames/base")
pathIn2 = os.path.abspath("monodepth2/assets/siggraph17_prediction")


def psnr(img1, img2):
    mse = numpy.mean( (img1 - img2) ** 2 )
    if mse == 0:
        return 100
    PIXEL_MAX = 255.0
    return 20 * math.log10(PIXEL_MAX / math.sqrt(mse))



files = [f for f in os.listdir(pathIn) if isfile(join(pathIn, f))]
#for sorting the file names properly
# print(files)
files.sort(key = lambda x: int(x.split(".")[0].split("_")[0][5:]))

video_psnr = 0

for i in range(len(files)):
	filename=files[i]
	if int(filename.split(".")[0].split("_")[0][5:]) < 1601:
		#reading each files
		ground_truth = cv2.imread(pathIn + "/" + filename)
		img = cv2.imread(pathIn2 + "/" + filename.split(".")[0] + ".jpeg")

		video_psnr += psnr(img, ground_truth)

print(video_psnr/max(1,len(files)))
