import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVR
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import matplotlib.pyplot as plt

# 1. Data generation (simulated dataset)
np.random.seed(42)
n_samples = 500
X = np.random.rand(n_samples, 4)  # Four features: density, specific heat capacity, crystal structure, electrical conductivity
y = 10 * X[:, 0] + 3 * X[:, 1]**2 + np.random.randn(n_samples)  # Generate thermal conductivity data

# 2. Split the dataset
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# 3. Standardize the data
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# 4. SVR model construction and parameter optimization
svr = SVR(kernel='rbf')
param_grid = {
    'C': [0.1, 1, 10, 100],
    'epsilon': [0.01, 0.1, 1],
    'gamma': ['scale', 'auto']
}
grid_search = GridSearchCV(svr, param_grid, cv=5, scoring='neg_mean_squared_error', n_jobs=-1)
grid_search.fit(X_train, y_train)

# 5. Select the best model
best_svr = grid_search.best_estimator_

# 6. Model prediction and evaluation
y_pred = best_svr.predict(X_test)
mse = mean_squared_error(y_test, y_pred)
mae = mean_absolute_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print("Best Parameters:", grid_search.best_params_)
print("MSE on Test Set:", mse)
print("MAE on Test Set:", mae)
print("R² on Test Set:", r2)

# 7. Cross-validation
cross_val_scores = cross_val_score(best_svr, X_train, y_train, cv=5, scoring='neg_mean_squared_error')
print("5-Fold Cross-Validation MSE:", -cross_val_scores.mean())

# 8. Visualization of prediction results
plt.scatter(y_test, y_pred, color='blue')
plt.plot([min(y_test), max(y_test)], [min(y_test), max(y_test)], color='red', linewidth=2)
plt.xlabel('Actual Thermal Conductivity')
plt.ylabel('Predicted Thermal Conductivity')
plt.title('SVR Model Prediction vs Actual')
plt.show()
