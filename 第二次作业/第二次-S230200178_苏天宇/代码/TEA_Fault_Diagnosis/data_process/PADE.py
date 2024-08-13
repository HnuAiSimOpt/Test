import pandas as pd
import os
import numpy as np
import scipy.io as scio
import pywt
import matplotlib
import matplotlib.pyplot as plt
import random
import shutil
import torch
import copy
import torch.nn as nn
import torch.optim as optim
from torchvision import transforms, models
from torchvision import transforms
from torchvision.datasets import ImageFolder
from torch.utils.data import DataLoader
from basic.val import val

matplotlib.use("Agg")
# 常量定义
SEGMENT_SIZE = 2048  # 数据分段的大小
MAX_SEGMENTS = 400  # 最大段数
WAVELET_NAME = 'cmor1-1'
SAMPLING_PERIOD_DEFAULT = 1.0 / 12000
TOTALSCALE_DEFAULT = 128
TRAIN_RATIO_DEFAULT = 0.7
OVERLAP_RATE_DEFAULT = 0.5

"""确保目录存在，如果不存在则创建它。"""


def ensure_directory_exists(directory):
    os.makedirs(directory, exist_ok=True)
def train(model, data_dir, data_transforms, save_dir, device, num_epochs=25):
    image_datasets = {x: ImageFolder(os.path.join(data_dir, x), data_transforms[x]) for x in ['train', 'test']}
    # print(image_datasets)
    dataloaders = {x: DataLoader(image_datasets[x], batch_size=16, shuffle=True, num_workers=0, drop_last=True) for x in
                   ['train', 'test']}
    dataset_sizes = {x: len(image_datasets[x]) for x in ['train', 'test']}
    class_names = image_datasets['train'].classes
    class_num = len(class_names)
    print('class_num: ', class_num)
    if model == "VGG":
        model = models.vgg16(pretrained=True)
        model.classifier[6] = nn.Linear(model.classifier[6].in_features, class_num)  # 修改输出层的维度
    elif "resnet" in model:
        if model == 'resnet18':
            model = models.resnet18(pretrained=True)
        elif model == 'resnet50':
            model = models.resnet50(pretrained=True)
        num_features = model.fc.in_features
        model.fc = nn.Linear(num_features, class_num)
    elif model == "wideresnet":
        model = WideResNet(28, 10, class_num)
    model = model.to(device)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.SGD(model.parameters(), lr=0.001, momentum=0.9)
    best_model_wts = copy.deepcopy(model.state_dict())  # 初始化为初始模型权重
    best_acc = 0.0
    for epoch in range(num_epochs):
        print(f"--------------------------------epoch: {epoch + 1}----------------------------")
        for phase in ['train', 'test']:
            if phase == 'train':
                model.train()
            else:
                model.eval()

            running_loss = 0.0
            running_corrects = 0

            for inputs, labels in dataloaders[phase]:
                inputs = inputs.to(device)  # [4,3,224,224]
                labels = labels.to(device)  # [4,]
                # test = model(inputs)
                # print(test.shape)
                optimizer.zero_grad()
                with torch.set_grad_enabled(phase == 'train'):
                    outputs = model(inputs)
                    _, preds = torch.max(outputs, 1)
                    loss = criterion(outputs, labels)

                    if phase == 'train':
                        loss.backward()
                        optimizer.step()

                running_loss += loss.item() * inputs.size(0)
                running_corrects += torch.sum(preds == labels.data)

            epoch_loss = running_loss / dataset_sizes[phase]
            epoch_acc = running_corrects.double() / dataset_sizes[phase]

            print(f'{phase} Loss: {epoch_loss:.4f} Acc: {epoch_acc:.4f}')
            # 在测试阶段结束时检查并保存最佳模型
            if phase == 'test' and epoch_acc > best_acc:
                best_acc = epoch_acc
                best_model_wts = copy.deepcopy(model.state_dict())
                # 保存模型权重到指定路径
                torch.save(model.state_dict(), save_dir)
                # 在所有epoch训练完成后，加载最佳模型权重
    model.load_state_dict(best_model_wts)
    print(f'Best test Acc: {best_acc:.4f}')

