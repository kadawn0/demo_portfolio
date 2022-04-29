import matplotlib.pyplot as plt

import numpy
from skimage.restoration import (denoise_tv_chambolle, denoise_bilateral,
                                 denoise_wavelet, estimate_sigma)
from skimage import data, img_as_float
from skimage.util import random_noise
import skimage.io

# read image
angio1 = skimage.io.imread(fname="angio1.png")
angio2 = skimage.io.imread(fname="angio2.png")

perf1 = skimage.io.imread(fname="perf1.png")
perf2 = skimage.io.imread(fname="perf2.png")

angio1_wave = denoise_wavelet(angio1, rescale_sigma=True)
angio2_wave = denoise_wavelet(angio2, rescale_sigma=True)

perf1_wave = denoise_wavelet(perf1, rescale_sigma=True)
perf2_wave = denoise_wavelet(perf2, rescale_sigma=True)

fig, ax = plt.subplots(nrows=2, ncols=4, figsize=(8, 5),
                       sharex=True, sharey=True)

plt.gray()
                       
ax[0, 0].imshow(angio1)
ax[0, 0].axis('off')
ax[0, 0].set_title('angio1')

ax[0, 1].imshow(angio1_wave)
ax[0, 1].axis('off')
ax[0, 1].set_title('angio1_wave')

ax[0, 2].imshow(angio2)
ax[0, 2].axis('off')
ax[0, 2].set_title('angio2')

ax[0, 3].imshow(angio2_wave)
ax[0, 3].axis('off')
ax[0, 3].set_title('angio2_wave')

ax[1, 1].imshow(perf1)
ax[1, 1].axis('off')
ax[1, 1].set_title('perf1')

ax[1, 2].imshow(perf1_wave)
ax[1, 2].axis('off')
ax[1, 2].set_title('perf1_wave')

ax[1, 3].imshow(perf2)
ax[1, 3].axis('off')
ax[1, 3].set_title('perf2')

ax[1, 0].imshow(perf2_wave)
ax[1, 0].axis('off')
ax[1, 0].set_title('perf2_wave')

fig.tight_layout()

plt.show()
