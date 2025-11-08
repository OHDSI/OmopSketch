# Create a visual table from a summariseConceptIdCounts() result.

Create a visual table from a summariseConceptIdCounts() result.

## Usage

``` r
tableConceptIdCounts(result, display = "overall", type = "reactable")
```

## Arguments

- result:

  A summarised_result object.

- display:

  A character string indicating which subset of the data to display.
  Options are:

  - `"overall"`: Show all source and standard concepts.

  - `"standard"`: Show only standard concepts.

  - `"source"`: Show only source codes.

  - `"missing standard"`: Show only source codes that are missing a
    mapped standard concept.

- type:

  Type of formatting output table, either "reactable" or "datatable".

## Value

A reactable or datatable object with the summarised data.

## Examples

``` r
# \donttest{
library(OmopSketch)
library(CDMConnector)
library(duckdb)

requireEunomia()
con <- dbConnect(duckdb(), eunomiaDir())
cdm <- cdmFromCon(con = con, cdmSchema = "main", writeSchema = "main")

result <- summariseConceptIdCounts(cdm = cdm, omopTableName = "condition_occurrence")
tableConceptIdCounts(result = result, display = "standard")

{"x":{"tag":{"name":"Reactable","attribs":{"data":{" ":["condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence","condition_occurrence"],"Standard concept name":["Acute allergic reaction","Acute bacterial sinusitis","Acute bronchitis","Acute cholecystitis","Acute viral pharyngitis","Alzheimer's disease","Anemia","Angiodysplasia of stomach","Appendicitis","Asthma","Atopic dermatitis","Atrial fibrillation","Bullet wound","Cardiac arrest","Cerebrovascular accident","Child attention deficit disorder","Childhood asthma","Chronic paralysis due to lesion of spinal cord","Chronic sinusitis","Closed fracture of hip","Concussion injury of brain","Concussion with loss of consciousness","Concussion with no loss of consciousness","Contact dermatitis","Coronary arteriosclerosis","Cystitis","Diverticular disease","Emphysematous bronchitis","Epilepsy","Escherichia coli urinary tract infection","Esophagitis","Facial laceration","Familial alzheimer's disease of early onset","First degree burn","Fracture of ankle","Fracture of clavicle","Fracture of forearm","Fracture of rib","Fracture of vertebral column with spinal cord injury","Fracture of vertebral column without spinal cord injury","Fracture subluxation of wrist","Gallstone","Gastrointestinal hemorrhage","Hypothyroidism","Injury of anterior cruciate ligament","Injury of medial collateral ligament of knee","Injury of tendon of the rotator cuff of shoulder","Laceration of foot","Laceration of forearm","Laceration of hand","Laceration of thigh","Myocardial infarction","Osteoarthritis","Osteoporosis","Otitis media","Pathological fracture due to osteoporosis","Peptic ulcer","Perennial allergic rhinitis","Perennial allergic rhinitis with seasonal variation","Pneumonia","Polyp of colon","Pulmonary emphysema","Pyelonephritis","Recurrent urinary tract infection","Rheumatoid arthritis","Rupture of appendix","Rupture of patellar tendon","Seasonal allergic rhinitis","Second degree burn","Seizure disorder","Sinusitis","Sprain of ankle","Sprain of wrist","Streptococcal sore throat","Tear of meniscus of knee","Third degree burn","Traumatic brain injury","Ulcerative colitis","Viral sinusitis","Whiplash injury to neck"],"Standard concept id":["4084167","4294548","260139","198809","4112343","378419","439777","4310024","440448","317009","133834","313217","4094814","321042","381316","440086","4051466","44782520","257012","4230399","4001336","375671","378001","134438","317576","195588","4266809","258780","380378","4116491","30753","4156265","4043241","4296204","4059173","4237458","4278672","4142905","4066995","4048695","4134304","196456","192671","140673","40479768","40479422","4146173","4109685","4155034","4113008","4152936","4329847","80180","80502","372328","40480160","4027663","40486433","4048171","255848","4285898","261325","198199","4056621","80809","4166224","4149245","4280726","4296205","4029498","4283893","81151","78272","28060","4035415","4299128","4132546","81893","40481087","4218389"],"N records":[161,939,8184,35,10217,117,102,388,157,5,54,137,46,138,224,253,96,3,825,138,70,265,1013,113,191,322,405,48,30,482,409,497,19,384,464,492,569,263,3,23,493,35,479,31,80,113,266,484,507,500,499,67,2694,171,3605,77,802,64,79,52,380,77,9,33,18,41,80,25,229,79,1001,1915,770,2656,83,24,27,413,17268,825]},"columns":[{"id":" ","name":" ","type":"character","sortable":true,"resizable":true,"filterable":true,"headerStyle":{"textAlign":"center"}},{"id":"Standard concept name","name":"Standard concept name","type":"character","sortable":true,"resizable":true,"filterable":true,"headerStyle":{"textAlign":"center"}},{"id":"Standard concept id","name":"Standard concept id","type":"character","sortable":true,"resizable":true,"filterable":true,"headerStyle":{"textAlign":"center"}},{"id":"N records","name":"N records","type":"numeric","sortable":true,"resizable":true,"filterable":true,"headerStyle":{"textAlign":"center"}}],"columnGroups":[{"headerStyle":{"textAlign":"center"},"name":"Synthea","columns":["N records"]}],"groupBy":[" "],"searchable":true,"defaultPageSize":10,"showPageSizeOptions":true,"defaultExpanded":true,"highlight":true,"striped":true,"dataKey":"51cdebdd7dae457f54277fda69577adb"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}# }
```
