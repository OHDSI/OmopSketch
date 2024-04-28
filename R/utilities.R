startDate <- function(name) {
  tables$start_date[tables$table_name == name]
}
endDate <- function(name) {
  tables$end_date[tables$table_name == name]
}
standardConcept <- function(name) {
  tables$standard_concept[tables$table_name == name]
}
sourceConcept <- function(name) {
  tables$source_concept[tables$table_name == name]
}
typeConcept <- function(name) {
  tables$type_concept[tables$table_name == name]
}
tableId <- function(name) {
  tables$id[tables$table_name == name]
}
