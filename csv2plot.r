
###########
# Imports #
###########

library(plyr)
library(plotrix)
library(ggplot2)
library(reshape2)

#######################
# Auxiliary functions #
#######################

geom_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}

# geometric mean
pos_mean = function(x, na.rm=TRUE){
  if (-1 %in% x) {
    return(0.1);
  }
  mean(x)
  #  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}

# standard mean
time_mean = function(x, na.rm=TRUE){
  if (999.999 %in% x) {
    return(999.999);
  }
  if (800.000 %in% x) {
    return(700.000);
  }
  mean(x)
}

# standard var
time_var = function(x, na.rm=TRUE){
  if (999.999 %in% x) {
    return(0.000);
  }
  if (800.000 %in% x) {
    return(0.000);
  }
  var(x) # add a small bit extra for plots, otherwise R complains
}


MYBLUE  = rgb(8/255, 81/255, 156/255, 1)
MYRED   = rgb(251/255, 106/255, 74/255, 1)
MYGREEN = rgb(161/255, 217/255, 155/255, 1)

###############
# Import data #
###############

results = read.csv("results.csv")


results_ok = subset(results, errmsg != "FAIL")
#results_ok = subset(results, errmsg == "OK")


####################
# Postprocess data #
####################


# take average time, states, etc.
results_mean = ddply(results_ok, .(model,alg,workers,buchi,rabinpairorder), summarize, 
                              time_v = time_var(time),
                              time = time_mean(time), 
                              ltl = mean(ltl), 
                              ustates = pos_mean(ustates), 
                              utrans = pos_mean(utrans), 
                              tstates = pos_mean(tstates), 
                              ttrans = pos_mean(ttrans), 
                              selfloop = pos_mean(selfloop), 
                              claimdead = pos_mean(claimdead), 
                              claimfound = pos_mean(claimfound), 
                              claimsuccess = pos_mean(claimsuccess), 
                              cumstack = pos_mean(cumstack), 
                              rabinpairs = mean(rabinpairs), 
                              ftrans = mean(ftrans), 
                              autsize = mean(autsize))


results_filter = results_mean
#results_filter = subset(results_mean, ustates > 1E5)
results_filter = subset(results_mean, time > 1.0 & utrans > 1)


results_ltl3hoa    = subset(results_filter, buchi == "ltl3hoa" & rabinpairorder == "seq")
results_ltl3dra    = subset(results_filter, buchi == "ltl3dra" & rabinpairorder == "seq")
results_rabinizer3 = subset(results_filter, buchi == "rabinizer3" & rabinpairorder == "seq")
results_tgbarabin  = subset(results_filter, buchi == "tgbarabin" & rabinpairorder == "seq")
results_tgba       = subset(results_filter, buchi == "tgba")

results_ltl3hoa_par    = subset(results_filter, buchi == "ltl3hoa" & rabinpairorder == "par")
results_ltl3dra_par    = subset(results_filter, buchi == "ltl3dra" & rabinpairorder == "par")
results_rabinizer3_par = subset(results_filter, buchi == "rabinizer3" & rabinpairorder == "par")
results_tgbarabin_par  = subset(results_filter, buchi == "tgbarabin" & rabinpairorder == "par")


##################
# Plot functions #
##################


f_plot = function(data, name) {
  
  x = data$time
  y = data$autsize
  
  options(scipen=5)
  pdf(sprintf("img/%s.pdf", name), width=6, height=5)
  
  plot(x,y,
       xlab=sprintf("%s", "time"),
       ylab=sprintf("%s", "F trans"),
       log="x", 
       col = ifelse(data$ltl > 1, MYRED, MYBLUE),
       pch = ifelse(data$ltl > 1, 4, 1 ))
  
  abline(v=800, col = "purple", lwd=1)
  abline(v=1000, col = "red", lwd=1)
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  
  dev.off()
}

# compare the time
f_compare_time = function(data_x, data_y, name_x, name_y, print_text) {
  
  comb_model = merge(data_x, data_y, by="model", all = FALSE)
  x_ = comb_model$time.x
  y_ = comb_model$time.y

  x_v = comb_model$time_v.x
  y_v = comb_model$time_v.y
  
  options(scipen=5)
  
  if (print_text) {
    pdf(sprintf("img/compare_time_text_%s_%s.pdf", name_x, name_y), width=6, height=5)
  }
  else {
    pdf(sprintf("img/compare_time_%s_%s.pdf", name_x, name_y), width=6, height=5)
  }
  
  plot(x=x_,
       y=y_,
       ylim=c(1,1000),
       xlim=c(1,200),
       xlab=sprintf("Time %s", name_x),
       ylab=sprintf("Time %s", name_y),
       log="xy", 
       col = ifelse(comb_model$ltl.x > 1, MYRED, MYBLUE ),
       pch = ifelse(comb_model$ltl.x > 1, 4, 1 ),
       cex=1.5,
       lwd=1.5)

  #arrows(x_, y_-y_v, x_, y_+y_v, length=0.05, angle=90, code=3)
  #arrows(x_-x_v, y_, x_+x_v, y_, length=0.05, angle=90, code=3)

  if (print_text) {
    text(x_, y_, labels=comb_model$model, cex= 0.7, pos=1)
  }
  
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  abline(h=700, col = "purple", lwd=1.5, lty=5)
  abline(h=1000, col = "forestgreen", lwd=1.5, lty=6)
  abline(v=700, col = "purple", lwd=1.5, lty=5)
  abline(v=1000, col = "forestgreen", lwd=1.5, lty=6)
  
  abline(a=0, b=1, col = "black", lwd=1.5)
  
  dev.off()
  
}

# compare the number of transitions
f_compare_utrans = function(data_x, data_y, name_x, name_y, print_text) {
  
  comb_model = merge(data_x, data_y, by="model", all = FALSE)
  x = comb_model$utrans.x
  y = comb_model$utrans.y
  
  options(scipen=5)
  
  if (print_text) {
    pdf(sprintf("img/compare_utrans_text_%s_%s.pdf", name_x, name_y), width=6, height=5)
  }
  else {
    pdf(sprintf("img/compare_utrans_%s_%s.pdf", name_x, name_y), width=6, height=5)
  }
  
  plot(x,y,
       xlab=sprintf("Transitions %s", name_x),
       ylab=sprintf("Transitions %s", name_y),
       log="xy", 
       col = ifelse(comb_model$ltl.x > 1, MYRED, MYBLUE ),
       pch = ifelse(comb_model$ltl.x > 1, 4, 1 ))
  
  if (print_text) {
    text(x, y, labels=comb_model$model, cex= 0.7, pos=1)
  }
  
  abline(a=0, b=1, col = "black", lwd=1)
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  
  dev.off()
  
}


# check if the LTL results are the same
f_compare_ltl = function(data_x, data_y, name_x, name_y, print_text) {
  
  comb_model = merge(data_x, data_y, by="model", all = FALSE)
  x = comb_model$time.x
  y = comb_model$time.y
  
  options(scipen=5)
  
  if (print_text) {
    pdf(sprintf("img/compare_ltl_text_%s_%s.pdf", name_x, name_y), width=6, height=5)
  }
  else {
    pdf(sprintf("img/compare_ltl_%s_%s.pdf", name_x, name_y), width=6, height=5)
  }
  
  plot(x,y,
       #xlim=c(7.5,8),
       #ylim=c(10,20),
       xlab=sprintf("Time %s", name_x),
       ylab=sprintf("Time %s", name_y),
       log="xy", 
       col = ifelse((comb_model$ltl.x > 1 & comb_model$ltl.y <= 1) | (comb_model$ltl.x <= 1 & comb_model$ltl.y > 1), MYRED, MYBLUE ),
       pch = ifelse((comb_model$ltl.x > 1 & comb_model$ltl.y <= 1) | (comb_model$ltl.x <= 1 & comb_model$ltl.y > 1), 4, 1 ))
  
  if (print_text) {
    text(x, y, labels=comb_model$model, cex= 0.7, pos=1)
  }
  
  abline(h=700, col = "purple", lwd=1)
  abline(h=1000, col = "red", lwd=1)
  abline(v=700, col = "purple", lwd=1)
  abline(v=1000, col = "red", lwd=1)
  
  abline(a=0, b=1, col = "black", lwd=1)
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  
  dev.off()
  
}

# calls multiple plot functions
f_compare = function(data_x, data_y, name_x, name_y) {
  f_compare_time(data_x, data_y, name_x, name_y, TRUE)
  f_compare_time(data_x, data_y, name_x, name_y, FALSE)
  f_compare_utrans(data_x, data_y, name_x, name_y, TRUE)
  f_compare_utrans(data_x, data_y, name_x, name_y, FALSE)
  f_compare_ltl(data_x, data_y, name_x, name_y, TRUE)
  f_compare_ltl(data_x, data_y, name_x, name_y, FALSE)
}

##############
# Make plots #
##############


f_plot(results_ltl3hoa,    "plot_ltl3hoa")
f_plot(results_ltl3dra,    "plot_ltl3dra")
f_plot(results_rabinizer3, "plot_rabinizer3")
f_plot(results_tgba,       "plot_tgba")
f_plot(results_tgbarabin,  "plot_tgbarabin")


f_compare(results_tgba, results_ltl3hoa,    "TGBA", "LTL3HOA")
f_compare(results_tgba, results_ltl3dra,    "TGBA", "LTL3DRA")
f_compare(results_tgba, results_rabinizer3, "TGBA", "Rabinizer3")
f_compare(results_tgba, results_tgbarabin,  "TGBA", "TGBA-TGRA")


f_compare(results_ltl3hoa,    results_ltl3hoa_par,    "LTL3HOA-seq", "LTL3HOA-par")
f_compare(results_ltl3dra,    results_ltl3dra_par,    "LTL3DRA-seq", "LTL3DRA-par")
f_compare(results_rabinizer3, results_rabinizer3_par, "Rabinizer3-seq", "Rabinizer3-par")


## print a legend

options(scipen=5)
pdf("img/legend.pdf", width=12, height=5)


plot.new()

MYBLUE  = rgb(8/255, 81/255, 156/255, 1)
MYRED   = rgb(251/255, 106/255, 74/255, 1)
MYGREEN = rgb(161/255, 217/255, 155/255, 1)

legend(x = "top",inset = 0,
         pch=c(4,1,-1,-1,-1), 
         col=c(MYRED, MYBLUE, "purple", "forestgreen", "black"), 
         c("Counterexample", "No counterexample", "Memory limit", "Time limit", "x = y"), 
         bty="0",
         lwd=c(1.5,1.5,1.5,1.5,1.5),
         lty=c(0,0,5,6,1),
         bg="white",
         horiz=TRUE)


dev.off();



##################################################
# Make table, make sure to only use "OK" results #
##################################################



noce   = subset(results_tgba, ltl == -1)
ce = subset(results_tgba, ltl > -1)


comb_all_1 = merge(results_tgba, results_tgbarabin, by="model", all = FALSE)
comb_all_2 = merge(results_ltl3hoa, results_ltl3dra, by="model", all = FALSE)
comb_all_3 = merge(comb_all_2, results_rabinizer3, by="model", all = FALSE)
comb_all   = merge(comb_all_1, comb_all_3, by="model", all = FALSE)


print("averages:")
sprintf("{\tt %.2f (%.2f)} & {\tt %.2f (%.2f)} & {\tt %.2f (%.2f)} & {\tt %.2f (%.2f)} & {\tt %.2f}",
        geom_mean(comb_all$time.x.y), # ltl3hoa
        geom_mean(comb_all$time.x.y)/geom_mean(comb_all$time.x.x),
        geom_mean(comb_all$time.y.y), # ltl3dra
        geom_mean(comb_all$time.y.y)/geom_mean(comb_all$time.x.x),
        geom_mean(comb_all$time),     # rabinizer3
        geom_mean(comb_all$time)/geom_mean(comb_all$time.x.x),
        geom_mean(comb_all$time.y.x), # tgbarabin
        geom_mean(comb_all$time.y.x)/geom_mean(comb_all$time.x.x),
        geom_mean(comb_all$time.x.x)  # tgba
        )



print("aut sizes:")
sprintf("{\tt %.2f} & {\tt %.2f} & {\tt %.2f} & {\tt %.2f} & {\tt %.2f}",
        geom_mean(comb_all$autsize.x.y), # ltl3hoa
        geom_mean(comb_all$autsize.y.y), # ltl3dra
        geom_mean(comb_all$autsize),     # rabinizer3
        geom_mean(comb_all$autsize.y.x), # tgbarabin
        geom_mean(comb_all$autsize.x.x)  # tgba
)

print("ustates:")
sprintf("{\tt %.2f} & {\tt %.2f} & {\tt %.2f} & {\tt %.2f} & {\tt %.2f}",
        geom_mean(comb_all$ustates.x.y), # ltl3hoa
        geom_mean(comb_all$ustates.y.y), # ltl3dra
        geom_mean(comb_all$ustates),     # rabinizer3
        geom_mean(comb_all$ustates.y.x), # tgbarabin
        geom_mean(comb_all$ustates.x.x)  # tgba
)












