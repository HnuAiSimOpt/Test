import os
import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import transforms, models
from torchvision.datasets import ImageFolder
from torch.utils.data import DataLoader
import copy
from core.utils import load_model
from core.model.wideresnet import WideResNet

transforms = {
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
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")


def train(model, data_dir, data_transforms, save_dir, device, num_epochs=25):
    image_datasets = {x: ImageFolder(os.path.join(data_dir, x), data_transforms[x]) for x in ['train', 'test']}
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


if __name__ == '__main__':
    ## source
    # save_dir = r'G:\TEA_Fault_Diagnosis\output\XJTU_weights\XJTU_origin_resnet50.pth'
    # data_dir = r'G:\数据集\机械故障诊断数据集\XJTU_split\XJTU_origin\\'
    ## gaussion
    save_dir = r'/output/XJTU_weights/XJTU_Gaussian_resnet50.pth'
    data_dir = r'G:\数据集\机械故障诊断数据集\XJTU_split\XJTU_Gaussian\\'
    ## random blur
    # save_dir = r'G:\TEA_Fault_Diagnosis\output\XJTU_weights\XJTU_apply_random_blur_resnet50.pth'
    # data_dir = r'G:\数据集\机械故障诊断数据集\XJTU_split\XJTU_apply_random_blur\\'
    ## brightness
    # save_dir = r'G:\TEA_Fault_Diagnosis\output\XJTU_weights\XJTU_adjust_brightness_resnet50.pth'
    # data_dir = r'G:\数据集\机械故障诊断数据集\XJTU_split\XJTU_adjust_brightness\\'
    train('resnet50', data_dir, transforms, save_dir, device, 10)
