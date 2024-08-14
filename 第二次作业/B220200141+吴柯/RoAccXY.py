import cv2
import numpy as np
from math import atan2, asin, degrees

def calculate_rotation(gray, prev_gray, unit_length):
    # 计算光流
    flow = cv2.calcOpticalFlowFarneback(prev_gray, gray, None, 0.5, 3, 15, 3, 5, 1.2, 0)

    dx = np.mean(flow[..., 0])
    dy = np.mean(flow[..., 1])

    # 计算旋转角度（单位：弧度）
    rotation_x = atan2(dy, unit_length)
    rotation_z = asin(dx / unit_length)

    # 将旋转角度从弧度转换为角度
    rotation_x_degrees = degrees(rotation_x)
    rotation_z_degrees = degrees(rotation_z)

    return rotation_x_degrees, rotation_z_degrees, flow

def calculate_acceleration(displacement_list, dt, WINDOW_LENGTH):
    displacement_filtered = np.mean(displacement_list[-WINDOW_LENGTH:])
    acceleration = displacement_filtered / (dt ** 2)
    return acceleration

def calculate_y(gray1, gray2):
    # 使用 SIFT 特征检测器
    sift = cv2.SIFT_create()
    kp1, des1 = sift.detectAndCompute(gray1, None)
    kp2, des2 = sift.detectAndCompute(gray2, None)

    # 使用 FLANN 匹配器
    FLANN_INDEX_KDTREE = 1
    index_params = dict(algorithm=FLANN_INDEX_KDTREE, trees=5)
    search_params = dict(checks=50)
    flann = cv2.FlannBasedMatcher(index_params, search_params)
    matches = flann.knnMatch(des1, des2, k=2)

    # 比率测试，只保留最佳匹配
    good_matches = []
    for m, n in matches:
        if m.distance < 0.7 * n.distance:
            good_matches.append(m)

    # 提取匹配的关键点
    src_pts = np.float32([kp1[m.queryIdx].pt for m in good_matches]).reshape(-1, 1, 2)
    dst_pts = np.float32([kp2[m.trainIdx].pt for m in good_matches]).reshape(-1, 1, 2)

    # 使用单应性进行估计
    M, mask = cv2.findHomography(src_pts, dst_pts, cv2.RANSAC, 20.0)

    # 从单应性矩阵中提取旋转角度
    if M is not None:
        roll_angle = 3 * np.arctan2(M[0, 1], M[0, 0]) * (180 / np.pi)
        return roll_angle
    else:
        return None