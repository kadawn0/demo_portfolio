import time
import numpy as np
import matplotlib.pyplot as plot
from random import randint
from sklearn.metrics.pairwise import euclidean_distances, cosine_similarity, manhattan_distances
from sklearn.metrics.pairwise import linear_kernel, polynomial_kernel, sigmoid_kernel
from utils import do_pca, get_impostors_distance, get_d_prime


start_time = time.time()
results = {}
for i in range(8, 9):
    for j in range(8, 9):
        print(f'vdiv={i} hdiv={j}')

        # Retrieve saved file into an array
        features_A = np.load(f'data/lbp/features_A_lbp_{i}x{j}.npy')
        features_B = np.load(f'data/lbp/features_B_lbp_{i}x{j}.npy')

        # Normalize features
        features_A = features_A/np.linalg.norm(features_A)
        features_B = features_B/np.linalg.norm(features_B)

        # Do PCA
        # features_A, features_B = do_pca(features_A, features_B, 10)

        # Get metrics
        euclidean_matrix = euclidean_distances(features_A, features_B)
        cosine_matrix = cosine_similarity(features_A, features_B)
        manhattan_matrix = manhattan_distances(features_A, features_B)
        linear_matrix = linear_kernel(features_A, features_B)
        polynomial_matrix = polynomial_kernel(features_A, features_B)
        sigmoid_matrix = sigmoid_kernel(features_A, features_B)

        # Get genuines distances
        genuines_euclidean_distance = euclidean_matrix.diagonal()
        genuines_cosine_distance = cosine_matrix.diagonal()
        genuines_manhattan_distance = manhattan_matrix.diagonal()
        genuines_linear_distance = linear_matrix.diagonal()
        genuines_polynomial_distance = polynomial_matrix.diagonal()
        genuines_sigmoid_distance = sigmoid_matrix.diagonal()

        # Get impostors distances
        impostors_euclidean_distance = get_impostors_distance(euclidean_matrix)
        impostors_cosine_distance = get_impostors_distance(cosine_matrix)
        impostors_manhattan_distance = get_impostors_distance(manhattan_matrix)
        impostors_linear_distance = get_impostors_distance(linear_matrix)
        impostors_polynomial_distance = get_impostors_distance(
            polynomial_matrix)
        impostors_sigmoid_distance = get_impostors_distance(sigmoid_matrix)

        # Calculate d'
        euclidean_d_prime = get_d_prime(
            genuines_euclidean_distance, impostors_euclidean_distance)
        cosine_d_prime = get_d_prime(
            genuines_cosine_distance, impostors_cosine_distance)
        manhattan_d_prime = get_d_prime(
            genuines_manhattan_distance, impostors_manhattan_distance)
        linear_d_prime = get_d_prime(
            genuines_linear_distance, impostors_linear_distance)
        polynomial_d_prime = get_d_prime(
            genuines_polynomial_distance, impostors_polynomial_distance)
        sigmoid_d_prime = get_d_prime(
            genuines_sigmoid_distance, impostors_sigmoid_distance)

        # Save results
        results[(i, j)] = {'euclidean': euclidean_d_prime,
                           'cosine': cosine_d_prime,
                           'manhattan': manhattan_d_prime,
                           'linear': linear_d_prime,
                           'polynomial': polynomial_d_prime,
                           'sigmoid': sigmoid_d_prime}

# Get best result
best = 0
best_key = None
metric_ = None
for key in results:
    for metric in ['euclidean', 'cosine', 'manhattan', 'linear', 'polynomial', 'sigmoid']:
        print(f'{metric}: {results[key][metric]}')
        if results[key][metric] > best:
            best = results[key][metric]
            best_key = key
            metric_ = metric
print(
    f'Best result was {best} with vdiv={best_key[0]}, hdiv={best_key[1]} and {metric_} metric')

end_time = time.time()
print(f'Total time was {end_time - start_time}')
