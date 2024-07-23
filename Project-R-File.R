## USE FORECAST LIBRARY.
library(readxl)
library(forecast)
library(zoo)

## CREATE DATA FRAME. 

# Set working directory for locating files.
setwd("C:/Users/STSC/Desktop/Time-series Project")

# Create data frame.
Exports.data <- read_excel("Us_Monthly_exports_2000-2023.xlsx")

# See the first 6 records of the file.
head(Exports.data)
tail(Exports.data)

exports.ts <- ts(Exports.data$Value, 
                   start = c(2000, 1), end = c(2023, 12), freq = 12)
exports.ts

## Use plot() to plot time series data  
plot(exports.ts, 
     xlab = "Time", ylab = "U.S International Exports (in Million$)", 
     ylim = c(50000, 180000), xaxt = 'n',
     main = "U.S International Exports",
     bty = "l", lwd = 2, col="blue")

# Establish x-axis scale interval for time in months.
axis(1, at = seq(2000, 2024, 1), labels = format(seq(2000, 2024, 1)))

# Use Acf() function to identify autocorrelation and plot autocorrelation
# for different lags.
autocor <- Acf(exports.ts, lag.max = 12, 
               main = "Autocorrelation for U.S International Exports")

# Display autocorrelation coefficients for various lags.
Lag <- round(autocor$lag, 0)

ACF <- round(autocor$acf, 3)
data.frame(Lag, ACF)

# Predictability-test
exports.ar1<- Arima(exports.ts, order = c(1,0,0))
summary(exports.ar1)

# Apply z-test to test the null hypothesis that beta 
# coefficient of AR(1) is equal to 1.
ar1 <- 0.9970
s.e. <- 0.0035
null_mean <- 1
alpha <- 0.05
z.stat <- (ar1-null_mean)/s.e.
z.stat
p.value <- pnorm(z.stat)
p.value
if (p.value<alpha) {
  "Reject null hypothesis"
} else {
  "Accept null hypothesis"
}

# Create first differenced data using lag1.
diff.exports.ts <- diff(exports.ts, lag = 1)
diff.exports.ts

# Use Acf() function to identify autocorrealtion for first differenced 
# Amtrak Ridership, and plot autocorrelation for different lags 
# (up to maximum of 12).
Acf(diff.exports.ts, lag.max = 12, 
    main = "Autocorrelation for Differenced U.S Exports Data")

nValid <- 48 
nTrain <- length(exports.ts) - nValid
train.ts <- window(exports.ts, start = c(2000, 1), end = c(2000, nTrain))
valid.ts <- window(exports.ts, start = c(2000, nTrain + 1), 
                   end = c(2000, nTrain + nValid))

# Use tslm() function to create linear trend and seasonal model.
train.lin.season <- tslm(train.ts ~ trend + season)

# See summary of linear trend and seasonality model and associated parameters.
summary(train.lin.season)

train.lin.season.res <- train.lin.season$residuals
train.lin.season.res

ma.trail.res <- rollmean(train.lin.season.res, k = 6, align = "right")
ma.trail.res

# Apply forecast() function to make predictions for ts with 
# linear trend and seasonality data in validation set.  
train.lin.season.pred <- forecast(train.lin.season, h = nValid, level = 0)
train.lin.season.pred

# Plot ts data, linear trend and seasonality data, and predictions for validation period.
plot(exports.ts, 
     xlab = "Time", ylab = "U.S International Exports (in Million$)", 
     ylim = c(50000, 190000), bty = "l",
     xlim = c(2000, 2025.25), xaxt = "n",
     main = "Regression Model with Linear Trend and Seasonality", 
     ) 
axis(1, at = seq(2000, 2025, 1), labels = format(seq(2000, 2025, 1)))
lines(train.lin.season$fitted, col = "blue", lwd = 2, lty = 1)
lines(train.lin.season.pred$mean, col = "blue", lwd = 2, lty = 2)
legend(2000,190000, legend = c("U.S Exports for Time-Series", 
                             "Linear Trend and Seasonality Model for Training Data",
                             "Linear Trend and Seasonality Forecast for Validation Data"), 
       col = c("black", "blue" , "blue"), 
       lty = c(1, 1, 2), lwd =c(2, 2, 2), bty = "n")

