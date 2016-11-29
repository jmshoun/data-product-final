### For a given sample number, create a pair of side-by-side numeric inputs
### where the user can specify the number of observed successes and failures
### for the sample.
sample_input <- function(sample.number, default.value=5) {
    success.id <- sprintf("sample_%d_successes", sample.number)
    failure.id <- sprintf("sample_%d_failures", sample.number)
    success.label <- sprintf("Sample %d Successes", sample.number)
    failure.label <- sprintf("Sample %d Failures", sample.number)
    div(
        inlineNumericInput(success.id, success.label, default.value, min=0),
        inlineNumericInput(failure.id, failure.label, default.value, min=0)
    )
}

### Create a numericInput field that displays inline (i.e., so you can have two
### numericInputs side-by-side instead of stacking vertically).
### This code is basically a slight modification of numericInput with a modified
### CSS style tag in the containing div.
inlineNumericInput <- function(inputId, label, value, min=NA, max=NA, step=1) {
    value <- restoreInput(id=inputId, default=value)
    inputTag <- tags$input(id=inputId, type="number", class="form-control",
                           value=shiny:::formatNoSci(value))
    if (!is.na(min)) inputTag$attribs$min <- min
    if (!is.na(max)) inputTag$attribs$max <- max
    if (!is.na(step)) inputTag$attribs$step <- step
    div(style="display:inline-block; width:49%",
        class="input-small",
        tags$label(label, `for`=inputId),
        inputTag)
}