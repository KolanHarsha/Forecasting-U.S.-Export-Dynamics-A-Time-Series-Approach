# Forecasting-U.S.-Export-Dynamics-A-Time-Series-Approach
## **Objective**
The main goal of this project is to conduct a thorough time series analysis of monthly export data for the United States, spanning 23 years of historical records to uncover underlying patterns in monthly export trends. The objective is to understand how these patterns evolve over time, identify recurring seasonal fluctuations, long-term trends, and any irregularities that may impact export performance.
The analysis encompasses U.S. international export monthly data from 2000 to 2023, employing five distinct models:
1. A regression model featuring linear trend and seasonality.
2. A two-level forecasting model combining regression with linear trend and seasonality, and trailing MA (k=6) for residuals.
3. Another two-level forecasting model integrating regression with linear trend and seasonality, along with order-5 auto-regressive (AR5) for residuals.
4. Holt-Winter’s model.
5. Auto-ARIMA model.

## **Softwares**

<img src="https://github.com/user-attachments/assets/f3c061f2-9c9e-4ced-af4f-9af148be699c" alt="python" width="150" height="100">

## **Data-Overview**
The data is collected from U.S Census Bureau and is available in "Us_Monthly_exports_2000-2023.xlsx" file.

![image](https://github.com/user-attachments/assets/e570b219-c422-41df-98c5-b3a206c39b67)

The data plots illustrate the international exports over a 23-year period from 2000 to 2023. The time series trend exhibits a mix of upward and downward trends. A significant decrease in exports is observed during the 2008-2009 period, attributed to the Great Recession, and a similar pattern is noted between 2019 and 2020 due to the impact of COVID-19. However, despite these downturns, the overall trend shows a consistent upward trajectory.

![image](https://github.com/user-attachments/assets/89b21e2d-6d2f-4ab2-933e-a7a87b6d42bd)

From the autocorrelation chart above we see that the data is highly correlated, as the autocorrelation coefficients in all the lags are substantially higher than the horizontal threshold (significantly greater than zero). For all the lags, the autocorrelation coefficients have a positive value. A positive autocorrelation coefficient in lag 1 is substantially higher than the horizontal threshold, which is indicative of an upward trend component. A positive autocorrelation coefficient in lag 12, which is also statistically significant, points to a seasonal component being present in the data. It can be concluded that the data is not just comprised of a level component.

## **Checking predictability using Hypothesis Testing and First Differencing of historical data.**
The primary objective of this analysis is to conduct a z-test using the AR(1) model to assess the significance of the autocorrelation at lag 1. The calculated z-statistic was -0.8571429, resulting in a p-value of 0.195683. Since the p-value exceeds the chosen significance level (p-value > 0.05), the decision is made to accept the null hypothesis.
Further investigation is done using the autocorrelation in first-differenced data, utilizing the Acf() function in R. The autocorrelation chart for the first differencing data is shown below.

![image](https://github.com/user-attachments/assets/2acafa08-0006-47e2-af5c-2cc99d4d9b36)

Although not all autocorrelation coefficients of the first differenced data are statistically significant, only the lag-1 autocorrelation is significant. Nevertheless, it is still valuable to explore different models as it is not a random walk.

## **Apply Forecasting & Comparing Performance**
The dataset is divided into two parts – Training and Validation. The training is used to train the forecasting models and the set consists of 240 records from the period of January 2000 to December 2019. The validation set is used to validate the performance of the forecasting models and has 48 records from the period of January 2020 to December 2023.

![image](https://github.com/user-attachments/assets/b457cb3f-549a-4e84-b72f-3559dde035a7)

### **Regression model with linear trend and seasonality**
The summary of the regression model with linear trend and seasonality for the training set is shown below.

![image](https://github.com/user-attachments/assets/b01bec97-d383-48cb-a24a-2f5fed606f8c)

The linear regression model has 12 predictors- 1trend + 11 dummy variables for seasonality feb (season2) to dec (season12). All the seasonal variables are statistically insignificant. The intercept of the model is 53999.583. The model has a R-squared of 0.884 and adj. R_squared of 0.8779.
The regression model equation is:

    yt = 53999.583 + 393.286 t + 371.214 D2 + ………-71.649 D12

![image](https://github.com/user-attachments/assets/5121ae99-d8fd-4520-8d7c-0e200a271c20)

### **Two-Level Forecast- Regression model with linear trend and seasonality + Trailing MA (k=6) for residuals**
Trailing MA with a window width of 6 is trained using the above linear regression model residuals. The below plot shows regression residuals and trailing MA residuals for training and validation partition.

![image](https://github.com/user-attachments/assets/e97e6fa3-5ff2-4038-893f-8f772fe2742d)

The table containing validation partition data (Exports), regression forecast (Regression.Fst), MA forecast for regression residuals (MA.Residuals.Fst), and combined (2-level) forecast (Combined.Fst(MA1)) that combines the two previous forecasts is shown below:

![image](https://github.com/user-attachments/assets/f53d921c-992f-4bac-89ab-2e1b1dbc68d3)

![image](https://github.com/user-attachments/assets/7b0f0946-c1f3-4594-a71a-e5db717837ec)

### **Two-Level Forecast- Regression model with linear trend and seasonality + AR(5) for residuals**
The autocorrelation chart (correlogram) of the residuals from the regression model with linear trend and seasonality is provided below.

![image](https://github.com/user-attachments/assets/9b50e21d-1966-4b19-b6f8-b1785ba2dc1f)

The plot indicates notable autocorrelation among the residuals across lag intervals 1 to 12. This suggests that the regression model does not account for these autocorrelations among the residuals. Consequently, by incorporating these residual autocorrelations using an autoregressive (AR) model and implementing a two-level forecasting approach, the forecast could potentially be enhanced.
The correlogram for the residuals of the AR(1), AR(2), AR(3), AR(4) and AR(5) model (residuals of residuals) are shown below

![image](https://github.com/user-attachments/assets/8e275f9d-7f68-4cf7-8eb5-ab2051e3f71b)  ![image](https://github.com/user-attachments/assets/c603bf44-6a15-4308-b380-880e732f7d0f)

![image](https://github.com/user-attachments/assets/e52eb0ef-ccf1-4123-bf92-ea2a515d85b2)  ![image](https://github.com/user-attachments/assets/f8227a0d-dc34-4510-8b75-70519a88f426)

![image](https://github.com/user-attachments/assets/1d6ea7fe-da45-4c09-994b-4db9d8a67186)

The correlogram reveals that the autocorrelations for the AR(5) model's residuals appear to be random, indicating that the AR(5) model has successfully captured significant autocorrelation at all lags. Consequently, integrating the AR(5) model for residuals with the regression model could enhance the forecasting of the time series.
The summary of the AR(5) model for the regression residuals is shown below

![image](https://github.com/user-attachments/assets/7683fc44-f0f8-42b7-8e19-079db31e8964)

The AR(5) model’s equation is:

    et = -39.2819 + 0.9528 et-1 + 0.1910 et-2 - 0.0024 et-3 - 0.0628 et-4 - 0.1194 et-5

The below plot shows regression residuals and AR(5) residuals for training and validation partition.

![image](https://github.com/user-attachments/assets/bd5296f4-7115-4c8c-9b04-1fff41df9e5a)

The table containing validation partition data (Exports), regression forecast (Regression.Fst), AR(5) forecast for regression residuals (AR(5).Residuals.Fst), and combined (2-level) forecast (Combined.Fst(AR5)) that combines the two forecasts is shown below:

![image](https://github.com/user-attachments/assets/54148ca1-fd90-4cd9-9a30-180fbc866bb7)

### **Holt-Winter’s Model**
The summary of the Holt-Winter’s (HW) model with automated selection of error, trend and seasonality options, and automated selection of smoothing parameters for the training partition is shown below.

![image](https://github.com/user-attachments/assets/ddcaf6f6-59d9-4f7a-bbdc-aaefb30a91b2)

The HW model has the (M,Ad,N) options which indicates multiplicative error, additive trend, and no seasonality. The optimal value for exponential smoothing constant (alpha) is 0.7249, the smoothing constant for trend estimate (beta) is 0.3264, and damping constant (phi) is 0.8.

![image](https://github.com/user-attachments/assets/1ef98ef0-8394-41f0-a49b-501342d92304)

### **Auto-ARIMA model**
The summary of the auto-ARIMA model is for the training period is shown below.

![image](https://github.com/user-attachments/assets/454d41dc-bb7b-42cf-acaa-1927ccd296e3)

This is a non-seasonal ARIMA model, (2,1,2), with the following parameters:
• p = 2, order-2 autoregressive model AR(2)
• d = 1, first differencing
• q = 2, order 2 moving average MA(2) for error lags
The ARIMA model’s equation is:

    yt - yt-1 = 1.1970(yt-1 -yt-2) – 0.5232(yt-2 -yt-3) – 1.2335εt-1 + 0.7166εt-2 + 311.4698

In ARIMA (AutoRegressive Integrated Moving Average) models, drift(311.4698) refers to a constant term added to the model to account for long-term trends or shifts in the data that are not captured by the autoregressive or moving average components.
In a basic ARIMA model, the drift parameter is denoted as "d" and is typically included in models with the integrated component (the "I" in ARIMA), which represents differencing to make the time series stationary. The drift term allows the model to capture linear trends in the data.

![image](https://github.com/user-attachments/assets/b470a5c8-2111-4cfe-a86e-6d7bb77682ec)

### **Performance measures of the models on validation data**

![image](https://github.com/user-attachments/assets/b781a017-dd84-4eee-be3d-989c1e25bfdd)

### **Training Models on entire dataset**
The 5 models are trained on entire dataset and the table below shows the forecast of the five models in the future of 2024

![image](https://github.com/user-attachments/assets/9163cce7-3df5-454d-9f8e-927675ba14ac)

## **Determining the best model**
The performance measures of the models along with base-line models on entire dataset is shown below

![image](https://github.com/user-attachments/assets/cb7c55e5-9b4c-4995-b229-699d9a8cdd34)

Based on above table the best performing models are:
1. Regression with linear trend and seasonality + AR(5)
2. Holt’s Winter model
3. Auto-ARIMA model

![image](https://github.com/user-attachments/assets/49318b5b-44a5-4923-a6df-b41c9d52122b)

![image](https://github.com/user-attachments/assets/b237efdb-59e6-413a-a459-319a22d71241)

![image](https://github.com/user-attachments/assets/3acb27e6-56d7-4822-8078-66a4565408ed)

## **Conclusion**

After thorough analysis of both Mean Absolute Percentage Error (MAPE) and Root Mean Squared Error (RMSE) values, the Regression model with linear trend and seasonality combined with autoregressive component of order 5 for residuals emerges as the optimal choice among the evaluated models for U.S. international exports analysis. Although the MAPE for this model slightly surpasses that of Auto-ARIMA (1.96% compared to 1.953%), its RMSE significantly outperforms Auto-ARIMA, standing at 3302.002 compared to 3461.523. Therefore, the Regression model with linear trend and seasonality combined with AR(5) for residuals is deemed the best model. Additionally, this model exhibits lower MAPE and RMSE values compared to baseline models, further supporting its superiority for the analysis of U.S. international exports

## **Contributors**
- Sai Harsha Vardhan Reddy, Kolan- skolan@horizon.csueastbay.edu, harsha62334@gmail.com

Thanks for reading!
