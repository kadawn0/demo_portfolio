import matplotlib.pyplot as plt

import numpy as np
import time
from skimage.restoration import (denoise_tv_chambolle, denoise_bilateral,
                                 denoise_wavelet, estimate_sigma)
from skimage import data, img_as_float
from skimage.util import random_noise
import skimage.io
from skimage.restoration import denoise_nl_means
from skimage.metrics import peak_signal_noise_ratio
from sklearn.metrics import mean_squared_error

# read image
angio1 = img_as_float(skimage.io.imread(fname="angio1.png"))
angio2 = img_as_float(skimage.io.imread(fname="angio2.png"))

perf1 = img_as_float(skimage.io.imread(fname="perf1.png"))
perf2 = img_as_float(skimage.io.imread(fname="perf2.png"))

angio = img_as_float(skimage.io.imread(fname="angio.png"))
perf = img_as_float(skimage.io.imread(fname="perfusion.png"))

sigma_est_1 = np.mean(estimate_sigma(angio1, multichannel=True))
sigma_est_2 = np.mean(estimate_sigma(angio2, multichannel=True))

patch_kw = dict(patch_size=5,      # 5x5 patches
                patch_distance=6,  # 13x13 search area
                multichannel=True)

tim1 = time.time()
angio1_wave = denoise_nl_means(angio1, h=0.6 * sigma_est_1, sigma=sigma_est_1,
                                 fast_mode=True, **patch_kw)
print("Tiempo angio1: " + str(time.time() - tim1))
tim1 = time.time()
angio2_wave = denoise_nl_means(angio2, h=0.6 * sigma_est_2, sigma=sigma_est_2,
                                 fast_mode=True, **patch_kw)
print("Tiempo angio2: " + str(time.time() - tim1))
tim1 = time.time()
perf1_wave = denoise_nl_means(perf1, h=0.6 * sigma_est_1, sigma=sigma_est_1,
                                 fast_mode=True, **patch_kw)
print("Tiempo perf1: " + str(time.time() - tim1))
tim1 = time.time()
perf2_wave = denoise_nl_means(perf2, h=0.6 * sigma_est_2, sigma=sigma_est_2,
                                 fast_mode=True, **patch_kw)
print("Tiempo perf2: " + str(time.time() - tim1))



fig, ax = plt.subplots(nrows=2, ncols=4, figsize=(8, 5),
                       sharex=True, sharey=True)

plt.gray()
                       
ax[0, 0].imshow(angio1)
ax[0, 0].axis('off')
ax[0, 0].set_title('angio1')

ax[0, 1].imshow(angio1_wave)
ax[0, 1].axis('off')
ax[0, 1].set_title('angio1_nonlocalmeans')

ax[0, 2].imshow(angio2)
ax[0, 2].axis('off')
ax[0, 2].set_title('angio2')

ax[0, 3].imshow(angio2_wave)
ax[0, 3].axis('off')
ax[0, 3].set_title('angio2_nonlocalmeans')

ax[1, 1].imshow(perf1_wave)
ax[1, 1].axis('off')
ax[1, 1].set_title('perf1_nonlocalmeans')

ax[1, 2].imshow(perf1)
ax[1, 2].axis('off')
ax[1, 2].set_title('perf1')

ax[1, 3].imshow(perf2_wave)
ax[1, 3].axis('off')
ax[1, 3].set_title('perf2_nonlocalmeans')

ax[1, 0].imshow(perf2)
ax[1, 0].axis('off')
ax[1, 0].set_title('perf2')

fig.tight_layout()

plt.show()

metric_angio1 = peak_signal_noise_ratio(angio, angio1_wave)
metric_angio2 = peak_signal_noise_ratio(angio, angio2_wave)
metric_perf1 = peak_signal_noise_ratio(perf, perf1_wave)
metric_perf2 = peak_signal_noise_ratio(perf, perf2_wave)

print("PSNR angio1 reconstruida: " + str(metric_angio1) )
print("PSNR angio2 reconstruida: " + str(metric_angio2) )
print("PSNR perf1 reconstruida: " + str(metric_perf1) )
print("PSNR perf2 reconstruida: " + str(metric_perf2) )


mse_angio1 = mean_squared_error(angio, angio1_wave)
mse_angio2 = mean_squared_error(angio, angio2_wave)
mse_perf1 = mean_squared_error(perf, perf1_wave)
mse_perf2 = mean_squared_error(perf, perf2_wave)

print("MSE angio1 reconstruida: " + str(mse_angio1) )
print("MSE angio2 reconstruida: " + str(mse_angio2) )
print("MSE perf1 reconstruida: " + str(mse_perf1) )
print("MSE perf2 reconstruida: " + str(mse_perf2) )