"""
PADE数据集处理
- domain_path: 构造的不同工况的域地址
- img_path: 经过小波变换之后图像目录
- final_path: 划分好训练集和测试集之后的可用目录
"""
class Cross_Domain_Validation:
    def __init__(self, weight_savepath, domain_imagepath):
        self.weightLists = [os.path.join(weight_savepath, item) for item in os.listdir(weight_savepath)]
        self.domainLists = [os.path.join(domain_imagepath, item) for item in os.listdir(domain_imagepath)]

    def VAL(self):
        for model in self.weightLists:

            for data in self.domainLists:
                print(model.split('\\')[-1])
                print(data.split('\\')[-1])
                val(data + '\\test\\', model)
                print('---------------')

class PADE():
    def __init__(self, domain_path, img_path, final_path, ratio):
        self.domain_path = domain_path
        self.img_path = img_path
        self.final_path = final_path
        self.ratio = ratio

    def create_contour_image(self, data_segment, sampling_period, totalscal, wavename, save_path, base_name, segment_num):
        fc = pywt.central_frequency(wavename)  # 计算所选小波的中心频率
        cparam = 2 * fc * totalscal
        scales = cparam / np.arange(totalscal, 0, -1)
        coefficients, frequencies = pywt.cwt(
            data_segment, scales, wavename, sampling_period)
        amp = np.abs(coefficients)
        t = np.linspace(0, sampling_period * len(data_segment),
                        len(data_segment), endpoint=False)

        plt.figure(figsize=(4, 2))
        plt.contourf(t, frequencies, amp, cmap='jet')
        plt.axis('off')
        plt.subplots_adjust(left=0, right=1, top=1, bottom=0)
        plt.savefig(f"{save_path}{base_name}_{segment_num}.jpg")
        plt.close('all')

    def vibration_extract(self, file_path):
        file_content = scio.loadmat(file_path)
        key = file_path.split('\\')[-1].split('.')[0]
        print(key)
        temp = file_content[key]
        Y = temp['Y']
        vibration = Y[0][0][0][6]['Data']
        return vibration[0]

    def generate_images_per_file(self, file_path, save_base_path, sampling_period=SAMPLING_PERIOD_DEFAULT,
                                 totalscal=TOTALSCALE_DEFAULT, wavename=WAVELET_NAME, overlap_rate=OVERLAP_RATE_DEFAULT):
        # 文件保存路径
        # print(file_path)
        a = file_path.split('\\\\')[-1]
        parts = a.split("\\")
        result = "\\".join(parts[1:-1])  # 跳过第一个元素'Domain'
        result = result.split('.')[0]
        # print(result)
        save_path = os.path.join(save_base_path, result)+'\\'
        print('save_path:', save_path)
        # 确保路径存在
        ensure_directory_exists(save_path)
        vibration = vibration_extract(file_path)
        overlap_samples = int(SEGMENT_SIZE * overlap_rate)
        # 调整每段的实际长度以考虑重叠
        effective_segment_size = SEGMENT_SIZE - overlap_samples
        # 确保数据足够
        data = vibration.reshape(-1)[:effective_segment_size * MAX_SEGMENTS]
        # 开始和结束索引初始化
        start_idx = 0
        end_idx = effective_segment_size
        while end_idx <= len(data):
            # 处理当前数据段
            current_segment = data[start_idx:end_idx]
            create_contour_image(current_segment, sampling_period, totalscal, wavename,
                                 save_path, os.path.basename(
                                     file_path).split('.')[0],
                                 (start_idx // effective_segment_size) + 1)

            # 更新下一段的起始和结束索引
            start_idx += effective_segment_size
            end_idx = start_idx + effective_segment_size

            # 最后一段可能不需要再移动，避免越界
            if end_idx > len(data):
                break

    def Mat2Image(self):
        domain_list = [os.path.join(self.domain_path, item)
                       for item in os.listdir(self.domain_path)]
        for domain in domain_list:  # 遍历构造的域
            situations = [os.path.join(domain, item2)
                          for item2 in os.listdir(domain)]  # 9种工况路径列表
            for situation in situations:
                temp = situation.split('\\')[-2]+'\\'+situation.split('\\')[-1]
                ensure_directory_exists(os.path.join(self.img_path, temp))
                files = os.listdir(situation)
                for file in files:
                    file_dir = os.path.join(situation, file)
                    self.generate_images_per_file(file_dir, self.img_path)

    def split_PADE(self):
        for domain in os.listdir(self.img_path):
            temp = os.path.join(self.final_path, domain)
            ensure_directory_exists(os.path.join(temp, 'train'))
            ensure_directory_exists(os.path.join(temp, 'test'))
        for domain in os.listdir(self.img_path):  # 遍历每个域
            # print(os.path.join(final_path,domain))
            p = os.path.join(self.img_path, domain)  # 获取每个图像域的具体路径
            train_dir = os.path.join(os.path.join(
                self.final_path, domain), 'train')
            # print(train_dir)
            test_dir = os.path.join(os.path.join(
                self.final_path, domain), 'test')
            # print(test_dir)
            kinds = os.listdir(p)
            for kind in kinds:
                category_path = os.path.join(p, kind)
                images = [os.path.join(category_path, img) for img in os.listdir(category_path) if
                          img.endswith(('.jpg', '.png', '.jpeg'))]
                # 打乱顺序
                random.shuffle(images)
                # 分割点计算
                split_point = int(len(images) * self.ratio)  # 70%作为训练集

                # 训练集和测试集划分
                train_images, test_images = images[:
                                                   split_point], images[split_point:]
            # 创建对应类别的训练集和测试集目录
                ensure_directory_exists(os.path.join(train_dir, kind))
                ensure_directory_exists(os.path.join(test_dir, kind))

            # 将图片复制到相应的训练集或测试集目录
                for image_path in train_images:
                    shutil.copy(image_path, os.path.join(
                        train_dir, kind, os.path.basename(image_path)))

                for image_path in test_images:
                    shutil.copy(image_path, os.path.join(
                        test_dir, kind, os.path.basename(image_path)))
    def Process(self):
        self.Mat2Image()
        self.split_PADE()

class PADE_train():
    def __init__(self, separated_path, weight_savepath, model, epoch):
        self.model = model
        self.domainList = [os.path.join(separated_path, i) for i in os.listdir(separated_path)]
        self.transforms = {
            'train': transforms.Compose([
                transforms.Resize((224, 224)),
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
            ]),
            'test': transforms.Compose([
                transforms.Resize((224, 224)),
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
            ]),
        }
        self.weight_savepath = weight_savepath
        self.epoch = epoch
        self.device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

    def Train(self):
        for i in range(len(self.domainList)):
            suffix = self.domainList[i].split('\\')[-1] + '_'+self.model+'.pth'
            print(suffix)
            weight_savepath = os.path.join(self.weight_savepath, suffix)
            train(self.model, self.domainList[i], self.transforms, weight_savepath, device=self.device, num_epochs=10)





if __name__ == '__main__':
    domain_path = r'G:\\数据集\\机械故障诊断数据集\\PADE\\Domain'
    img_path = r'G:\数据集\机械故障诊断数据集\PADE\Img'
    final_path = r'G:\数据集\机械故障诊断数据集\PADE\Final'
    weights = r'G:\数据集\机械故障诊断数据集\PADE\Weights'
    ensure_directory_exists(img_path)
    ensure_directory_exists(domain_path)
    ensure_directory_exists(final_path)
    # pade = PADE(domain_path, img_path, final_path, 0.7)
    # pade.Process()
    pade_train = PADE_train(final_path,weights,'resnet50',10)
    # print(pade_train.domainList)
    # pade_train.Train()
    valer = Cross_Domain_Validation(weights,final_path)
    valer.VAL()