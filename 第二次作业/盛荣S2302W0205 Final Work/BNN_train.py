import torch, time
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.distributions import Normal
import numpy as np
from sklearn import preprocessing
import matplotlib.pyplot as plt
from torch.utils.data import TensorDataset
from torch.utils.data import DataLoader
from get_data import GetData

def seed_everything(seed=56):
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
seed_everything()

class Linear_BBB(nn.Module):
    """
        Layer of our BNN.
    """
    def __init__(self, input_features, output_features, prior_var=1.0):
        super().__init__()
        self.input_features = input_features
        self.output_features = output_features
        self.w_mu = nn.Parameter(torch.zeros(output_features, input_features))
        self.w_rho = nn.Parameter(torch.zeros(output_features, input_features))
        self.b_mu =  nn.Parameter(torch.zeros(output_features))
        self.b_rho = nn.Parameter(torch.zeros(output_features))
        self.w = None
        self.b = None

        self.prior = Normal(0,prior_var)

    def forward(self, input):

        w_epsilon = Normal(0,1).sample(self.w_mu.shape)
        self.w = self.w_mu + torch.log(1+torch.exp(self.w_rho)) * w_epsilon

        b_epsilon = Normal(0,1).sample(self.b_mu.shape)
        self.b = self.b_mu + torch.log(1+torch.exp(self.b_rho)) * b_epsilon

        w_log_prior = self.prior.log_prob(self.w)
        b_log_prior = self.prior.log_prob(self.b)
        self.log_prior = torch.sum(w_log_prior) + torch.sum(b_log_prior)

        self.w_post = Normal(self.w_mu.data, torch.log(1+torch.exp(self.w_rho)))
        self.b_post = Normal(self.b_mu.data, torch.log(1+torch.exp(self.b_rho)))
        self.log_post = self.w_post.log_prob(self.w).sum() + self.b_post.log_prob(self.b).sum()

        return F.linear(input, self.w, self.b)

class MLP_BBB(nn.Module):
    def __init__(self, noise_tol=0.1,  prior_var=1.0):

        super().__init__()
        self.hidden = Linear_BBB(8, 64, prior_var=prior_var)
        self.out = Linear_BBB(64, 3, prior_var=prior_var)
        self.noise_tol = noise_tol

    def forward(self, x):
        x = torch.sigmoid(self.hidden(x))
        x = self.out(x)
        return x

    def log_prior(self):
        return self.hidden.log_prior + self.out.log_prior

    def log_post(self):
        return self.hidden.log_post + self.out.log_post

    def sample_elbo(self, input, target, samples):
        outputs = torch.zeros(samples, target.reshape(-1).shape[0])
        
        log_priors = torch.zeros(samples)
        log_posts = torch.zeros(samples)
        log_likes = torch.zeros(samples)
        for i in range(samples):
            outputs[i] = self(input).reshape(-1)
            log_priors[i] = self.log_prior()
            log_posts[i] = self.log_post()
            log_likes[i] = Normal(outputs[i], self.noise_tol).log_prob(target.reshape(-1)).sum()
        log_prior = log_priors.mean()
        log_post = log_posts.mean()
        log_like = log_likes.mean()
        loss = log_post - log_prior - log_like
        return loss,log_prior,log_post,log_like
start_time = time.time()

"""
    读取数据
"""
DataSet = GetData("D:\\Python WorkShop File\\AutoMCNP\\Result.xlsx")
my_data_set = DataSet.get_data()
x = my_data_set[:,:8]
y = my_data_set[:,8:11]
from sklearn.model_selection import train_test_split
input_train,input_valid,output_train,output_valid= train_test_split(x,y,test_size=0.2,random_state = 20,shuffle = True)
input_valid,input_test,output_valid,output_test= train_test_split(input_valid,output_valid,test_size=0.5,random_state = 20,shuffle = True)

"""
    处理数据，归一化
"""
scaler_input = preprocessing.MinMaxScaler(feature_range=(-1,1))
scaler_input.fit(input_train)
input_train_scaler = torch.tensor(scaler_input.transform(input_train), dtype=torch.float32)
print(input_train_scaler.mean(axis=0),input_train_scaler.std(axis=0))
output_train[:,0:2] = torch.log10(output_train[:,0:2])
scaler_output = preprocessing.StandardScaler()
scaler_output.fit(output_train)
output_train_scaler = torch.tensor(scaler_output.transform(output_train), dtype=torch.float32)
print(output_train_scaler.mean(axis=0),output_train_scaler.std(axis=0))
train_dt = TensorDataset(input_train_scaler, output_train_scaler)
train_dl = DataLoader(train_dt, batch_size= 100 ,shuffle= True)

valid_dt = TensorDataset(input_valid, output_valid)
valid_dl = DataLoader(valid_dt, batch_size= len(valid_dt) ,shuffle= False)

test_dt = TensorDataset(input_test, output_test)
test_dl = DataLoader(test_dt, batch_size= len(test_dt) ,shuffle= False)

"""
    初始化网络结构
"""
net = MLP_BBB(prior_var=1.0)
"""
    训练网络
"""
optimizer = optim.Adam(net.parameters(), lr=0.01)
epochs = 1000
hist_epochs = np.zeros((int(epochs/10),1))
hist_loss = np.zeros((int(epochs/10),1))
train_loss = []
train_prior = []
train_post = []
train_like = []
valid_loss = []
valid_prior = []
valid_post = []
valid_like = []
valid_mape = []
valid_mae =[]
valid_mse = []
valid_rmse = []
valid_log_rmse = []
valid_r2 = []

