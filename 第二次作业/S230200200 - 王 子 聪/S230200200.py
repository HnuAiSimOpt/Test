"""
一种基于SVM的汽车检测算法

S230200200
王  子  聪
"""


import time
import pickle
from os import walk
from os import path
from copy import copy

import matplotlib.image as mpimg
from skimage.feature import hog
from scipy.ndimage.measurements import label
from sklearn.svm import LinearSVC
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from visualizations import *
from timeit import default_timer as timer

color_space = 'RGB'

# 方向梯度直方图参数
orient = 9
pix_per_cell = 8
cell_per_block = 2
hog_channel = "ALL"

spatial_size = (32, 32)
hist_bins = 32
spatial_feat = True
hist_feat = True
hog_feat = True

buffer_weights=[0.1,0.2,0.3,0.4]
clf_path = 'clf_pickle_all_v1.p'
Heatmap_buffer = []
N_buffer = 3

y_start_stop = [400, 656]
ystart_0 = y_start_stop[0]
ystop_0 = ystart_0 + 64*2
ystart_1 = ystart_0
ystop_1 = y_start_stop[1]
ystart_2 = ystart_0
ystop_2 = y_start_stop[1]
ystarts = [ystart_1, ystart_2]
ystops = [ystop_1-100, ystop_2]
search_window_scales = [1.5, 2]


# 定义一个函数来返回HOG特征和可视化
def get_hog_features(img, orient, pix_per_cell, cell_per_block,
                        vis=False, feature_vec=True):
    if vis == True:
        features, hog_image = hog(img, orientations=orient,
                                  pixels_per_cell=(pix_per_cell, pix_per_cell),
                                  cells_per_block=(cell_per_block, cell_per_block),
                                  transform_sqrt=True,
                                  visualise=vis, feature_vector=feature_vec)
        return features, hog_image
    else:
        features = hog(img, orientations=orient,
                       pixels_per_cell=(pix_per_cell, pix_per_cell),
                       cells_per_block=(cell_per_block, cell_per_block),
                       transform_sqrt=True,
                       visualise=vis, feature_vector=feature_vec)
        return features


def bin_spatial(img, size=(32, 32)):
    color1 = cv2.resize(img[:,:,0], size).ravel()
    color2 = cv2.resize(img[:,:,1], size).ravel()
    color3 = cv2.resize(img[:,:,2], size).ravel()
    return np.hstack((color1, color2, color3))


# 定义一个函数来计算颜色直方图特征
def color_hist(img, nbins=32):
    channel1_hist = np.histogram(img[:,:,0], bins=nbins)
    channel2_hist = np.histogram(img[:,:,1], bins=nbins)
    channel3_hist = np.histogram(img[:,:,2], bins=nbins)
    hist_features = np.concatenate((channel1_hist[0], channel2_hist[0], channel3_hist[0]))
    return hist_features


# 定义一个函数来从图像列表中提取特征
def extract_features(imgs, color_space='RGB', spatial_size=(32, 32),
                        hist_bins=32, orient=9,
                        pix_per_cell=8, cell_per_block=2, hog_channel=0,
                        spatial_feat=True, hist_feat=True, hog_feat=True):

    features = []

    for file in imgs:
        file_features = []
    
        image = mpimg.imread(file)

        feature_image = np.copy(image)

        if spatial_feat == True:
            spatial_features = bin_spatial(feature_image, size=spatial_size)
            file_features.append(spatial_features)
        if hist_feat == True:
            hist_features = color_hist(feature_image, nbins=hist_bins)
            file_features.append(hist_features)
        if hog_feat == True:
            if hog_channel == 'ALL':
                hog_features = []
                for channel in range(feature_image.shape[2]):
                    hog_features.append(get_hog_features(feature_image[:,:,channel],
                                        orient, pix_per_cell, cell_per_block,
                                        vis=False, feature_vec=True))
                hog_features = np.ravel(hog_features)
            else:
                hog_features = get_hog_features(feature_image[:,:,hog_channel], orient,
                            pix_per_cell, cell_per_block, vis=False, feature_vec=True)
            file_features.append(hog_features)
        features.append(np.concatenate(file_features))
    return features


