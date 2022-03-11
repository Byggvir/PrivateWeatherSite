# Title: My personal theme
# Version: 0.1.0
# Author: Thomas Arend
# Maintainer: Thomas Arend <thomas@arend-rhb.de>
#   Description: Define a personal theme to be used in all projects.
#   My theme for the uniform appearance of the diagrams
# License: GNU General Public License 3
# Encoding: UTF-8
#
# 
# 

theme_ta <- function (
  base_family = "Helvetica",
  base_size = 24,
  plot_title_family = base_family,
  plot_title_size = 48,
  plot_title_face = "bold",
  plot_title_margin = 24,
  subtitle_family = base_family,
  subtitle_size = 26,
  subtitle_face = "plain",
  subtitle_margin = 24,
  strip_text_family = base_family,
  strip_text_size = 16,
  strip_text_face = "plain",
  caption_family = base_family,
  caption_size = 16,
  caption_face = "italic",
  caption_margin = 16,
  axis_text_size = base_size,
  axis_title_family = subtitle_family,
  axis_title_size = base_size + 8,
  axis_title_face = "plain",
  axis_title_just = "rt",
  plot_margin = margin(30, 30, 30, 30),
  grid_col = "#cccccc",
  grid = TRUE,
  axis_col = "#cccccc",
  axis = FALSE,
  ticks = FALSE ) {
  
  theme_ipsum(   base_size = base_size
               , base_family = base_family
               , plot_title_margin = plot_title_margin
               , subtitle_margin = subtitle_margin
               , strip_text_size = strip_text_size ) %+replace%
  theme(
        plot.title = element_text (
          size = plot_title_size
          , color = "black"
          , face = "bold.italic"
        )
    
        , plot.subtitle = element_text (
          size = subtitle_size
          , color = "black"
          , face = "bold.italic"
        )
      , legend.position = 'bottom'
      , axis.title = element_text(
          size = axis_title_size )
      , axis.text = element_text(
          size = axis_text_size )
      , axis.title.x = element_text(
          size = rel(1))
      , axis.text.x = element_text ( 
          size = axis_text_size
          , angle = 90 )
      , axis.title.y = element_text ( 
          size = rel(1), angle = 90 )
      , axis.title.y.right = element_text ( 
          size = axis_title_size, angle = 90 )
      , axis.text.y = element_text ( 
          size = axis_text_size, angle = 90 )
      , axis.text.y.right = element_text ( 
          size = axis_text_size, angle = 90 , color = 'blue' )
      
      , plot.caption = element_text (
           size = rel(0.2)
        ,  color = "black"
        , face = "bold.italic"
      )
      , legend.title = element_text (
        size = base_size + 8
        ,  color = "black"
        , face = "bold.italic"
      )
      , legend.text = element_text (
          size = base_size
          ,  color = "black"
          , face = "bold.italic"
        )
      , strip.text.x = element_text (
        size = rel(0.2)
        , color = "black"
        , face = "bold.italic"
      ),
      
      complete = TRUE
    )
  
}