# Plot on the chart vertical lines and horizontal arrows
# describing training, validation, and future prediction intervals.
lines(c(2020, 2020), c(0, 140000))
lines(c(2024, 2024), c(0, 140000))
text(2010, 140000, "Training")
text(2022, 140000, "Validation")
text(2024.8, 140000, "Future")
arrows(2000, 140000, 2019.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2020.1, 140000, 2023.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2024.1, 140000, 2025.3, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)

# Regression residuals in validation period.
train.lin.season.res.valid <- valid.ts - train.lin.season.pred$mean
train.lin.season.res.valid

# Create residuals forecast for validation period.
ma.trail.res.pred <- forecast(ma.trail.res, h = nValid, level = 0)
ma.trail.res.pred

# Plot residuals and MA residuals forecast in training and validation partitions. 
plot(train.lin.season.res, 
     xlab = "Time", ylab = "Exports (in M$)", ylim = c(-65000, 65000), 
     bty = "l", xlim = c(2000, 2025.25), xaxt = "n",
     main = "Regression Residuals and Trailing MA for Residuals", 
     col = "brown", lwd =2) 
axis(1, at = seq(1991, 2025, 1), labels = format(seq(1991, 2025, 1)))
lines(train.lin.season.res.valid, col = "brown", lwd = 2, lty = 2)
lines(ma.trail.res, col = "blue", lwd = 2, lty = 1)
lines(ma.trail.res.pred$mean, col = "blue", lwd = 2, lty = 2)
legend(2000,65000, legend = c("Regression Residuals, Training Partition", 
                            "Regression Residuals, Validation Partition",
                            "MA Forecast (k=6), Training Partition", 
                            "MA forecast (k=6), Validation Partition"), 
       col = c("brown", "brown", "blue", "blue"), 
       lty = c(1, 2, 1, 2), lwd =c(2, 2, 2, 2), bty = "n")


lines(c(2020, 2020), c(-60000, 14000))
lines(c(2024, 2024), c(-60000, 14000))
text(2010, 20000, "Training")
text(2022, 22200, "Validation")
text(2024.8, 22200, "Future")
arrows(2000, 20000, 2019.9, 20000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2020.1, 20000, 2023.9, 20000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2024.1, 20000, 2025.3, 20000, code = 3, length = 0.1,
       lwd = 1, angle = 30)

# Develop two-level forecast for validation period by combining  
# regression forecast and trailing MA forecast for residuals.
fst.2level <- train.lin.season.pred$mean + ma.trail.res.pred$mean
fst.2level

valid.df <- round(data.frame(valid.ts, train.lin.season.pred$mean, 
                             ma.trail.res.pred$mean, 
                             fst.2level ), 3)
names(valid.df) <- c("Exports", "Regression.Fst", 
                     "MA.Residuals.Fst", "Combined.Fst(MA1)"
                     )
valid.df



Acf(train.lin.season.pred$residuals, lag.max = 12, 
    main = "Autocorrelation for U.S Exports Training Residuals")
Acf(valid.ts - train.lin.season.pred$mean, lag.max = 12, 
    main = "Autocorrelation for U.S Exports Validation Residuals")

res.ar1 <- Arima(train.lin.season$residuals, order = c(5,0,0))
summary(res.ar1)

res.ar1.pred <- forecast(res.ar1, h = nValid, level = 0)
res.ar1.pred

Acf(res.ar1$residuals, lag.max = 12, 
    main = "Autocorrelation for U.S Exports Training Residuals of Residuals-AR(5)")

# Plot residuals and AR1 residuals forecast in training and validation partitions. 
plot(train.lin.season.res, 
     xlab = "Time", ylab = "Exports (in M$)", ylim = c(-65000, 85000), 
     bty = "l", xlim = c(2000, 2025.25), xaxt = "n",
     main = "Regression Residuals and AR(5) for Residuals", 
     col = "brown", lwd =2) 
axis(1, at = seq(1991, 2025, 1), labels = format(seq(1991, 2025, 1)))
lines(train.lin.season.res.valid, col = "brown", lwd = 2, lty = 2)
lines(res.ar1$fitted, col = "blue", lwd = 2, lty = 1)
lines(res.ar1.pred$mean, col = "blue", lwd = 2, lty = 2)
legend(2000,85000, legend = c("Regression Residuals, Training Partition", 
                              "Regression Residuals, Validation Partition",
                              "AR(5) Forecast, Training Partition", 
                              "AR(5) forecast, Validation Partition"), 
       col = c("brown", "brown", "blue", "blue"), 
       lty = c(1, 2, 1, 2), lwd =c(2, 2, 2, 2), bty = "n")


