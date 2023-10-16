library(ggplot2)
library(ggprism)
library(dplyr)


plot_jitter_ttest <- function(data, col_values, col_name, label_name,
                              category, levels_manual = NULL,
                              subset_categories = NULL, subset_items = NULL,
                              log_bool = TRUE,
                              ttest_bool = TRUE,
                              ttest_alternative = "two.sided",
                              ttest_adjust_method = "bonferroni",
                              ttest_remove_bool = TRUE,
                              ttest_sig = 0.05,
                              ttest_y_scale = 0.1,
                              outlier_bool = FALSE,
                              plot_title = "Awesome title",
                              x_title = "x title", y_title = "y title", ...) {
  
  ## output
  out <- list()
  
  ## data preparation
  data_temp <- data
  
  if (!is.null(subset_categories) & !is.null(subset_items)) {
    if (length(subset_categories) != length(subset_items)) {
      stop("The lengths of subset_categories and subset_items must be equal!")
    }
    for (i in subset_categories) {
      if (!(i %in% colnames(data))) {
        stop("subset_categories not in data")
      }
    }
    
    for (i in 1:length(subset_categories)) {
      data_temp <- data_temp[which(data_temp[, subset_categories[i]] == subset_items[i]),]
    }
    # print(data_temp)
  }
  
  # print(col_name)
  # print(label_name)
  
  data_temp <- data_temp[which(data_temp[, col_name] == label_name), ][, c(category, col_values)]
  colnames(data_temp) <- c("x", "y")
  if (!is.null(levels_manual)) {
    data_temp$x <- factor(data_temp$x, levels = levels_manual)
  }
  
  # print(data_temp)
  
  # jitter plot and box plot
  plt <- ggplot()
  
  if (outlier_bool) {
    coef_boxplot <- Inf
  }else {
    coef_boxplot <- 1.5
  }
  
  if (log_bool) {
    plt <- plt +
      geom_boxplot(data = data_temp, aes(x = x, y = log(y)), outlier.shape = NA, width = 0.5, coef = coef_boxplot) +
      geom_jitter(data = data_temp, aes(x = x, y = log(y)), height = 0, width = 0.2)
  }else {
    plt <- plt +
      geom_boxplot(data = data_temp, aes(x = x, y = y), outlier.shape = NA, width = 0.5, coef = coef_boxplot) +
      geom_jitter(data = data_temp, aes(x = x, y = y), height = 0, width = 0.5)
  }
  
  plt <- plt + xlab(x_title) + ylab(y_title) +
    labs(title = plot_title) +
    theme_classic() + 
    theme(plot.title = element_text(hjust = 0.5),
          axis.text = element_text(color = "black"))
  
  
  ## t-test
  if (ttest_bool) {
    levels_temp <- unique(data_temp$x)
    if (!is.null(levels_manual)) {
      levels_temp <- levels_manual
    }
    
    # print(data_temp)
    
    res_ttest <- data.frame()
    
    i_ttest <- 0
    for (i in 1:(length(levels_temp) - 1)) {
      for (j in (i + 1):length(levels_temp)) {
        
        # print(i_ttest)
        
        if (log_bool) {
          group_a <- log(subset(data_temp, x == levels_temp[i])$y)
          group_b <- log(subset(data_temp, x == levels_temp[j])$y)
        }else {
          group_a <- subset(data_temp, x == levels_temp[i])$y
          group_b <- subset(data_temp, x == levels_temp[j])$y
        }
        
        
        # print(group_a)
        # print(group_b)
        res_ttest <- rbind(res_ttest,
                           data.frame(group1 = levels_temp[i], group2 = levels_temp[j],
                                      label = t.test(x = group_a, y = group_b,
                                                     alternative = ttest_alternative)$p.value))
        
        i_ttest <- i_ttest + 1
      }
    }
    
    # print(res_ttest$label)
    # print(nrow(res_ttest))
    
    # adjust p-values
    res_ttest$label <- p.adjust(res_ttest$label, method = ttest_adjust_method)
    
    # remove p-values less than ttest_sig or not for plot
    if (ttest_remove_bool) {
      df_ttest <- subset(res_ttest, label < ttest_sig)
    }else {
      df_ttest <- res_ttest
    }
    
    # define y position of plot of t-test results
    if (log_bool) {
      ydiff_ttest <- max(log(data_temp$y)) - min(log(data_temp$y))
      ymin_ttest <- max(log(data_temp$y)) + ttest_y_scale*ydiff_ttest
    }else {
      ydiff_ttest <- max(data_temp$y) - min(data_temp$y)
      ymin_ttest <- max(data_temp$y) + ttest_y_scale*ydiff_ttest
    }
    
    if(nrow(df_ttest) != 0) {
      df_ttest$y.position <- ymin_ttest + (0:(nrow(df_ttest) - 1))*ttest_y_scale*ydiff_ttest
      
      # modify significant digits of p-values for plot
      df_ttest <- mutate(df_ttest,
                         label = ifelse(df_ttest$label < 1, formatC(df_ttest$label, digits = 3), formatC(df_ttest$label, digits = 2, format = "f")))
      
      # add p-values to plot
      plt <- plt +
        add_pvalue(df_ttest,
                   xmin = "group1",
                   xmax = "group2",
                   label = "p = {label}",
                   y.position = "y.position",
                   tip.length = 0) 
      
    }
    
    out$ttest <- res_ttest
  }
  
  
  # print(plt)
  
  
  out$plot <- plt
  
  return(out)
}