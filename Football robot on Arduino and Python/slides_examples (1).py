
############# SLIDES SIFT

import cv2
from matplotlib.pylab import *

# open the image and store it in 'I'
I = cv2.imread('crop_0001.png',0)
imshow(I,cmap='gray'),show()

# create a SIFT object
sift = cv2.SIFT()

# detect and compute SIFT descriptors
kp,desc = sift.detectAndCompute(I,None)

# show descriptors in image
img=cv2.drawKeypoints(I,kp, flags=cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
imshow(img),show()




############# SLIDES KMEANS


from sklearn.cluster import KMeans
from numpy.random import normal

# synthetic data to show clusters
real_centers = np.array([[2,1],[4,-1],[3,4],[5,3]])
DESC = zeros((5000,2))
for i in range(0,5000):
    DESC[i,:] = real_centers[random_integers(0,3),:] + normal(0,0.5,2)
plot(DESC[:,0],DESC[:,1],'.'), show()

K = 4
km = KMeans(K, init='k-means++')
km.fit(DESC) # run K-means
labels = km.predict(DESC) # predict labels

for cl in range(0,K) :
    idx = where(labels==cl)[0]
    plot(DESC[idx,0],DESC[idx,1],'.',markersize=16,color=(random(),random(),random()))
show()


# load images of bykes and airplanes

import os

bPath = 'CaltechCrops320-240-Train/motosTrain'
bIm = sorted([f for f in os.listdir(bPath) if os.path.splitext(f)[1] == '.png'])
fPath = 'CaltechCrops320-240-Train/airplanesTrain'
fIm = sorted([f for f in os.listdir(fPath) if os.path.splitext(f)[1] == '.png'])

# create the "data cloud"
DESC = zeros((0,128)) # SIFT --> 128-dim vectors
for i in range(0,20) :
    I_temp = cv2.imread(os.path.join(bPath,bIm[i]),0)
    DESC = concatenate((DESC,sift.detectAndCompute(I_temp,None)[1]))
    I_temp = cv2.imread(os.path.join(fPath,fIm[i]),0)
    DESC = concatenate((DESC,sift.detectAndCompute(I_temp,None)[1]))

# create K clusters
K = 10
km = KMeans(K, init='k-means++')
km.fit(DESC) # run K-means

######### SLIDES BOW

figure(1)
for i in range(0,3) :
    I_temp = cv2.imread(os.path.join(bPath,bIm[i]),0)
    labels = km.predict(sift.detectAndCompute(I_temp,None)[1])
    
    # Bow: histogram of labels    
    BoW_temp = histogram(labels,linspace(-0.5,K-0.5,K+1))[0]
    subplot(3,4,4*i+1),imshow(I_temp,cmap='gray'), axis('off')
    subplot(3,4,4*i+2), bar(range(0,K),BoW_temp), axis('off')
for i in range(0,3) :
    I_temp = cv2.imread(os.path.join(fPath,fIm[i]),0)
    labels = km.predict(sift.detectAndCompute(I_temp,None)[1])
    
    # Bow: histogram of labels    
    BoW_temp = histogram(labels,linspace(-0.5,K-0.5,K+1))[0]
    subplot(3,4,4*i+3),imshow(I_temp,cmap='gray'), axis('off')
    subplot(3,4,4*i+4), bar(range(0,K),BoW_temp), axis('off')
show()


######### SLIDES SVM

from sklearn.svm import SVC
from sklearn.metrics import confusion_matrix

X = zeros((0,K))
y = zeros(0,int64)

# create train/test data

# bykes
for i in range(0,100) :
    I_temp = cv2.imread(os.path.join(bPath,bIm[i]),0)
    labels = km.predict(sift.detectAndCompute(I_temp,None)[1])
    BoW_temp = histogram(labels,linspace(-0.5,K-0.5,K+1))[0]
    X = concatenate((X,BoW_temp[newaxis,:]))
    y = concatenate((y,[1]))

# airplanes
for i in range(0,100) :
    I_temp = cv2.imread(os.path.join(fPath,fIm[i]),0)
    labels = km.predict(sift.detectAndCompute(I_temp,None)[1])
    BoW_temp = histogram(labels,linspace(-0.5,K-0.5,K+1))[0]
    X = concatenate((X,BoW_temp[newaxis,:]))
    y = concatenate((y,[2]))

idx = permutation(range(0,200))

X_train = X[idx[:160],:]
X_test  = X[idx[160:],:]
y_train = y[idx[:160]]
y_test  = y[idx[160:]]

classifier = SVC(kernel='linear') # create linear classifier

classifier.fit(X_train, y_train) # train classifier

y_pred = classifier.predict(X_test) #test classifier

CM = confusion_matrix(y_test, y_pred) # confusion matrix
print CM

# now test with 100 random images

names_clas = ['BYKE','AIRPLANE']
for i in range(0,100):
    clas = random_integers(0,1)
    if clas == 0 :
        im_id = random_integers(100,len(bIm)-1)
        I_temp = cv2.imread(os.path.join(bPath,bIm[im_id]),0)
    else :
        im_id = random_integers(100,len(fIm))
        I_temp = cv2.imread(os.path.join(fPath,fIm[im_id]),0)
    labels = km.predict(sift.detectAndCompute(I_temp,None)[1])
    BoW_temp = histogram(labels,linspace(-0.5,K-0.5,K+1))[0]
    clas_pred = classifier.predict(BoW_temp[newaxis,:])
    imshow(I_temp,cmap='gray'), text(10,5,'%s'%(names_clas[int64(clas_pred)-1],),fontsize=42, color='red')
    axis('off')
    show()