def slide_window(img, x_start_stop=[None, None], y_start_stop=[None, None],
                    xy_window=(64, 64), xy_overlap=(0.5, 0.5)):
    if x_start_stop[0] == None:
        x_start_stop[0] = 0
    if x_start_stop[1] == None:
        x_start_stop[1] = img.shape[1]
    if y_start_stop[0] == None:
        y_start_stop[0] = 0
    if y_start_stop[1] == None:
        y_start_stop[1] = img.shape[0]
    xspan = x_start_stop[1] - x_start_stop[0]
    yspan = y_start_stop[1] - y_start_stop[0]
    nx_pix_per_step = np.int(xy_window[0]*(1 - xy_overlap[0]))
    ny_pix_per_step = np.int(xy_window[1]*(1 - xy_overlap[1]))
    nx_buffer = np.int(xy_window[0]*(xy_overlap[0]))
    ny_buffer = np.int(xy_window[1]*(xy_overlap[1]))
    nx_windows = np.int((xspan-nx_buffer)/nx_pix_per_step)
    ny_windows = np.int((yspan-ny_buffer)/ny_pix_per_step)
    window_list = []
    for ys in range(ny_windows):
        for xs in range(nx_windows):
        
            startx = xs*nx_pix_per_step + x_start_stop[0]
            endx = startx + xy_window[0]
            starty = ys*ny_pix_per_step + y_start_stop[0]
            endy = starty + xy_window[1]

        
            window_list.append(((startx, starty), (endx, endy)))

    return window_list


# 定义一个函数来绘制边界
def draw_boxes(img, bboxes, color=(0, 0, 255), thick=6):

    imcopy = np.copy(img)

    for bbox in bboxes:
        cv2.rectangle(imcopy, bbox[0], bbox[1], color, thick)

    return imcopy


def convert_color(img, conv='RGB2YCrCb'):
    if conv == 'RGB2YCrCb':
        return cv2.cvtColor(img, cv2.COLOR_RGB2YCrCb)
    if conv == 'BGR2YCrCb':
        return cv2.cvtColor(img, cv2.COLOR_BGR2YCrCb)
    if conv == 'RGB2LUV':
        return cv2.cvtColor(img, cv2.COLOR_RGB2LUV)
    if conv == 'RGB2HSV':
        return cv2.cvtColor(img, cv2.COLOR_RGB2HSV)


# 定义一个函数从单个图像窗口提取特征
def single_img_features(img, color_space='RGB', spatial_size=(32, 32),
                        hist_bins=32, orient=9,
                        pix_per_cell=8, cell_per_block=2, hog_channel=0,
                        spatial_feat=True, hist_feat=True, hog_feat=True):

    img_features = []

    if color_space != 'RGB':
        if color_space == 'HSV':
            feature_image = cv2.cvtColor(img, cv2.COLOR_RGB2HSV)
        elif color_space == 'LUV':
            feature_image = cv2.cvtColor(img, cv2.COLOR_RGB2LUV)
        elif color_space == 'HLS':
            feature_image = cv2.cvtColor(img, cv2.COLOR_RGB2HLS)
        elif color_space == 'YUV':
            feature_image = cv2.cvtColor(img, cv2.COLOR_RGB2YUV)
        elif color_space == 'YCrCb':
            feature_image = cv2.cvtColor(img, cv2.COLOR_RGB2YCrCb)
    else:
        feature_image = np.copy(img)

    if spatial_feat == True:
        spatial_features = bin_spatial(feature_image, size=spatial_size)
    
        img_features.append(spatial_features)

    if hist_feat == True:
        hist_features = color_hist(feature_image, nbins=hist_bins)
    
        img_features.append(hist_features)

    if hog_feat == True:
        if hog_channel == 'ALL':
            hog_features = []
            for channel in range(feature_image.shape[2]):
                hog_features.extend(get_hog_features(feature_image[:,:,channel],
                                    orient, pix_per_cell, cell_per_block,
                                    vis=False, feature_vec=True))
        else:
            hog_features = get_hog_features(feature_image[:,:,hog_channel], orient,
                        pix_per_cell, cell_per_block, vis=False, feature_vec=True)
    
        img_features.append(hog_features)
    return np.concatenate(img_features)


