## demo run through workflow with fish

rm(list = ls())

# library(charisma)

in_dir_f <- file.path("~", "Dropbox", "Research", "UCLA", "Alfaro-Lab", "labrid_colors2", "segmented_images", "female_segmented")
in_dir_m <- file.path("~", "Dropbox", "Research", "UCLA", "Alfaro-Lab", "labrid_colors2", "segmented_images", "male_segmented")
out_dir <- "diagnostic_plots"

if (!dir.exists(out_dir))
  dir.create(out_dir)

run_charisma <- function(img = "Anampses_Anampses caeruleopunctatus_1511191576.png", out_dir = out_dir) {
  # fname <- paste0(tools::file_path_sans_ext(basename(img)), ".jpeg")
  fname <- paste0(tools::file_path_sans_ext(basename(img)), ".pdf")
  #fish_c <- charisma(img, verbose = FALSE, plot = FALSE)
  fish_c <- charisma(img, verbose = TRUE, plot = TRUE)
  # assuming appropriate output dirs
  saveRDS(fish_c, file.path(out_dir, paste0("charisma_", basename(img), ".RDS")))

  # then, save out all the relevant data to csvs for analysis later
  write.csv(fish_c$pavo_adj_stats, file.path(out_dir, paste0("charisma_", basename(img), "_pavo.csv")), row.names = FALSE)
  # jpeg(file.path(out_dir, fname), width = 1920, height = 300, units = "px")
  # pdf(file.path(out_dir, fname), width = 7, height = 3)
  plot_diagnostics(fish_c)
  # dev.off()
}


# run_charisma()

if (!dir.exists(file.path(out_dir, "female_segmented")))
  dir.create(file.path(out_dir, "female_segmented"))

female_files <- list.files(in_dir_f, pattern = ".png", all.files = TRUE, full.names = TRUE)

for (female in female_files) {
  run_charisma(img = female, out_dir = file.path(out_dir, "female_segmented"))
}

if (!dir.exists(file.path(out_dir, "male_segmented")))
  dir.create(file.path(out_dir, "male_segmented"))

male_files <- list.files(in_dir_m, pattern = ".png", all.files = TRUE, full.names = TRUE)

for (male in male_files) {
  run_charisma(img = male, out_dir = file.path(out_dir, "male_segmented"))
}

#### later on
all_pavo_data.df <- dir_with_all_csvs %>%
  list.files(path = out_dir,
             pattern = "*.csv",
             full.names = TRUE) %>%
  read_csv(show_col_types = FALSE) %>%
  bind_rows()
