import pandas as pd
import torch

class GetData():
    def __init__(self, path):
        self.path = path
    
    def get_data(self):
        # 读取 Excel 文件到 DataFrame 中
        df = pd.read_excel(self.path, engine='openpyxl')  # 使用 openpyxl 引擎

        # 将 DataFrame 转换为 numpy 数组，然后转换为 tensor
        # 假设第一行是标题，所以从第二行开始
        data = df.iloc[1:].values  # 跳过第一行

        # 将 numpy 数组转换为 torch tensor
        dataset = torch.tensor(data, dtype=torch.float32)

        return dataset


        # # TensorDataset对tensor进行打包
        # train_dataset = TensorDataset(input_train, output_train)
        # valid_dataset = TensorDataset(input_valid, output_valid)
        
        # # DataLoader进行数据封装
        # train_dataload = DataLoader(train_dataset, batch_size = 300, shuffle = True)
        # valid_dataload = DataLoader(valid_dataset, batch_size = 300, shuffle = False)

        # return train_dataload, valid_dataload

# DataSet = GetData("F:\Python Working Directory\MY_BNN\spacecraft_data.xls")
# my_data_set = DataSet.get_data()

# Data = GetData("F:\Python Working Directory\MY_BNN\spacecraft_data.xls")
# train_data,valid_data = Data.get_data()
# for i, data in enumerate(train_data, 1):  # 将初始枚举序号修改为1（但还是将所有数据枚举出来）
# # 注意enumerate返回值有两个,一个是序号，一个是数据（包含训练数据和标签）
#     input, label = data
#     print(' batch:{0} x_data:{1}  label: {2}'.format(i, input, label))
# print('end')