lines(c(2020, 2020), c(-60000, 14000))
lines(c(2024, 2024), c(-60000, 14000))
text(2010, 20000, "Training")
text(2022, 20000, "Validation")
text(2024.8, 20000, "Future")
arrows(2000, 20000, 2019.9, 20000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2020.1, 20000, 2023.9, 20000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2024.1, 20000, 2025.3, 20000, code = 3, length = 0.1,
       lwd = 1, angle = 30)


snd.2level <- train.lin.season.pred$mean + res.ar1.pred$mean
snd.2level

valid.df <- round(data.frame(valid.ts, train.lin.season.pred$mean, 
                             res.ar1.pred$mean, 
                             snd.2level ), 3)
names(valid.df) <- c("Exports", "Regression.Fst", 
                      "AR(5).Residuals.Fst", 
                     "Combined.Fst(AR5)")
valid.df


train.hw.ZZZ <- ets(train.ts, model = "ZZZ")
train.hw.ZZZ

# Use forecast() function to make predictions using this HW model with 
# validation period (nValid). 
# Show predictions in tabular format.
train.hw.ZZZ.pred <- forecast(train.hw.ZZZ, h = nValid, level = 0)
train.hw.ZZZ.pred


plot(exports.ts, 
     xlab = "Time", ylab = "U.S International Exports (in Million$)", 
     ylim = c(50000, 185000), bty = "l",
     xlim = c(2000, 2025.25), xaxt = "n",
     main = "HW Model with Automatic Selection Of Parameters", 
) 
axis(1, at = seq(2000, 2025, 1), labels = format(seq(2000, 2025, 1)))
lines(train.hw.ZZZ$fitted, col = "blue", lwd = 2, lty = 1)
lines(train.hw.ZZZ.pred$mean, col = "blue", lwd = 2, lty = 2)
legend(2000,185000, legend = c("U.S Exports for Time-Series", 
                               "HW Model for Training Data",
                               "HW Model Forecast for Validation Data"), 
       col = c("black", "blue" , "blue"), 
       lty = c(1, 1, 2), lwd =c(2, 2, 2), bty = "n")

# Plot on the chart vertical lines and horizontal arrows
# describing training, validation, and future prediction intervals.
lines(c(2020, 2020), c(0, 140000))
lines(c(2024, 2024), c(0, 140000))
text(2010, 140000, "Training")
text(2022, 145000, "Validation")
text(2024.8, 140000, "Future")
arrows(2000, 140000, 2019.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2020.1, 140000, 2023.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2024.1, 140000, 2025.3, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)


train.auto.arima <- auto.arima(train.ts)
summary(train.auto.arima)

# Apply forecast() function to make predictions for ts with 
# auto ARIMA model in validation set.  
train.auto.arima.pred <- forecast(train.auto.arima, h = nValid, level = 0)
train.auto.arima.pred

plot(exports.ts, 
     xlab = "Time", ylab = "U.S International Exports (in Million$)", 
     ylim = c(50000, 185000), bty = "l",
     xlim = c(2000, 2025.25), xaxt = "n",
     main = "Auto ARIMA Model", 
) 
axis(1, at = seq(2000, 2025, 1), labels = format(seq(2000, 2025, 1)))
lines(train.auto.arima$fitted, col = "blue", lwd = 2, lty = 1)
lines(train.auto.arima.pred$mean, col = "blue", lwd = 2, lty = 2)
legend(2000,185000, legend = c("U.S Exports for Time-Series", 
                               "Auto ARIMA Model for Training Data",
                               "Auto ARIMA Model Forecast for Validation Data"), 
       col = c("black", "blue" , "blue"), 
       lty = c(1, 1, 2), lwd =c(2, 2, 2), bty = "n")

# Plot on the chart vertical lines and horizontal arrows
# describing training, validation, and future prediction intervals.
lines(c(2020, 2020), c(0, 140000))
lines(c(2024, 2024), c(0, 140000))
text(2010, 140000, "Training")
text(2022, 145000, "Validation")
text(2024.8, 140000, "Future")
arrows(2000, 140000, 2019.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2020.1, 140000, 2023.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2024.1, 140000, 2025.3, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)

