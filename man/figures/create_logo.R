# Script to create the charisma hex logo

library(hexSticker)
library(grid)
library(showtext)
library(rsvg)
library(sysfonts)

font_add(
  family = "impact",
  regular = "~/Library/Fonts/ChelseaMarket-Regular.ttf"
)

icon_svg <- "man/figures/charisma-rainbow-full.svg"

showtext_auto()

s <- sticker(
  icon_svg,
  package = "charisma",
  p_size = 45 * 2.5,
  p_color = "#FFFFFF",
  p_family = "impact",
  p_fontface = "bold",
  p_x = 1,
  p_y = 1,
  s_x = 1,
  s_y = 1,
  s_width = 0.9,
  s_height = 0.9,
  h_fill = "#1A1A1C",
  h_color = "#1A1A1C",
  h_size = 2.25,
  l_x = 1,
  l_y = 1,
  l_width = 10,
  l_height = 5,
  l_alpha = 0.5,
  dpi = 300,
  url = "github.com/charisma",
  u_color = "#FFFFFF",
  u_family = "impact",
  u_size = 9 * 2.5,
  u_x = 1.1,
  u_y = 0.105,
  white_around_sticker = FALSE,
  spotlight = F
)

ggsave(
  "man/figures/logo.png",
  width = 732,
  height = 523,
  units = "px",
  scale = 5
)
