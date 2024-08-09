import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import torch
import torch.nn as nn
import torch.optim as optim
import warnings
import random
from sklearn.preprocessing import MinMaxScaler

warnings.filterwarnings('ignore')

torch.backends.cudnn.deterministic = True
torch.backends.cudnn.benchmark = False
torch.manual_seed(42)
np.random.seed(42)
random.seed(42)

train_df = pd.read_csv("DailyDelhiClimateTrain.csv")
print(f"len(train_df):{len(train_df)}")
train_df.head()

meantemp = train_df['meantemp'].values
print(f"len(meantemp):{len(meantemp)}")

plt.plot([i for i in range(len(meantemp))], meantemp)

scaler = MinMaxScaler()
meantemp = scaler.fit_transform(meantemp.reshape(-1, 1))

def split_data(data, time_step=12):
    dataX = []
    datay = []
    for i in range(len(data) - time_step):
        dataX.append(data[i:i + time_step])
        datay.append(data[i + time_step])
    dataX = np.array(dataX).reshape(len(dataX), time_step, -1)
    datay = np.array(datay)
    return dataX, datay

dataX, datay = split_data(meantemp, time_step=12)
print(f"dataX.shape:{dataX.shape},datay.shape:{datay.shape}")

def train_test_split(dataX, datay, shuffle=True, percentage=0.8):
    if shuffle:
        random_num = [index for index in range(len(dataX))]
        np.random.shuffle(random_num)
        dataX = dataX[random_num]
        datay = datay[random_num]
    split_num = int(len(dataX) * percentage)
    train_X = dataX[:split_num]
    train_y = datay[:split_num]
    test_X = dataX[split_num:]
    test_y = datay[split_num:]
    return train_X, train_y, test_X, test_y


train_X, train_y, test_X, test_y = train_test_split(dataX, datay, shuffle=False, percentage=0.8)
print(f"train_X.shape:{train_X.shape},test_X.shape:{test_X.shape}")

X_train, y_train = train_X, train_y


class CNN_LSTM(nn.Module):
    def __init__(self, conv_input, input_size, hidden_size, num_layers, output_size):
        super(CNN_LSTM, self).__init__()
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        self.conv = nn.Conv1d(conv_input, conv_input, 1)
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)
        self.fc = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        x = self.conv(x)
        h0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size)
        c0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size)
        out, _ = self.lstm(x, (h0, c0))
        out = self.fc(out[:, -1, :])
        return out


test_X1 = torch.Tensor(test_X)
test_y1 = torch.Tensor(test_y)

input_size = 1
conv_input = 12
hidden_size = 64
num_layers = 5
output_size = 1


model = CNN_LSTM(conv_input, input_size, hidden_size, num_layers, output_size)
num_epochs = 500
batch_size = 64
optimizer = optim.Adam(model.parameters(), lr=0.0001, betas=(0.5, 0.999))
criterion = nn.MSELoss()

train_losses = []
test_losses = []

print(f"start")

for epoch in range(num_epochs):

    random_num = [i for i in range(len(train_X))]
    np.random.shuffle(random_num)

    train_X = train_X[random_num]
    train_y = train_y[random_num]

    train_X1 = torch.Tensor(train_X[:batch_size])
    train_y1 = torch.Tensor(train_y[:batch_size])


    model.train()
    optimizer.zero_grad()
    output = model(train_X1)
    train_loss = criterion(output, train_y1)
    train_loss.backward()
    optimizer.step()

    if epoch % 50 == 0:
        model.eval()
        with torch.no_grad():
            output = model(test_X1)
            test_loss = criterion(output, test_y1)
        train_losses.append(train_loss)
        test_losses.append(test_loss)
        print(f"epoch:{epoch},train_loss:{train_loss},test_loss:{test_loss}")


def mse(pred_y, true_y):
    return np.mean((pred_y - true_y) ** 2)


train_X1 = torch.Tensor(X_train)
train_pred = model(train_X1).detach().numpy()
test_pred = model(test_X1).detach().numpy()
pred_y = np.concatenate((train_pred, test_pred))
pred_y = scaler.inverse_transform(pred_y).T[0]
true_y = np.concatenate((y_train, test_y))
true_y = scaler.inverse_transform(true_y).T[0]
print(f"mse(pred_y,true_y):{mse(pred_y, true_y)}")

plt.title("CNN_LSTM")
x = [i for i in range(len(true_y))]
plt.plot(x, pred_y, marker="o", markersize=1, label="pred_y")
plt.plot(x, true_y, marker="x", markersize=1, label="true_y")
plt.legend()
plt.show()