import math
import numpy as np
import matplotlib.pyplot as plot
import metric_learn as ml
import cv2
import os
from sklearn.metrics.pairwise import euclidean_distances, cosine_similarity
from sklearn.decomposition import PCA
from sklearn.neural_network import MLPClassifier


# Return d'
def d_prime(u1, u2, s1, s2):
    return abs(u1 - u2) / math.sqrt((s1 ** 2 + s2 ** 2) / 2)


# Return FMR and FNMR
def get_FMR_and_FNMR(genuines_distance, impostors_distance):
    impostors_average = np.average(impostors_distance)
    impostors_std = np.std(impostors_distance)
    genuines_average = np.average(genuines_distance)
    genuines_std = np.std(genuines_distance)
    theta = 0.5 * abs((impostors_average + impostors_std) -
                      (genuines_average + genuines_std))
    FMR = 100 * abs(impostors_distance[0] - theta) / len(impostors_distance)
    FNMR = 100 * \
           abs(genuines_distance[len(genuines_distance) - 1] -
               theta) / len(genuines_distance)
    return FMR, FNMR


# Multiplication of matrix A and matrix B getting cosine metric
def mult_A_B_cosine_metric(matrix_A, matrix_B):
    return cosine_similarity(matrix_A, matrix_B), None


# Multiplication of matrix A and B getting euclidean metric
def mult_A_B_euclidean_metric(matrix_A, matrix_B):
    return euclidean_distances(matrix_A, matrix_B), None


def mahalanobis_distances(matrix_A, matrix_B):
    X = np.concatenate((matrix_A, matrix_B), axis=0)
    subjects = matrix_A.shape[0]
    y = np.fromfunction(lambda i: i, (subjects,), dtype=int)
    y = np.concatenate((y, y))
    mmc = ml.rca.RCA_Supervised(pca_comps=50)
    mmc = mmc.fit(X, y)

    X_L = mmc.transform(X)
    A, B = np.split(X_L, 2)
    return euclidean_distances(A, B), mmc


def nca_distances(matrix_A, matrix_B):
	X = np.concatenate((matrix_A, matrix_B), axis=0)
	subjects = matrix_A.shape[0]
	y = np.fromfunction(lambda i: i, (subjects,), dtype=int)
	y = np.concatenate((y, y))
	mmc = ml.nca.NCA(verbose=True)
	mmc = mmc.fit(X, y)
	X_L = mmc.transform(X)
	A, B = np.split(X_L, 2)
	return euclidean_distances(A, B), mmc


def lmnn_distances(matrix_A, matrix_B):
	X = np.concatenate((matrix_A, matrix_B), axis=0)
	subjects = matrix_A.shape[0]
	y = np.fromfunction(lambda i: i, (subjects, ), dtype=int)
	y = np.concatenate((y, y))
	mmc = ml.LMNN(k=1, verbose=True)
	mmc = mmc.fit(X, y)
	X_L = mmc.transform(X)
	A, B = np.split(X_L, 2)
	return euclidean_distances(A, B), mmc



def do_pca(features_A, features_B, n_components, op=0):
    sizeA = np.shape(features_A)
    sizeB = np.shape(features_B)
    print(sizeA, sizeB)
    dA = sizeA[0]
    dB = sizeB[0]
    dA = np.ones(dA)
    dB = np.ones(dB)
    for i in (0, len(dA) - 1):  # cada persona es su propia clase, y se asume que se han leído en orden
        dA[i] = i
    for j in (0, len(dB) - 1):
        dB[j] = j

    if op == 3: # eigenfaces solo con sklearn
        pca_A = PCA(n_components=n_components, whiten=True)
        features_A = pca_A.fit_transform(features_A)
        pca_B = PCA(n_components=n_components, whiten=True)
        features_B = pca_B.fit_transform(features_B)


    if op == 0:
        pca_A = PCA(n_components=n_components)
        features_A = pca_A.fit_transform(features_A)
        pca_B = PCA(n_components=n_components)
        features_B = pca_B.fit_transform(features_B)

    return features_A, features_B, pca_A, pca_B


def get_impostors_distance(matrix):
    lenght = len(matrix)
    upper_diagonal = matrix[np.triu_indices(lenght, 1)]
    below_diagonal = matrix[np.tril_indices(lenght, 1)]
    impostors_distance = np.concatenate([upper_diagonal, below_diagonal])
    return impostors_distance


def get_d_prime(genuines_distance, impostors_distance):
    genuines_average = np.average(genuines_distance)
    genuines_std = np.std(genuines_distance)
    impostors_average = np.average(impostors_distance)
    impostors_std = np.std(impostors_distance)
    return d_prime(genuines_average, impostors_average, genuines_std, impostors_std)


def saveplot(genuines_distance, impostors_distance, dir_plot, key):
	# Draw histogram with the data
	plot.hist(genuines_distance, color='red', weights=np.zeros_like(
	    genuines_distance) + 1. / genuines_distance.size, alpha=0.5,
		label="Genuines distribution")
	plot.hist(impostors_distance, color='blue', weights=np.zeros_like(
	    impostors_distance) + 1. / impostors_distance.size, alpha=0.5,
		label="Impostors distribution")
	plot.xlabel('Distance')
	plot.ylabel('Relative Frecuency')
	plot.legend()

	if not os.path.exists(dir_plot):
		os.makedirs(dir_plot)
	plot.savefig(f"{dir_plot}/Distributions {key}")
	plot.close()






if __name__ == '__main__':
    vdiv = 1
    hdiv = 1

    """
    # Retrieve saved file into an array
    features_A = np.load(f'data/lbp/features_A_lbp_{vdiv}x{hdiv}.npy')
    features_B = np.load(f'data/lbp/features_B_lbp_{vdiv}x{hdiv}.npy')

    # Normalize features
    features_A = features_A / np.linalg.norm(features_A)
    features_B = features_B / np.linalg.norm(features_B)

    features_A, features_B = do_pca(features_A, features_B, n_components=50)


    X_L = train_mahalanobis(features_A, features_B)
    A, B = np.split(X_L, 2)
    dist = euclidean_distances(features_A, features_B)
    Ldist = euclidean_distances(A, B)
    print(f"Dist: {dist}; Ldist: {Ldist}")
    """
    a = {{'a': 2, 'b': 3}: 4}