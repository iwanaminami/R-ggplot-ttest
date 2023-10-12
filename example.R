rm( list=ls(all=TRUE) )

library(tidyr)

data_test <- data.frame(
    id = paste0("patient_", 1:100),
    y_norm = c(rnorm(20*3, mean = 0, sd = 1), rnorm(20*2, mean = 3, sd = 1)),
    y_lnorm = c(rlnorm(20*3, meanlog = 0, sdlog = 1), rlnorm(20*2, meanlog = 1.5, sdlog = 1)),
    group = rep(paste0("group_", 1:5), each = 20),
    subcategory = sample(LETTERS[1:2], 100, replace = TRUE)
  )

data_plot <- pivot_longer(data = data_test, cols = -c(id, group, subcategory))


## plot examples

source("function.R")

## default plot
plt <- plot_jitter_ttest(data = data_plot, col_values = "value", col_name = "name", label_name = "y_lnorm",
                         category = "group")$plot

ggsave(plt, filename = "outputs/00_default_plot.png", w = 8, h = 6)

## plot all p-values
plt <- plot_jitter_ttest(data = data_plot,
                         col_values = "value", col_name = "name", label_name = "y_lnorm",
                         category = "group",
                         ttest_remove_bool = FALSE)$plot

ggsave(plt, filename = "outputs/01_plot_all_pvalues.png", w = 8, h = 6)

## change plot title and axis titles
plt <- plot_jitter_ttest(data = data_plot, col_values = "value", col_name = "name", label_name = "y_lnorm",
                         category = "group",
                         plot_title = "Another title", x_title = "Group", y_title = "Value")$plot

ggsave(plt, filename = "outputs/02_plot_title_axis_title.png", w = 8, h = 6)

## change order of categories (x axis)
plt <- plot_jitter_ttest(data = data_plot, col_values = "value", col_name = "name", label_name = "y_lnorm",
                         category = "group",
                         levels_manual = c("group_3", "group_2", "group_4", "group_5", "group_1"))$plot

ggsave(plt, filename = "outputs/03_order_categories.png", w = 8, h = 6)

## hide t-test
plt <- plot_jitter_ttest(data = data_plot, col_values = "value", col_name = "name", label_name = "y_lnorm",
                         category = "group",
                         ttest_bool = FALSE)$plot

ggsave(plt, filename = "outputs/04_hide_ttest.png", w = 8, h = 6)

## use subgroup
plt <- plot_jitter_ttest(data = data_plot, col_values = "value", col_name = "name", label_name = "y_lnorm",
                         category = "group",
                         subset_categories = "subcategory", subset_items = "B")$plot

ggsave(plt, filename = "outputs/05_use_subgroup.png", w = 8, h = 6)

## change plot options with ggplot
plt <- plot_jitter_ttest(data = data_plot, col_values = "value", col_name = "name", label_name = "y_lnorm",
                         category = "group")$plot

plt <- plt +
  xlab("Updated x title") +
  theme(axis.title = element_text(color = "red"))

ggsave(plt, filename = "outputs/06_plot_options.png", w = 8, h = 6)

## get t-test result
result <- plot_jitter_ttest(data = data_plot, col_values = "value", col_name = "name", label_name = "y_lnorm",
                            category = "group")$ttest

print(result)