# Using Acf() function, create autocorrelation chart of auto ARIMA 
# model residuals.
Acf(train.auto.arima$residuals, lag.max = 12, 
    main = "Autocorrelations of Auto ARIMA Model Residuals")

round(accuracy(train.lin.season.pred$mean, valid.ts), 3)
round(accuracy(fst.2level, valid.ts), 3)
round(accuracy(snd.2level, valid.ts), 3)
round(accuracy(train.hw.ZZZ.pred$mean, valid.ts), 3)
round(accuracy(train.auto.arima.pred$mean, valid.ts), 3)

# training with entire dataset for future prediction
tot.trend.seas <- tslm(exports.ts ~ trend  + season)
summary(tot.trend.seas)

# Create regression forecast for future 12 periods.
tot.trend.seas.pred <- forecast(tot.trend.seas, h = 12, level = 0)
tot.trend.seas.pred

# Identify and display regression residuals for entire data set.
tot.trend.seas.res <- tot.trend.seas$residuals
tot.trend.seas.res

# Use trailing MA to forecast residuals for entire data set.
tot.ma.trail.res <- rollmean(tot.trend.seas.res, k = 6, align = "right")
tot.ma.trail.res

# Create forecast for trailing MA residuals for future 12 periods.
tot.ma.trail.res.pred <- forecast(tot.ma.trail.res, h = 12, level = 0)
tot.ma.trail.res.pred

# Develop 2-level forecast for future 12 periods by combining 
# regression forecast and trailing MA for residuals for future
# 12 periods.
tot.fst.2level <- tot.trend.seas.pred$mean + tot.ma.trail.res.pred$mean
tot.fst.2level

residual.ar5 <- Arima(tot.trend.seas.res, order = c(5,0,0))
residual.ar5.pred <- forecast(residual.ar5, h = 12, level = 0)

# Use summary() to identify parameters of AR(1) model.
summary(residual.ar5)

# Use Acf() function to identify autocorrelation for the residuals of residuals 
# and plot autocorrelation for different lags (up to maximum of 12).
Acf(residual.ar5$residuals, lag.max = 12, 
    main = "Autocorrelation for Residuals of Residuals for Entire Data Set")


# Identify forecast for the future 12 periods as sum of linear trend and 
# seasonal model and AR(1) model for residuals.
tot.snd.2level <- tot.trend.seas.pred$mean + residual.ar5.pred$mean
tot.snd.2level

HW.ZZZ <- ets(exports.ts, model = "ZZZ")
HW.ZZZ 

# Use forecast() function to make predictions using this HW model for
# 12 month into the future.
HW.ZZZ.pred <- forecast(HW.ZZZ, h = 12 , level = 0)
HW.ZZZ.pred


auto.arima <- auto.arima(exports.ts)
summary(auto.arima)

auto.arima.pred <- forecast(auto.arima, h = 12, level = 0)
auto.arima.pred

# Use Acf() function to create autocorrelation chart of auto ARIMA 
# model residuals.
Acf(auto.arima$residuals, lag.max = 12, 
    main = "Autocorrelations of Auto ARIMA Model Residuals")

future12.df <- round(data.frame(tot.trend.seas.pred$mean, tot.fst.2level, tot.snd.2level, 
                                HW.ZZZ.pred$mean, auto.arima.pred$mean), 3)
names(future12.df) <- c("Regression.Fst", "Regression.MA.Fst", "Regression.AR5.Fst","HW.Fst","Auto.ARIMA.Fst")
future12.df

round(accuracy(tot.trend.seas.pred$fitted, exports.ts), 3)
round(accuracy(tot.trend.seas.pred$fitted+tot.ma.trail.res, exports.ts), 3)
round(accuracy(tot.trend.seas.pred$fitted+residual.ar5$fitted, exports.ts), 3)
round(accuracy(HW.ZZZ.pred$fitted, exports.ts), 3)
round(accuracy(auto.arima.pred$fitted, exports.ts), 3)
round(accuracy((naive(exports.ts))$fitted, exports.ts), 3)
round(accuracy((snaive(exports.ts))$fitted, exports.ts), 3)


