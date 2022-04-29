import numpy as np
from glob import glob
from PIL import Image
from pybalu.feature_extraction import lbp_features
import os
from skimage.feature import hog
from skimage.feature import daisy
from sklearn import preprocessing

# notch_filter_opc = ["/notch_filter", ""]
notch_filter_opc = ["/testing_nf"]

for opc in notch_filter_opc:
    db_training = f'i1213s1720/training'
    db_testing = 'i1213s1720/testing/notch_filter'

    dir = f"data/lbp{opc}"
    if not os.path.exists(dir):
        os.makedirs(dir)

    for i in range(8, 9):
        for j in range(8, 9):

            features_A = []
            features_B = []

            # Get LBP of each training image
            for path in os.listdir(db_testing):
                print(path)
                if not path.endswith(".png") and not path.endswith(".jpg"):
                    continue


                # Open image and convert it to gray scale
                image = Image.open(os.path.join(db_testing, path))
                gray_image = np.array(image.convert('L'))

                # Get LBP image
                features = lbp_features(gray_image, vdiv=i, hdiv=j)
                fd, hog_image = hog(gray_image, orientations=8, pixels_per_cell=(16, 16),
                                    cells_per_block=(1, 1), visualize=True, multichannel=True)
                descs, descs_img = daisy(gray_image, step=180, radius=58, rings=2, histograms=6,
                                         orientations=8, visualize=True)
                lbp_norm = preprocessing.normalize(features, norm='l2')
                hog_norm = preprocessing.normalize(hog_image, norm='l2')
                descs_norm = preprocessing.normalize(descs, norm='l2')
                features = np.concatenate((lbp_norm, hog_norm, descs_norm), axis=0)

                # Get image class
                filename = path.split('.')[0].split('/')[-1]
                image_class = filename[-1]
                image_id = filename[:-1]

                # Add features and image class to the correspondent sets
                if image_class == "A":
                    features_A.append((features, int(image_id)))
                elif image_class == "B":
                    features_B.append((features, int(image_id)))

            # Order the features sets
            features_A.sort(key=lambda tuple: tuple[1])
            features_B.sort(key=lambda tuple: tuple[1])

            # Eliminate id from the features set
            features_A = [features for (features, image_id) in features_A]
            features_B = [features for (features, image_id) in features_B]

            # Save files of features for avoiding recompute
            np.save(f'data/lbp{opc}/features_A_lbp_{i}x{j}', np.array(features_A))
            np.save(f'data/lbp{opc}/features_B_lbp_{i}x{j}', np.array(features_B))
