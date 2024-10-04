# Mark all corresponding SNPs between reference sequences in the AF plot
library(ggplot2)
library(dplyr)  # Optional
library(readr)  # Optional
library(writexl)  


dataA <- mumerSNP
dataB <- numt6

# Merge two data frames to find matching rows
merged_data <- merge(dataA, dataB, by = "npos", suffixes = c("_A", "_B"))


# Add a color column to dataB and set colors based on conditions
dataB$color <- ifelse(dataB$npos %in% merged_data$npos, "black", "gray88")


###### Scatter plot creation
# Create a scatter plot, using the POS column from table B as the x-axis, total column as the y-axis, and colors based on filtering results
p <- ggplot(dataB, aes(x = npos, y = total)) +
  geom_point(aes(color = color), size = 2) +
  scale_color_identity() +  # Use colors from the color column
  theme_minimal()

# Control the step size of the x-axis, starting from 0
p1 <- scale_x_continuous(breaks = c(10, 60, 110, 160, 210, 260, 310, 360, 410, 460, 510, 560, 610), expand = c(0, 0))

# Set the y-axis range and display the y-axis data as percentages
p2 <- scale_y_continuous(limits = c(0, 1), expand = c(0, 0), labels = scales::percent_format())

# Remove background and thicken the border
p3 <- theme_bw() + theme(panel.grid = element_blank(), panel.border = element_rect(fill = NA, color = "black", size = 1.25, linetype = "solid"))

p + p1 + p2 + p3


#### Histogram of SNP count statistics
# Filter rows where the color column is "black"
black_data <- subset(dataB, color == "black")
nrow(black_data)

# Group the total column by intervals of 0.05
black_data$total_group <- cut(merged_data$total, breaks = seq(0, 1, by = 0.05), include.lowest = TRUE)
# Count how many rows are in each group
total_counts <- table(black_data$total_group)
# Filter rows where the sup or pre column is not 0
#black_data1 <- subset(black_data, sup != 0)
# Create a histogram
p <- ggplot(black_data, aes(y = total)) +
  geom_histogram(binwidth = 0.05, fill = "black", color = "white", boundary = 0) + theme_minimal()
p2 <- scale_y_continuous(limits = c(0, 1), expand = c(0, 0), labels = scales::percent_format())
p1 <- scale_x_continuous(limits = c(0, 400), expand = c(0, 0))
p + p1 + p2 + p3