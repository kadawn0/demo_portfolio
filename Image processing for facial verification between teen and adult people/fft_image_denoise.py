import os
import time
import numpy as np
from scipy import ndimage as ndi
# from scipy import fftpack
from glob import glob
import cv2
# from matplotlib import pyplot as plt
# import scipy.stats as st
from PIL import Image
# import math
db_training = 'i1213s1720/testing/'

if not os.path.exists(f'{db_training}notch_filter'):
    os.mkdir(f'{db_training}notch_filter')

##########################################################################
# Aplica filtro notch a todas las imágenes "A", que son las de carnet.   #
# No logra borrar las lineas de todas las fotos, pero lo hace bien con   #
# un buen número de ellas y las que no, por lo menos las atenua.         #
# Las imágenes quedan guardadas en i1213s1720/training/notch_filter.     #
# El script se demora 1 minutos en procesar todas las caras de training  #
##########################################################################

OPTION = 2 # 1 fast, 2 slow and better
sigma = 1
prescale_a = 5
start_time = time.time()
for path in glob(f'{db_training}*.jpg'):

    filename = path.split('.')[0].split('/')[-1]
    image_class = filename[-1]

    im = cv2.imread(path, 0) # Image.open(path).convert("L")

    # cv2.imshow("dsvfvdfdfd", im)
    # cv2.waitKey(0)

    meanie = np.mean(im)/255

    N = 7*meanie
    N_prev = N*10

    kernel_prev = np.array([[-1 / N_prev, -1 / N_prev, -1 / N_prev],
                       [-1 / N_prev, (N_prev - 1)/N_prev, -1 / N_prev],
                       [-1 / N_prev, -1 / N_prev, -1 / N_prev]])

    kernel = np.array([[0, -1/N, 0],
                   [-1/N,int(N/2),-1/N],
                   [0, -1/N, 0]])

    # kernel = np.array([[-3, 0, 3],
    #                [-10,0,10],
    #                [-3, 0, 3]])
    im = cv2.filter2D(im, -1, kernel_prev)
    asdd = cv2.filter2D(im, -1, kernel)

    if (np.mean(asdd) >= 50):
        im = asdd

    if (image_class == "A"):
        denoiser = 9
    else:
        denoiser = 7

    # cv2.imshow("dsvfvdfdfd", im)
    # cv2.waitKey(0)
    if (OPTION == 1):
        img_back = cv2.fastNlMeansDenoising(im, None, denoiser, 20)
        blur = cv2.GaussianBlur(img_back, (5, 5), 0)
        img_back = cv2.addWeighted(blur, 1.5, img_back, -0.5, 0)
        if (image_class == "A"):
            img_back -= int(np.mean(img_back) * 0.1)
        else:
            img_back += int(np.mean(img_back) * 0.3)
        alpha = 1.1  # Simple contrast control
        beta = 0  # Simple brightness control
        img_back = cv2.convertScaleAbs(img_back, alpha=alpha, beta=beta)
        img_back = Image.fromarray(img_back)
        if img_back.mode != 'RGB':
            img_back = img_back.convert('RGB')
        print(f'{db_training}notch_filter/' + filename[len(filename) - 6:len(filename) - 1] + image_class + '.png')
        img_back.save(
            f'{db_training}notch_filter/' + filename[len(filename) - 6:len(filename) - 1] + image_class + '.png')
    else:
        if image_class in ["A", "B"]:
            dft = cv2.dft(np.float32(im), flags=cv2.DFT_COMPLEX_OUTPUT)
            dft_shift = np.fft.fftshift(dft)

            rows, cols = im.shape
            crow, ccol = int(rows / 2), int(cols / 2)
            img_back = np.zeros((rows, cols))

            im = cv2.fastNlMeansDenoising(im, None, denoiser, 20)

            n = 20
            blurred = cv2.blur(im, (n, n))

            j = 0
            keep_fraction = 0
            sigma = 1
            enable = 1
            prescale_a = 5
            noise_ant = 0
            for i in range(0, 8):
                # prescale_a += i
                if (enable == 1):
                    if (i % 2 == 0):
                        j += 1
                    sigma += 1
                    prescale_b = prescale_a*sigma
                    keep_fraction = 0.05*sigma
                    masketh = np.zeros((rows, cols))
                    masketh[crow - sigma*prescale_b:crow + sigma*prescale_b, ccol - sigma*prescale_b:ccol + sigma*prescale_b] = 1
                    asd = int(30*(1- keep_fraction))
                    filter_up = asd*2
                    mask = 255*ndi.filters.gaussian_filter(masketh, sigma=sigma*(prescale_b), mode='reflect')# gkern(cols, sigma*2)
                    mask = mask.astype(np.float64)
                    # dfdf, mask = cv2.threshold(mask, int(np.mean(mask)*0.2*(sigma/2)), 255, cv2.THRESH_BINARY)
                    masketh = np.zeros((rows, cols))
                    masketh[crow - sigma * prescale_a:crow + sigma * prescale_a, ccol - sigma * prescale_a:ccol + sigma * prescale_a] = 1
                    mask_smol = 255*ndi.filters.gaussian_filter(masketh, sigma=sigma, mode='reflect')# gkern(cols, sigma)
                    mask_smol = mask_smol.astype(np.float64)

                    mask = np.stack(np.array([mask, mask]), axis=2)
                    mask_smol = np.stack(np.array([mask_smol, mask_smol]), axis=2)
                    # print(mask.shape)
                    masked = mask - mask_smol
                    masked = masked

                    masked = masked.astype(np.uint8)
                    dft_shift = dft_shift.astype(np.float32)

                    fshift_first = cv2.bitwise_and(dft_shift[:,:,0], dft_shift[:,:,0],mask = masked[:,:,0])
                    fshift_alt = cv2.bitwise_and(dft_shift[:,:,1], dft_shift[:,:,1],mask = masked[:,:,1])#dft_shift*masked #dft_shift
                    fshift = np.stack(np.array([fshift_first, fshift_alt]), axis=2)

                    f_ishift = np.fft.ifftshift(fshift)
                    img_back = cv2.idft(f_ishift)
                    img_back = cv2.magnitude(img_back[:, :, 0], img_back[:, :, 1])

                    im = im.astype(np.float64)
                    im *= 255.0 / im.max()
                    img_back *= 255.0/img_back.max()
                    indicator = int(np.mean(im)/np.mean(img_back))
                    noise = (img_back / im)

                    print(prescale_a)
                    print(prescale_b)
                    print(sigma)
                    print(keep_fraction)

                    if (np.max(masked) >= 0):
                        if (indicator > 1):
                            noise[np.where(noise < np.mean(noise))] = 0
                            noise *= 100
                            noise = cv2.normalize(noise, None, alpha=0, beta=1, norm_type=cv2.NORM_MINMAX, dtype=cv2.CV_32F)
                            noise = noise.astype(np.uint8)
                            im_aux = cv2.bitwise_and(im, im, mask=noise)

                            im = im.astype(np.float32)
                            im_aux = im_aux.astype(np.float32)
                            final = cv2.subtract(im, im_aux)
                            final = cv2.normalize(final, None, alpha=0, beta=255, norm_type=cv2.NORM_MINMAX, dtype=cv2.CV_32F)
                            blurred = cv2.normalize(blurred, None, alpha=0, beta=255, norm_type=cv2.NORM_MINMAX,
                                                  dtype=cv2.CV_32F)
                            img_back = (final + cv2.bitwise_and(blurred, blurred, mask=noise)) * 0.8 + im * 0.2
                            img_back = cv2.fastNlMeansDenoising(img_back.astype(np.uint8), None, denoiser, 20)
                            blur = cv2.GaussianBlur(img_back, (5, 5), 0)
                            img_back = cv2.addWeighted(blur, 1.5, img_back, -0.5, 0)
                            if (image_class == "A"):
                                img_back -= int(np.mean(img_back) * 0.1)
                            else:
                                img_back += int(np.mean(img_back) * 0.1)
                            alpha = 1.1  # Simple contrast control
                            beta = 0  # Simple brightness control
                            img_back = cv2.convertScaleAbs(img_back, alpha=alpha, beta=beta)
                            # img_back = img_back_a.astype(np.uint8)
                            img_back = Image.fromarray(img_back)
                            if img_back.mode != 'RGB':
                                img_back = img_back.convert('RGB')
                            print(f'{db_training}notch_filter/' + filename[len(filename) - 6:len(filename) - 1] + image_class + '.png')
                            img_back.save(f'{db_training}notch_filter/' + filename[len(filename) - 6:len(filename) - 1] + image_class + '.png')
                            if (np.mean(noise) <= noise_ant):
                                enable = 0
                            noise_ant = np.mean(noise)
                    noise[np.where(noise < np.mean(noise))] = 0
                    noise *= 100
                    noise = noise.astype(np.uint8)
                    im_aux = cv2.bitwise_and(im, im, mask=noise)

                    im = im.astype(np.float32)
                    im_aux = im_aux.astype(np.float32)
                    final = cv2.subtract(im, im_aux)
                    final = cv2.normalize(final, None, alpha=0, beta=255, norm_type=cv2.NORM_MINMAX, dtype=cv2.CV_32F)
                    blurred = cv2.normalize(blurred, None, alpha=0, beta=255, norm_type=cv2.NORM_MINMAX,
                                            dtype=cv2.CV_32F)
                    img_back = (final + cv2.bitwise_and(blurred, blurred, mask=noise)) * 0.8 + im * 0.2
                    img_back = cv2.fastNlMeansDenoising(img_back.astype(np.uint8), None, denoiser, 20)
                    blur = cv2.GaussianBlur(img_back, (5, 5), 0)
                    img_back = cv2.addWeighted(blur, 1.5, img_back, -0.5, 0)
                    if (image_class == "A"):
                        img_back -= int(np.mean(img_back)*0.1)
                    else:
                        img_back += int(np.mean(img_back) * 0.1)
                    alpha = 1.1  # Simple contrast control
                    beta = 0  # Simple brightness control
                    img_back = cv2.convertScaleAbs(img_back, alpha=alpha, beta=beta)
                    img_back = Image.fromarray(img_back)
                    if img_back.mode != 'RGB':
                        img_back = img_back.convert('RGB')
                    print(f'{db_training}notch_filter/' + filename[len(filename) - 6:len(filename) - 1]  + image_class + '.png')
                    img_back.save(f'{db_training}notch_filter/' + filename[len(filename) - 6:len(filename) - 1] + image_class + '.png')


end_time = time.time()
print(f'Total time was {end_time - start_time}')
