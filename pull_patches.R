## Shawn T. Schwartz, 2022
## <stschwartz@stanford.edu>
## color code patches from HSV values using charisma (beta) 
## [pull_patches.R]

rm(list = ls())

library(tidyverse)

##################################################################
##                          Male Birds                          ##
##################################################################
all_patches.male <- file.path("~", "Desktop", "all_male_patches_ordered.csv") %>%
  read_csv()

all_patches.male_transform <- all_patches.male %>%
  pivot_longer(cols = -species,
               names_to = c("patch", "col_dim"),
               names_sep = "_",
               values_to = "col_val") %>%
  pivot_wider(id_cols = c(species, patch),
              names_from = col_dim,
              values_from = col_val)

male_color_calls <- rep(NA, nrow(all_patches.male_transform))

for(i_male in 1:nrow(all_patches.male_transform)) {
  if(i_male %% 100 == 0)
    cat(paste0(i_male, "/", nrow(all_patches.male_transform), "\n"))

  male_color_calls[i_male] <- charisma::parse_color(all_patches.male_transform[i_male,],
                                                    hsv = TRUE)
}

all_patches.male_transform.combo <- all_patches.male_transform %>%
  cbind(color = male_color_calls) %>%
  as.data.frame()

all_patches.male_transform.combo %>%
  write.csv("all_patches_male_LONG.csv",
            row.names = FALSE)

all_patches.male_transform.combo %>%
  mutate(h = as.character(h),
         s = as.character(s),
         v = as.character(v)) %>%
  pivot_longer(cols = c("h", "s", "v", "color"),
               names_to = "color_space",
               values_to = "color_value") %>%
  rowwise() %>%
  mutate(combo_patch_color = paste0(patch, "_", color_space)) %>%
  ungroup() %>%
  select(species,
         combo_patch_color,
         color_value) %>%
  pivot_wider(id_cols = "species",
              names_from = "combo_patch_color",
              values_from = "color_value") %>%
  write.csv("all_patches_male_WIDE.csv",
            row.names = FALSE)

##################################################################
##                         Female Birds                         ##
##################################################################
all_patches.female <- file.path("~", "Desktop", "all_female_patches_ordered.csv") %>%
  read_csv()

all_patches.female_transform <- all_patches.female %>%
  pivot_longer(cols = -species,
               names_to = c("patch", "col_dim"),
               names_sep = "_",
               values_to = "col_val") %>%
  pivot_wider(id_cols = c(species, patch),
              names_from = col_dim,
              values_from = col_val)

female_color_calls <- rep(NA, nrow(all_patches.female_transform))

for(i_female in 1:nrow(all_patches.female_transform)) {
  if(i_female %% 100 == 0)
    cat(paste0(i_female, "/", nrow(all_patches.female_transform), "\n"))

  female_color_calls[i_female] <- charisma::parse_color(all_patches.female_transform[i_female,],
                                                    hsv = TRUE)
}

all_patches.female_transform.combo <- all_patches.female_transform %>%
  cbind(color = female_color_calls) %>%
  as.data.frame()

all_patches.female_transform.combo %>%
  write.csv("all_patches_female_LONG.csv",
            row.names = FALSE)

all_patches.female_transform.combo %>%
  mutate(h = as.character(h),
         s = as.character(s),
         v = as.character(v)) %>%
  pivot_longer(cols = c("h", "s", "v", "color"),
               names_to = "color_space",
               values_to = "color_value") %>%
  rowwise() %>%
  mutate(combo_patch_color = paste0(patch, "_", color_space)) %>%
  ungroup() %>%
  select(species,
         combo_patch_color,
         color_value) %>%
  pivot_wider(id_cols = "species",
              names_from = "combo_patch_color",
              values_from = "color_value") %>%
  write.csv("all_patches_female_WIDE.csv",
            row.names = FALSE)

#################################################################
##                    Summarize Color Calls                    ##
#################################################################
male_species <- all_patches.male_transform.combo %>%
  pull(species) %>%
  unique()

male_color_uniques <- list()

for(i_male_species in 1:length(male_species)) {
  male_color_uniques[[i_male_species]] <- all_patches.male_transform.combo %>%
    filter(species == male_species[i_male_species]) %>%
    pull(color) %>%
    unique()
}

male_color_summaries <- list()

for(i_male_unique_calls in 1:length(male_color_uniques)) {
  male_color_summaries[[i_male_unique_calls]] <- charisma::summarise_colors(male_color_uniques[[i_male_unique_calls]])
}

names(male_color_summaries) <- male_species

male_color_summaries

male_colors_df <- do.call(rbind.data.frame, male_color_summaries) %>%
  mutate(species = rownames(.)) %>%
  mutate(sex = "male")

male_colors_df



female_species <- all_patches.female_transform.combo %>%
  pull(species) %>%
  unique()

female_color_uniques <- list()

for(i_female_species in 1:length(female_species)) {
 female_color_uniques[[i_female_species]] <- all_patches.female_transform.combo %>%
    filter(species == female_species[i_female_species]) %>%
    pull(color) %>%
    unique()
}

female_color_summaries <- list()

for(i_female_unique_calls in 1:length(female_color_uniques)) {
  female_color_summaries[[i_female_unique_calls]] <- charisma::summarise_colors(female_color_uniques[[i_female_unique_calls]])
}

names(female_color_summaries) <- female_species

female_color_summaries

female_colors_df <- do.call(rbind.data.frame, female_color_summaries) %>%
  mutate(species = rownames(.)) %>%
  mutate(sex = "female")

female_colors_df

# merge
combined_final_summaries <- rbind(male_colors_df, female_colors_df)

combined_final_summaries %>%
  View

combined_final_summaries %>%
  write.csv("male_female_color_k_summary.csv",
            row.names = FALSE)

##################################################################
##                    Color Map Used Summary                    ##
##################################################################
write.csv(charisma::color.map,
          "charisma_color_map_used.csv",
          row.names = FALSE)
