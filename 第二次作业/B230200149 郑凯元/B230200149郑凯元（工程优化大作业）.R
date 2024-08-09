# SVM pore
# load library
library(kernlab)

# set the working directory
setwd("D:/SVM/R_wd_fuben_2024_wuzhicheng/1_20240302")
switch_add_boundary_data <- 1

# load the data and normalize them
d <- read.csv(file='data_topsurface.csv')
dataNo <- nrow(d)
Surface <- as.matrix(d[1:dataNo,4])
Power <- as.matrix(d[1:dataNo,1])
ScanSpeed <- as.matrix(d[1:dataNo,2])
LineOffset <- as.matrix(d[1:dataNo,3])
d1 <- data.frame(Power,ScanSpeed,LineOffset,Surface)

# Add boundary data, i.e. I, V, LO = 0 lead to bad label
if (switch_add_boundary_data == 1){
  I_min = 50
  I_max = 500
  V_min = 50
  V_max = 1500
  LO_min = 0.02
  LO_max = 0.18
  
  add_data_I <- seq(from=I_min, to=I_max, by=50)#5
  add_data_V <- seq(from=V_min, to=V_max, by=175)#10
  add_data_LO <- seq(from=LO_min, to=LO_max, by=0.02)#0.01

  add_data <- expand.grid(Power=0, ScanSpeed=add_data_V, LineOffset=add_data_LO, Surface="bad")
  d1 <- rbind(d1,add_data)
  add_data <- expand.grid(Power=add_data_I, ScanSpeed=0, LineOffset=add_data_LO, Surface="bad")
  d1 <- rbind(d1,add_data)
  add_data <- expand.grid(Power=add_data_I, ScanSpeed=add_data_V, LineOffset=0, Surface="bad")
  d1 <- rbind(d1,add_data)
}

#optimization by SVM
t0 <- proc.time()
CrossValidNo <- floor(nrow(d1)/3)
CostParam <- 0.0
error <- 1
while (error > 0) {CostParam <- CostParam + 0.1
set.seed(0)
d1.ksvm <- ksvm(Surface~., data=d1, type="C-svc", kernel="rbfdot", C=CostParam, cross=CrossValidNo)
error <- error(d1.ksvm)
}
CostParam <- CostParam - 0.1
set.seed(0)
d1.ksvm <- ksvm(Surface~.,data=d1,type="C-svc",kernel="rbfdot",C=CostParam,cross=CrossValidNo)
t1 <- proc.time() - t0

#create data points for calculating the decision function values
t0 <- proc.time()
TestI <- seq(from=50, to=500, by=10)#5
TestV <- seq(from=50, to=1500, by=50)#10
TestLO <- seq(from=0.02, to=0.18, by=0.01)#0.01
TestData <- expand.grid(Power=TestI, ScanSpeed=TestV, LineOffset=TestLO)

#output the maximum and optimum conditions
criterionValueMin <- -7
criterionValueMax <- 3
PredictData <- predict(d1.ksvm, TestData, type="decision")
max(PredictData)
min(PredictData)

OptimumRegion <- TestData[which(PredictData > criterionValueMin & PredictData <= criterionValueMax),]
DecisionFunctionValues <- PredictData[which(PredictData > criterionValueMin & PredictData <= criterionValueMax),]
OptimumCondition <- data.frame(OptimumRegion,DecisionFunctionValues)
OptimumCondition <- OptimumCondition[order(OptimumCondition$DecisionFunctionValues, OptimumCondition$Power, decreasing = T),]
rownames(OptimumCondition) <- 1:nrow(OptimumCondition)
MaximumPoint <- TestData[which.max(PredictData),]
MaximumDecisionFunctionValue <- PredictData[which.max(PredictData),]
MaximumCondition <- data.frame(MaximumPoint, MaximumDecisionFunctionValue)
write.csv(MaximumCondition, file='MaxCondition.csv', row.names=FALSE, quote=FALSE)
write.csv(OptimumCondition, file='OptimumCondition.csv', row.names=FALSE, quote=FALSE)

# #output process map
# Lorder=n*LO
# len1 <- 11
# len2 <- 11
# SampleSize <- 10
# for(i in 1:len1){
#   LO <- 0.050*i
#   len3 <- floor(0.5 * SampleSize / LO)
#   for (j in 1:len2) {
#     FO <- 5*(j-1)
#     for (k in 1:len3) {
#       Lorder <- k * LO
#       jpeg(file=paste("LO", as.character(format(LO, nsmall = 3)),"_FO", as.character(format(FO, nsmall = 0)),"_Lorder", as.character(format(Lorder, nsmall = 3)),".jpg", sep=""))
#       plot(d1.ksvm, data=d1, slice=list(LineOffset=LO, FocusOffset=FO, DivideNumber=Lorder))
#       title(xlab = expression("[mm/s]"), ylab=expression("[mA]"))
#       dev.off()
# 
#     }
# 
#   }
# 
# }
# t2 <- proc.time() - t0