# 定义一个将图像传递函数
def search_windows(img, windows, clf, scaler, color_space='RGB',
                    spatial_size=(32, 32), hist_bins=32, orient=9,
                    pix_per_cell=8, cell_per_block=2,
                    hog_channel=0, spatial_feat=True,
                    hist_feat=True, hog_feat=True):
    on_windows = []

    for window in windows:
    
        test_img = cv2.resize(img[window[0][1]:window[1][1], window[0][0]:window[1][0]], (64, 64))

        features = single_img_features(test_img, color_space=color_space,
                            spatial_size=spatial_size, hist_bins=hist_bins,
                            orient=orient, pix_per_cell=pix_per_cell,
                            cell_per_block=cell_per_block,
                            hog_channel=hog_channel, spatial_feat=spatial_feat,
                            hist_feat=hist_feat, hog_feat=hog_feat)
    
        X = np.array(features).reshape(1, -1)
        test_features = scaler.transform(X)
    
        prediction = clf.predict(test_features)
    
        if prediction == 1:
            on_windows.append(window)

    return on_windows


def find_cars(img, ystart, ystop, scale, svc, X_scaler, orient, pix_per_cell, cell_per_block, spatial_size, hist_bins,
              hog_channel, color_space, spatial_feat, hist_feat, hog_feat):

    on_windows = []
    img = img.astype(np.float32)/255

    img_tosearch = img[ystart:ystop,:,:]
    if  color_space == 'YCrCb':
        ctrans_tosearch = convert_color(img_tosearch, conv='RGB2YCrCb')
    else:
        ctrans_tosearch = convert_color(img_tosearch, conv='RGB2HSV')

    if scale != 1:
        imshape = ctrans_tosearch.shape
        ctrans_tosearch = cv2.resize(ctrans_tosearch, (np.int(imshape[1]/scale), np.int(imshape[0]/scale)))

    ch1 = ctrans_tosearch[:,:,0]
    ch2 = ctrans_tosearch[:,:,1]
    ch3 = ctrans_tosearch[:,:,2]

    nxblocks = (ch1.shape[1] // pix_per_cell)-1
    nyblocks = (ch1.shape[0] // pix_per_cell)-1
    nfeat_per_block = orient*cell_per_block**2

    window = 64
    nblocks_per_window = (window // pix_per_cell)-1
    cells_per_step = 2
    nxsteps = (nxblocks - nblocks_per_window) // cells_per_step
    nysteps = (nyblocks - nblocks_per_window) // cells_per_step

    hog1 = get_hog_features(ch1, orient, pix_per_cell, cell_per_block, feature_vec=False)
    hog2 = get_hog_features(ch2, orient, pix_per_cell, cell_per_block, feature_vec=False)
    hog3 = get_hog_features(ch3, orient, pix_per_cell, cell_per_block, feature_vec=False)

    for xb in range(nxsteps):
        for yb in range(nysteps):
            ypos = yb*cells_per_step
            xpos = xb*cells_per_step

            if hog_feat:
            
                if hog_channel == 0:
                    hog_features = hog1[ypos:ypos+nblocks_per_window, xpos:xpos+nblocks_per_window].ravel()
                elif hog_channel == 1:
                    hog_features = hog2[ypos:ypos+nblocks_per_window, xpos:xpos+nblocks_per_window].ravel()
                elif hog_channel == 2:
                    hog_features = hog3[ypos:ypos+nblocks_per_window, xpos:xpos+nblocks_per_window].ravel()
                else:
                    hog_feat1 = hog1[ypos:ypos+nblocks_per_window, xpos:xpos+nblocks_per_window].ravel()
                    hog_feat2 = hog2[ypos:ypos+nblocks_per_window, xpos:xpos+nblocks_per_window].ravel()
                    hog_feat3 = hog3[ypos:ypos+nblocks_per_window, xpos:xpos+nblocks_per_window].ravel()
                    hog_features = np.hstack((hog_feat1, hog_feat2, hog_feat3))

            xleft = xpos*pix_per_cell
            ytop = ypos*pix_per_cell

        
            subimg = cv2.resize(ctrans_tosearch[ytop:ytop+window, xleft:xleft+window], (64,64))

        
            if spatial_feat:
                spatial_features = bin_spatial(subimg, size=spatial_size)

            if hist_feat:
                hist_features = color_hist(subimg, nbins=hist_bins)

            X = np.hstack((spatial_features, hist_features, hog_features)).reshape(1, -1)

            test_features = X_scaler.transform(X)
            test_prediction = svc.predict(test_features)

            if test_prediction == 1:
                xbox_left = np.int(xleft*scale)
                ytop_draw = np.int(ytop*scale)
                win_draw = np.int(window*scale)
            
                on_windows.append(((xbox_left, ytop_draw+ystart),(xbox_left+win_draw,ytop_draw+win_draw+ystart)))
    return on_windows


def add_heat(heatmap, bbox_list):
    for box in bbox_list:
        heatmap[box[0][1]:box[1][1], box[0][0]:box[1][0]] += 1
    return heatmap


def apply_threshold(heatmap, threshold):
    heatmap[heatmap <= threshold] = 0
    return heatmap


def draw_bboxes(img, heatmap_buffer, heatmap_pre, N_buffer):

    heatmap_buffer.append(heatmap_pre)

    if len(heatmap_buffer) > N_buffer:
        heatmap_buffer.pop(0)

    idxs = range(N_buffer)
    for b, w, idx in zip(heatmap_buffer, buffer_weights, idxs):
        heatmap_buffer[idx] = b * w

    heatmap = np.sum(np.array(heatmap_buffer), axis=0)
    heatmap = apply_threshold( heatmap, threshold= sum(buffer_weights[0:N_buffer])*2)


    labels = label(heatmap)

    bboxes = []

    for car_number in range(1, labels[1]+1):
    
        nonzero = (labels[0] == car_number).nonzero()
    
        nonzeroy = np.array(nonzero[0])
        nonzerox = np.array(nonzero[1])
    
        bbox_tmp = ((np.min(nonzerox), np.min(nonzeroy)), (np.max(nonzerox), np.max(nonzeroy)))
        bboxes.append(bbox_tmp)

    for bbox in bboxes:
    
        cv2.rectangle(img, bbox[0], bbox[1], (0,0,255), 4)

    return img, heatmap, bboxes


def generate_heatmap(image, windows_list):
    heat = np.zeros_like(image[:,:,0]).astype(np.float)
    heat = add_heat(heat, windows_list)
    heat = apply_threshold(heat, 1)
    heatmap = np.clip(heat, 0, 255)
    return heatmap


def get_fileNames(rootdir):
    data=[]
    for root, dirs, files in walk(rootdir, topdown=True):
        for name in files:
            _, ending = path.splitext(name)
            if ending != ".jpg" and ending != ".jepg" and ending != ".png":
                continue
            else:
                data.append(path.join(root, name))
    return data


if path.isfile(clf_path):
    print('loading existing classifier...')
    with open(clf_path, 'rb') as file:
        clf_pickle = pickle.load(file)
        svc = clf_pickle["svc"]
        X_scaler = clf_pickle["scaler"]
        orient = clf_pickle["orient"]
        pix_per_cell = clf_pickle["pix_per_cell"]
        cell_per_block = clf_pickle["cell_per_block"]
        spatial_size = clf_pickle["spatial_size"]
        hist_bins = clf_pickle["hist_bins"]
        color_space = clf_pickle["color_space"]
else:
    car_path = '/data/udacity/p5/vehicles'
    notcars_path = '/data/udacity/p5/non-vehicles'
    cars = get_fileNames(car_path)
    notcars = get_fileNames(notcars_path)

    sample_size = min(len(cars), len(notcars))
    cars = cars[0:sample_size]
    notcars = notcars[0:sample_size]

    print('filenames are saved!')

    print('extracting car features...')
    car_features = extract_features(cars, color_space=color_space,
                            spatial_size=spatial_size, hist_bins=hist_bins,
                            orient=orient, pix_per_cell=pix_per_cell,
                            cell_per_block=cell_per_block,
                            hog_channel=hog_channel, spatial_feat=spatial_feat,
                            hist_feat=hist_feat, hog_feat=hog_feat)
    print('car features extracted!')
    print('extracting noncar features...')
    notcar_features = extract_features(notcars, color_space=color_space,
                            spatial_size=spatial_size, hist_bins=hist_bins,
                            orient=orient, pix_per_cell=pix_per_cell,
                            cell_per_block=cell_per_block,
                            hog_channel=hog_channel, spatial_feat=spatial_feat,
                            hist_feat=hist_feat, hog_feat=hog_feat)
    print('noncar features extracted!')

    X = np.vstack((car_features, notcar_features)).astype(np.float64)

    X_scaler = StandardScaler().fit(X)

    scaled_X = X_scaler.transform(X)


    y = np.hstack((np.ones(len(car_features)), np.zeros(len(notcar_features))))

    rand_state = np.random.randint(0, 100)
    X_train, X_test, y_train, y_test = train_test_split(
        scaled_X, y, test_size=0.2, random_state=rand_state)

    print('Using:',orient,'orientations',pix_per_cell,
        'pixels per cell and', cell_per_block,'cells per block')
    print('Feature vector length:', len(X_train[0]))

    svc = LinearSVC()

    t=time.time()
    svc.fit(X_train, y_train)
    t2 = time.time()
    print(round(t2-t, 2), 'Seconds to train SVC...')

    print('Test Accuracy of SVC = ', round(svc.score(X_test, y_test), 4))

    t=time.time()

    clf_pickle = {}
    clf_pickle["svc"] = svc
    clf_pickle["scaler"] = X_scaler
    clf_pickle["orient"] = orient
    clf_pickle["pix_per_cell"] = pix_per_cell
    clf_pickle["cell_per_block"] = cell_per_block
    clf_pickle["spatial_size"] = spatial_size
    clf_pickle["hist_bins"] = hist_bins
    clf_pickle["color_space"] = color_space

    destnation = clf_path
    pickle.dump( clf_pickle, open( destnation, "wb" ) )
    print("Classifier is written into: {}".format(destnation))


def vehicle_detection_svm(image, img_lane_augmented, lane_info):

    start = timer()

    windows_list = []
    for search_window_scale, ystart, ystop in zip(search_window_scales, ystarts, ystops):
        windows_list_tmp = find_cars(np.copy(image), ystart, ystop, search_window_scale, svc, X_scaler, orient, pix_per_cell, cell_per_block,
                            spatial_size, hist_bins, hog_channel, color_space, spatial_feat, hist_feat, hog_feat)
        windows_list.extend(windows_list_tmp)

    heatmap_pre = generate_heatmap(image, windows_list)

    draw_img, heatmap_post, bboxes = draw_bboxes(np.copy(img_lane_augmented), copy(Heatmap_buffer), heatmap_pre, min(len(Heatmap_buffer)+1,N_buffer) )

    if len(Heatmap_buffer) >= N_buffer:
        Heatmap_buffer.pop(0)

    fps = 1.0 / (timer() - start)

    draw_img = draw_background_highlight(image, draw_img, image.shape[1])

    draw_thumbnails(draw_img, image, bboxes)
    draw_lane_status(draw_img, lane_info)

    return draw_img