for epoch in range(epochs):
    net.train()
    for train_index, train_item in enumerate(train_dl):
        xtr, ytr = train_item
        optimizer.zero_grad()
        loss,prior,post,like = net.sample_elbo(xtr, ytr, 10)
        loss.backward()
        optimizer.step()
    train_loss.append(loss.item())
    train_prior.append(prior.item())
    train_post.append(post.item())
    train_like.append(like.item())
    net.eval()

    for valid_index, valid_item in enumerate(valid_dl):
        xv,yv = valid_item
        xv = torch.tensor(scaler_input.transform(xv), dtype=torch.float32)
        y_tmp_valid = net(xv)
        loss_valid,prior_valid,post_valid,like_valid = net.sample_elbo(xv, y_tmp_valid, 10)
        y_tmp_valid = scaler_output.inverse_transform(y_tmp_valid.detach().numpy())
        y_tmp_valid[:,0:2] = 10**y_tmp_valid[:,0:2]
        y_pre_valid = y_tmp_valid
        y_true_valid = yv.numpy()
        abs_err_valid = y_true_valid - y_pre_valid
        mae_valid = np.sum(abs(abs_err_valid),axis=0)/len(abs_err_valid)
        mse_valid = np.sum((abs_err_valid)**2,axis=0)/len(abs_err_valid)
        rmse_valid = np.sqrt(mse_valid)
        log_rmse_valid = np.sqrt(np.sum((np.log10(y_true_valid/y_pre_valid))**2,axis=0)/len(y_true_valid))
        r2_valid = 1-mse_valid/ np.var(y_true_valid,axis=0)
        rel_err_valid = np.abs(abs_err_valid/y_true_valid)
        mape_valid = np.mean(rel_err_valid,axis=0)
        max_rel_err_valid = np.max(rel_err_valid,axis=0)
    valid_loss.append(loss_valid.item())
    valid_prior.append(prior_valid.item())
    valid_post.append(post_valid.item())
    valid_like.append(like_valid.item())
    valid_mape.append(mape_valid)
    valid_mae.append(mae_valid)
    valid_mse.append(mse_valid)
    valid_rmse.append(rmse_valid)
    valid_log_rmse.append(log_rmse_valid)
    valid_r2.append(r2_valid)

    if (0 < np.amax(mape_valid) < 0.05):
        break

    if epoch % 10 == 0:
        hist_loss[int(epoch/10)] = loss.data
        hist_epochs[int(epoch/10)] = epoch+1
        print('epoch: {}/{}'.format(epoch+1,epochs))
        print('Train Loss:', loss.item())
        print('Valid Loss:', loss_valid.item())
print('Finished Training')
end_time = time.time()
train_time = end_time - start_time
print(f"运行时间{train_time}秒")
print('训练次数',epoch)
print('Train Loss:', loss.item())
print('Valid Loss:', loss_valid.item())
print(f"验证集平均相对误差为:{mape_valid}")
print(f"验证集Log-RMS为:{log_rmse_valid}")
print(f"验证集R-Squared为:{r2_valid}")

"""
    从数据集中读取出验证集数据
"""
for test_index, test_item in enumerate(test_dl):
    xt, yt = test_item
    xt = torch.tensor(scaler_input.transform(xt), dtype=torch.float32)

"""
    蒙特卡洛抽样计算输出均值和方差
"""
samples = 200
y_samp_test = torch.zeros(yt.shape)
y_samp_test = y_samp_test.unsqueeze(0)
y_samp_test = y_samp_test.repeat(samples,1,1).numpy()
err_test = np.zeros_like(y_samp_test)
for s in range(samples):
    y_tmp_test = net(xt)
    y_tmp_test = scaler_output.inverse_transform(y_tmp_test.detach().numpy())
    y_tmp_test[:,0:2] = 10**y_tmp_test[:,0:2]
    y_pre_test = y_tmp_test
    y_samp_test[s] = y_pre_test
    err_test[s] = yt.numpy()-y_pre_test

y_pre_mean_test = np.mean(y_samp_test, axis=0, dtype=None, keepdims=False)
y_pre_var_test  = np.var(y_samp_test, axis=0, dtype=None, keepdims=False)

abs_err_test = np.mean(err_test, axis=0, dtype=None, keepdims=False)
mae_test = np.sum(abs(abs_err_test),axis=0)/len(abs_err_test)
mse_test = np.sum((abs_err_test)**2,axis=0)/len(abs_err_test)
rmse_test = np.sqrt(mse_test)
log_rmse_test = np.sqrt(np.sum((np.log10(yt.numpy()/y_pre_test))**2,axis=0)/len(yt.numpy()))
r2_test = 1- mse_test/np.var(yt.numpy(),axis=0)
rel_err_test = np.abs(abs_err_test/yt.numpy())
mape_test = np.mean(rel_err_test,axis=0)
max_rel_err_test = np.max(rel_err_test,axis=0)
print(f"测试集平均相对误差为:{mape_test}")
print(f"测试集Log-RMS为:{log_rmse_test}")
print(f"测试集R-Squared为:{r2_test}")

save_path = 'D:\\Python WorkShop File\\BNN+NSGA3\\demo3_i8o3'
state = {'net': net.state_dict(), 
         'optimizer': optimizer.state_dict(), 
         'epoch': epoch, 
         'scaler_output': scaler_output,
         'scaler_input': scaler_input,}
torch.save(state, save_path +'\\net_8in3out.pth')