plot(exports.ts, 
     xlab = "Time", ylab = "U.S International Exports (in Million$)", 
     ylim = c(50000, 185000), bty = "l",
     xlim = c(2000, 2025.25), xaxt = "n",
     main = "Two-Level Forecast: Regression with Trend and Seasonlity + AR(5)
     for Residuals", 
) 
axis(1, at = seq(2000, 2025, 1), labels = format(seq(2000, 2025, 1)))
lines(tot.trend.seas.pred$fitted+residual.ar5$fitted, col = "blue", lwd = 2, lty = 1)
lines(tot.snd.2level, col = "blue", lwd = 2, lty = 2)
legend(2000,185000, legend = c("U.S Exports for Training and Validation", 
                               "Regression + AR(5) for Training and Valiadtion Periods",
                               "Regression + AR(5) Forecast for 12 Future Periods"), 
       col = c("black", "blue" , "blue"), 
       lty = c(1, 1, 2), lwd =c(2, 2, 2), bty = "n")

# Plot on the chart vertical lines and horizontal arrows
# describing training, validation, and future prediction intervals.
lines(c(2020, 2020), c(0, 140000))
lines(c(2024, 2024), c(0, 140000))
text(2010, 140000, "Training")
text(2022, 145000, "Validation")
text(2024.8, 140000, "Future")
arrows(2000, 140000, 2019.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2020.1, 140000, 2023.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2024.1, 140000, 2025.3, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)


plot(exports.ts, 
     xlab = "Time", ylab = "U.S International Exports (in Million$)", 
     ylim = c(50000, 185000), bty = "l",
     xlim = c(2000, 2025.25), xaxt = "n",
     main = "Holt-Winter's Automated Model for Entire Data Set and Forecast for Future 12 Periods", 
) 
axis(1, at = seq(2000, 2025, 1), labels = format(seq(2000, 2025, 1)))
lines(HW.ZZZ.pred$fitted, col = "blue", lwd = 2, lty = 1)
lines(HW.ZZZ.pred$mean, col = "blue", lwd = 2, lty = 2)
legend(2000,185000, legend = c("U.S Exports for Training and Validation", 
                               "HW Model for Training and Valiadtion Periods",
                               "HW Model Forecast for 12 Future Periods"), 
       col = c("black", "blue" , "blue"), 
       lty = c(1, 1, 2), lwd =c(2, 2, 2), bty = "n")

# Plot on the chart vertical lines and horizontal arrows
# describing training, validation, and future prediction intervals.
lines(c(2020, 2020), c(0, 140000))
lines(c(2024, 2024), c(0, 140000))
text(2010, 140000, "Training")
text(2022, 145000, "Validation")
text(2024.8, 140000, "Future")
arrows(2000, 140000, 2019.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2020.1, 140000, 2023.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2024.1, 140000, 2025.3, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)


plot(exports.ts, 
     xlab = "Time", ylab = "U.S International Exports (in Million$)", 
     ylim = c(50000, 185000), bty = "l",
     xlim = c(2000, 2025.25), xaxt = "n",
     main = "Auto ARIMA Model for Entire Dataset", 
) 
axis(1, at = seq(2000, 2025, 1), labels = format(seq(2000, 2025, 1)))
lines(auto.arima.pred$fitted, col = "blue", lwd = 2, lty = 1)
lines(auto.arima.pred$mean, col = "blue", lwd = 2, lty = 2)
legend(2000,185000, legend = c("U.S Exports for Training and Validation", 
                               "Auto ARIMA for Training and Valiadtion Periods",
                               "Auto ARIMA Forecast for 12 Future Periods"), 
       col = c("black", "blue" , "blue"), 
       lty = c(1, 1, 2), lwd =c(2, 2, 2), bty = "n")

# Plot on the chart vertical lines and horizontal arrows
# describing training, validation, and future prediction intervals.
lines(c(2020, 2020), c(0, 140000))
lines(c(2024, 2024), c(0, 140000))
text(2010, 140000, "Training")
text(2022, 145000, "Validation")
text(2024.8, 140000, "Future")
arrows(2000, 140000, 2019.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2020.1, 140000, 2023.9, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)
arrows(2024.1, 140000, 2025.3, 140000, code = 3, length = 0.1,
       lwd = 1, angle = 30)

train.ts
valid.ts
