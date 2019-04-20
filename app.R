library(shiny)
library(raster)

options(shiny.maxRequestSize=300*1024^2)

NDVI <- function(x) {
    y <- (x[,3]-x[,5])/(x[,3]+x[,5])
}

ui <- fluidPage(
    titlePanel("Image output"),
    fluidRow(
        column(4,
            wellPanel(
                selectInput(
                    inputId = "rast",
                    label = "Choose image",
                    choices = c("uuconf group" = "uncoastunconf-group.jpg")
                ),
                fileInput(
                    inputId = 'custom_rast',
                    label = 'Upload image',
                    accept = c(
                        'image/tif',
                        'image/tiff',
                        'tif',
                        'tiff',
                        'image/png',
                        'png',
                        'image/jpg',
                        'image/jpeg',
                        'jpg',
                        'jpeg'
                    )
                ),
                selectInput(
                    inputId = "red",
                    label = "Choose red channel",
                    choices = c(
                        "Red" = 1,
                        "Green" = 2,
                        "Blue" = 3
                    ),
                    selected = 1
                ),
                selectInput(
                    inputId = "green",
                    label = "Choose green channel",
                    choices = c(
                        "Red" = 1,
                        "Green" = 2,
                        "Blue" = 3
                    ),
                    selected = 2
                ),
                selectInput(
                    inputId = "blue",
                    label = "Choose blue channel",
                    choices = c(
                        "Red" = 1,
                        "Green" = 2,
                        "Blue" = 3
                    ),
                    selected = 3
                ),
                selectInput(
                    inputId = "stretch",
                    label = "Choose stretch method",
                    choices = c(
                        "Linear (default)" = "lin",
                        "Histogram" = "hist",
                        "None" = NULL
                    )
                )
            )
        ),
        column(4,
            imageOutput("preview")
        )
    )
)


server <- function(input, output) {

    output$preview <- renderImage({

        outfile <- tempfile(fileext = ".png")
        input$custom_rast

        if (!is.null(input$custom_rast)){
            brick <- brick(input$custom_rast$datapath)
        } else {
            brick <- brick(input$rast)
        }

        png(
            filename = outfile,
            width = min(brick@ncols, 700),
            height = min(brick@nrows, 700)
        )
        plotRGB(
            x = brick,
            r = as.integer(input$red),
            g = as.integer(input$green),
            b = as.integer(input$blue),
            stretch = input$stretch
        )
        dev.off()

        # Return list with image metadata
        list(
            src = outfile,
            contentType = "image/png",
            width = min(brick@ncols, 700),
            height = min(brick@nrows, 700),
            alt = "image preview"
        )
    }, deleteFile = TRUE)
}

shinyApp(ui = ui, server = server)
