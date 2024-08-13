from torchvision.datasets import ImageFolder
import os
import torch
from torch.utils.data import DataLoader
import torchvision.transforms as transforms


def set_transform(dataset):
    if dataset == 'CRWU':
        transform_test = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])
        transform_train = transforms.Compose([transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])])
    else:
        raise
    return transform_train, transform_test

def load_CRWU_tiny(n_examples, data_dir, data_transforms):
    image_datasets = ImageFolder(data_dir, data_transforms)
    batch_size = 32
    dataloader = DataLoader(image_datasets, batch_size, shuffle=True, num_workers=0)
    x_test, y_test = [], []
    for i, (x, y) in enumerate(dataloader):
        x_test.append(x)
        y_test.append(y)
        if n_examples is not None and batch_size * i >= n_examples:
            break
    x_test_tensor = torch.cat(x_test)
    y_test_tensor = torch.cat(y_test)
    x_test_tensor = x_test_tensor[:n_examples]
    y_test_tensor = y_test_tensor[:n_examples]
    return x_test_tensor, y_test_tensor


def load_data(data, n_examples=None, severity=None, data_dir=None, shuffle=False, corruptions=None):
    if data == 'CRWU':
        _, transform = set_transform(data)
        x_test, y_test = load_CRWU_tiny(n_examples, data_dir, transform)
    else:
        raise
    print(x_test.shape, n_examples)
    return x_test, y_test
