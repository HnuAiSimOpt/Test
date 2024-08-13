# TEA_Fault_Diagnosis

### 数据处理

- 提供包含CWRU数据集以及PADE数据集的预处理程序，参见`data_process/PADE`以及`data_process/CRWU`
- 程序中包含有小波变换、数据集训练集测试集划分等

### 模型训练

- 提供报告中说明的PADE数据集、CWRU数据集以及其训练保存的模型权重；
- 也可以通过使用`basic/train.py`在修改相关路径之后对自定义数据集进行训练；

### 能量模型调用

- `cfg`目录下保存了使用能量模型进行无源域无监督自适应故障诊断的配置文件，用户也可以根据需求进行修改。
- 指定`.yaml`并修改`main.py`中的路径可以实现能量模型调用

### 程序运行要求

```python
numpy>=1.19.5
torch==1.8.1
torchvision==0.9.1
yacs==0.1.8
iopath==0.1.8
```



