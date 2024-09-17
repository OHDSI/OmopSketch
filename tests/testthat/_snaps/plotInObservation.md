# plotInObservation works

    Code
      plotInObservation(result)
    Condition
      Error in `plotInObservation()`:
      ! Subset to the variable of interest, there are results from: person-days and records.
      i result |> dplyr::filter(variable_name == 'person-days')

