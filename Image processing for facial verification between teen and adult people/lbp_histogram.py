import json
import numpy as np
import matplotlib.pyplot as plot
import os
from random import randint
from utils import *
from sklearn.decomposition import PCA
from sklearn.metrics.pairwise import sigmoid_kernel
from sklearn.metrics.pairwise import euclidean_distances, cosine_similarity, manhattan_distances
from sklearn.metrics.pairwise import linear_kernel, polynomial_kernel, sigmoid_kernel
from time import time
from itertools import product
from tabulate import tabulate


def metric_pipeline(filepath_A, filepath_B, key, 
	metric=cosine_similarity, op=0, n=200,
	mmc=None, pcas=None):

	print(f"Calculating pipeline over {key}")
	start_time = time()

	vdiv = 8
	hdiv = 8

	# Retrieve saved file into an array
	features_A = np.load(filepath_A)
	features_B = np.load(filepath_B)

	# Normalize features
	features_A = features_A/np.linalg.norm(features_A)
	features_B = features_B/np.linalg.norm(features_B)

	# Do PCA
	if not pcas:
		features_A, features_B, pca_A, pca_B = do_pca(features_A, 
			features_B, n, op)
	else:
		pca_A, pca_B = pcas
		features_A = pca_A.transform(features_A)
		features_B = pca_B.transform(features_B)

	# Get metric
	if not mmc:
		matrix, mmc = metric(features_A, features_B)
	else:
		X = np.concatenate((features_A, features_B), axis=0)
		X_L = mmc.transform(X)
		A, B = np.split(X_L, 2)
		matrix = euclidean_distances(A, B)

	# Get genuines distances
	genuines_distance = matrix.diagonal()

	# Get impostors distances
	impostors_distance = get_impostors_distance(matrix)

	# Calculate d'
	d_prime = get_d_prime(genuines_distance, impostors_distance)
	print(f"Valor d prime: {d_prime}")

	# Get average and standard desviation
	FMR, FNMR = get_FMR_and_FNMR(genuines_distance, impostors_distance)
	print(f"Valor FMR: {FMR}")
	print(f"Valor FNMR: {FNMR}")
	# min y max en largo para valores extremos, no los verdaderos mínimo y máximo

	# Draw histogram with the data

	dir_plot = 'plots/lbp'
	saveplot(genuines_distance, impostors_distance, dir_plot, key)

	end_time = time()
	total_time = end_time - start_time

	values = {'d_prime': d_prime, 'FMR': FMR, 'FNMR': FNMR, 
			'time': total_time}

	return values, mmc, (pca_A, pca_B) 

	


def main():
	results = {}
	if os.path.exists('results/data_array.json'):
		with open('results/data_array.json', 'r') as infile:
			results = json.load(infile)
	vdiv = 8
	hdiv = 8
	preproc = ""
	preproc_dir = f"{preproc}" if preproc != "" else ""

	def _in_results(metric, opc, *args, **kw):
		metric_name = metric.__name__
		with_pca = "without pca" if opc == -1 else f"with pca {opc}"
		n_components = f", {kw['n_components']}" if kw and kw['n_components'] != 200 else ""
		preproc = f", {kw['preproc']}"
		key = f"{metric_name}, {with_pca}{n_components}{preproc}"
		key += ", v2"
		return key

	def _get_statistics(values):
		stats = {}
		stats['mean_time'] = np.mean([i['time'] for i in values])
		stats['mean_d_prime'] = np.mean([i['d_prime'] for i in values])
		stats['std_d_prime'] = np.std([i['d_prime'] for i in values])
		stats['n_experiments'] = len(values)
		return stats

	filepath_A_training = f'data/lbp/training{preproc_dir}/features_A_lbp_{vdiv}x{hdiv}.npy'
	filepath_B_training = f'data/lbp/training{preproc_dir}/features_B_lbp_{vdiv}x{hdiv}.npy'
	filepath_A_testing = f'data/lbp/testing{preproc_dir}/features_A_lbp_{vdiv}x{hdiv}.npy'
	filepath_B_testing = f'data/lbp/testing{preproc_dir}/features_B_lbp_{vdiv}x{hdiv}.npy'
	metrics = [
		# euclidean_distances, 
		# cosine_similarity, 
		# mahalanobis_distances, 
		nca_distances, 
		# lmnn_distances
		]
	opcs = [3]
	# [665, 670, 675, 680, 685, 690, 695, 705, 710]
	# [1100, 1050, 1025, 975]
	# [900, 925, 950]
	# [70, 70, 70, 70, 70]
	n_components = [700, 800, 900, 1000]
	for metric, opc, n in product(metrics, opcs, n_components):
		key = _in_results(metric, opc, n_components=n, preproc=preproc)
		key += ", testing"
		execute = True
		exp_number = ""
		if key not in results: 
			results[key] = []
		else:
			stats = _get_statistics(results[key])
			exp_number = f"_n{stats['n_experiments']}"
			if stats['mean_time'] > 1000: execute = False

		if execute:
			key_n = f"{key}{exp_number}" 
			train_result, mmc, pcas = metric_pipeline(filepath_A_training, 
				filepath_B_training, key_n + "_prev", metric, opc, n)
			result, _, _ = metric_pipeline(filepath_A_testing, 
				filepath_B_testing, key_n, metric, opc, n, 
				mmc, pcas)
			results[key].append(result)
	if not os.path.exists('results'): 
		os.makedirs('results')
	with open('results/data_array.json', 'w') as outfile:
		json.dump(results, outfile)



if __name__ == '__main__':
	
	main()
	"""
	with open('results/data.json', 'r') as infile:
		results = json.load(infile)
	with open('results/data_array.json', 'w') as outfile:
		json.dump({k: [v, ] for k, v in results.items()}, outfile)
	"""
	with open('results/data_array.json', 'r') as infile:
		results = json.load(infile)
		results = {k: v for k, v in sorted(results.items(), key=lambda item: np.mean([
			i['d_prime'] for i in item[1]]), 
			reverse=True)}
		print("")
		lines = []
		for k, v in results.items():
			line = [k]
			v_mean_listed = [np.mean([i[key] for i in v]) for key in [
				"d_prime", "FMR", "FNMR", "time"]]
			# v_max = v[np.argmax([i['d_prime'] for i in v])]
			# line.extend(list(v_max.values()))
			line.extend(v_mean_listed)
			d_primes = [i['d_prime'] for i in v]
			std_d_prime = np.std(d_primes)
			min_d_prime = np.min(d_primes)
			max_d_prime = np.max(d_primes)
			line.extend([std_d_prime, min_d_prime, max_d_prime])
			if True:
			# if not "notch_filter" in k and "00" in k:
			# line.extend([len(v)])
				lines.append(line)

	print(tabulate(lines, headers=["method", "d_prime", "FMR", "FNMR", "time", 
			"std_d_prime", "min_d_prime", "max_d_prime"], tablefmt="github"))
	




