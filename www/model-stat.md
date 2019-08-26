---
title: "Lethal concentration estimator"
author: "Joel Putnam"
date: "May 17, 2017"
output: html_document
css: www/custom.css
---

# Model definitions 

The log-logistic models are the most commonly used models.
 
### LL.2 two paramater log-logistic ($ED_{50}$/$LD_{50}$/$LC_{50}$ as parameter) with lower limit at 0 and upper limit at 1 

$$ f(x) =  \frac{1}{1+(\frac{x}{a})^b} $$

### LL.3 three parameter log-logistic ($ED_{50}$/$LD_{50}$/$LC_{50}$ as parameter) with lower limit at 0

$$ f(x) = 0 + \frac{d - 0}{1+(\frac{x}{a})^b} $$

### LL.3u three parameter log-logistic ($ED_{50}$/$LD_{50}$/$LC_{50}$ as parameter) with upper limit at 1

$$ f(x) = c + \frac{1-c}{1+(\frac{x}{a})^b} $$

### LL.4 four paramater log-logistic ($ED_{50}$/$LD_{50}$/$LC_{50}$ as parameter)

$$ f(x) = c + \frac{d-c}{1+(\frac{x}{a})^b} $$


### LL.5 Generalized log-logistic ($ED_{50}$/$LD_{50}$/$LC_{50}$ as parameter)

$$ f(x) = c + \frac{d-c}{[1+(\frac{x}{a})^b]^f} $$

### LN.2 - two parameter log-normal

$$ f(x) = \Phi(\log(\frac{x}{a})^b) $$

### LN.3 - three parameter log-normal

$$ f(x) = 0 + (d - 0) * \Phi(\log(\frac{x}{a})^b) $$

### LN.3u - three parameter log-normal with upper limit at 1

$$ f(x) = c + (1 - c) * \Phi(\log(\frac{x}{a})^b) $$

### LN.4 - four parameter log-normal

$$ f(x) = c + (d-c) * \Phi(\log(\frac{x}{a})^b) $$

### W1.2 two paramater Weibull model

$$ f(x) = \frac{1}{e^{(\frac{x}{a})^b}} $$


### W1.3 three paramater Weibull model

$$ f(x) = 0 + \frac{d - 0}{e^{(\frac{x}{a})^b}} $$


### W1.3u three paramater Weibull model with upper limit of 1

$$ f(x) = 0 + \frac{1 - 0}{e^{(\frac{x}{a})^b}} $$


### W1.4 four paramater Weibull model with upper limit of 1

$$ f(x) = c + \frac{d - c}{e^{(\frac{x}{a})^b}} $$


### W2.2 two paramater Weibull model

$$ f(x) = 1 - \frac{1}{e^{(\frac{x}{a})^b}} $$ 

### W2.3 three paramater Weibull model

$$ f(x) = 0 + (d-0 )(1 - \frac{1}{e^{(\frac{x}{a})^b}}) $$


### W2.3u three paramater Weibull model with upper limit of 1

$$ f(x) = c + (1-c)(1 - \frac{1}{e^{(\frac{x}{a})^b}})  $$


### W2.4 four paramater Weibull model with upper limit of 1

$$ f(x) = c + (d-c)(\frac{d - c}{e^{(\frac{x}{a})^b}}) $$



##### Key:

  x - concentration (in ppb)
  
  a - the point of inflection (i.e. the point on the S-shaped curve halfway between c and d)

  b - Hill's slope of the curve (i.e. this is related to the steepness of the curve at point a)

  c - the lower horizontal asymptote

  d - the upper horizontal asymptote

  e - exponential function as in e<sup>b</sup>
  
  f - asymmetry factor (When f=1, the curve around the inflection point is symmetrical; therefore, the equation would have four parameters, as
       seen in LL.4)
  
  &Phi; - the cumulative distribution function of the normal distribution
  
  

