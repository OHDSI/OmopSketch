# Create a visual table from a summariseRecordCount() result. **\[deprecated\]**

Create a visual table from a summariseRecordCount() result.
**\[deprecated\]**

## Usage

``` r
tableRecordCount(result, type = "gt")
```

## Arguments

- result:

  A summarised_result object.

- type:

  Type of formatting output table. See
  [`visOmopResults::tableType()`](https://darwin-eu.github.io/visOmopResults/reference/tableType.html)
  for allowed options. Default is `"gt"`.

## Value

A formatted table object with the summarised data.

## Examples

``` r
# \donttest{
library(OmopSketch)
library(dplyr, warn.conflicts = FALSE)

cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

summarisedResult <- summariseRecordCount(
  cdm = cdm,
  omopTableName = c("condition_occurrence", "drug_exposure"),
  interval = "years",
  ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
  sex = TRUE
)

tableRecordCount(result = summarisedResult)
#> Warning: `tableRecordCount()` was deprecated in OmopSketch 1.0.0.
#> ℹ Please use `tableTrend()` instead.


  
Summary of Number of records by years in drug_exposure, condition_occurrence tables

  

Variable name
```

Time interval

Age group

Sex

Estimate name

Database name

mockOmopSketch

episode; drug_exposure

Number of records

1956-01-01 to 1956-12-31

overall

overall

N (%)

3 (0.01%)

\<=20

overall

N (%)

3 (0.01%)

overall

Female

N (%)

3 (0.01%)

\<=20

Female

N (%)

3 (0.01%)

1957-01-01 to 1957-12-31

overall

overall

N (%)

6 (0.03%)

\<=20

overall

N (%)

6 (0.03%)

overall

Female

N (%)

6 (0.03%)

\<=20

Female

N (%)

6 (0.03%)

1958-01-01 to 1958-12-31

overall

overall

N (%)

15 (0.07%)

\<=20

overall

N (%)

15 (0.07%)

overall

Female

N (%)

15 (0.07%)

\<=20

Female

N (%)

15 (0.07%)

1959-01-01 to 1959-12-31

overall

overall

N (%)

18 (0.08%)

\<=20

overall

N (%)

18 (0.08%)

overall

Female

N (%)

18 (0.08%)

\<=20

Female

N (%)

18 (0.08%)

1960-01-01 to 1960-12-31

overall

overall

N (%)

25 (0.12%)

\<=20

overall

N (%)

25 (0.12%)

overall

Female

N (%)

24 (0.11%)

Male

N (%)

1 (0.00%)

\<=20

Female

N (%)

24 (0.11%)

Male

N (%)

1 (0.00%)

1961-01-01 to 1961-12-31

overall

overall

N (%)

34 (0.16%)

\<=20

overall

N (%)

34 (0.16%)

overall

Female

N (%)

30 (0.14%)

Male

N (%)

4 (0.02%)

\<=20

Female

N (%)

30 (0.14%)

Male

N (%)

4 (0.02%)

1962-01-01 to 1962-12-31

overall

overall

N (%)

42 (0.19%)

\<=20

overall

N (%)

42 (0.19%)

overall

Female

N (%)

35 (0.16%)

Male

N (%)

7 (0.03%)

\<=20

Female

N (%)

35 (0.16%)

Male

N (%)

7 (0.03%)

1963-01-01 to 1963-12-31

overall

overall

N (%)

60 (0.28%)

\<=20

overall

N (%)

60 (0.28%)

overall

Female

N (%)

47 (0.22%)

Male

N (%)

13 (0.06%)

\<=20

Female

N (%)

47 (0.22%)

Male

N (%)

13 (0.06%)

1964-01-01 to 1964-12-31

overall

overall

N (%)

72 (0.33%)

\<=20

overall

N (%)

72 (0.33%)

overall

Female

N (%)

55 (0.25%)

Male

N (%)

17 (0.08%)

\<=20

Female

N (%)

55 (0.25%)

Male

N (%)

17 (0.08%)

1965-01-01 to 1965-12-31

overall

overall

N (%)

77 (0.36%)

\<=20

overall

N (%)

77 (0.36%)

overall

Female

N (%)

58 (0.27%)

Male

N (%)

19 (0.09%)

\<=20

Female

N (%)

58 (0.27%)

Male

N (%)

19 (0.09%)

1966-01-01 to 1966-12-31

overall

overall

N (%)

79 (0.37%)

\<=20

overall

N (%)

79 (0.37%)

overall

Female

N (%)

59 (0.27%)

Male

N (%)

20 (0.09%)

\<=20

Female

N (%)

59 (0.27%)

Male

N (%)

20 (0.09%)

1967-01-01 to 1967-12-31

overall

overall

N (%)

89 (0.41%)

\<=20

overall

N (%)

89 (0.41%)

overall

Female

N (%)

64 (0.30%)

Male

N (%)

25 (0.12%)

\<=20

Female

N (%)

64 (0.30%)

Male

N (%)

25 (0.12%)

1968-01-01 to 1968-12-31

overall

overall

N (%)

96 (0.44%)

\<=20

overall

N (%)

96 (0.44%)

overall

Female

N (%)

67 (0.31%)

Male

N (%)

29 (0.13%)

\<=20

Female

N (%)

67 (0.31%)

Male

N (%)

29 (0.13%)

1969-01-01 to 1969-12-31

overall

overall

N (%)

103 (0.48%)

\<=20

overall

N (%)

103 (0.48%)

overall

Female

N (%)

72 (0.33%)

Male

N (%)

31 (0.14%)

\<=20

Female

N (%)

72 (0.33%)

Male

N (%)

31 (0.14%)

1970-01-01 to 1970-12-31

overall

overall

N (%)

112 (0.52%)

\<=20

overall

N (%)

112 (0.52%)

overall

Female

N (%)

76 (0.35%)

Male

N (%)

36 (0.17%)

\<=20

Female

N (%)

76 (0.35%)

Male

N (%)

36 (0.17%)

1971-01-01 to 1971-12-31

overall

overall

N (%)

131 (0.61%)

\<=20

overall

N (%)

130 (0.60%)

\>20

overall

N (%)

1 (0.00%)

overall

Female

N (%)

80 (0.37%)

Male

N (%)

51 (0.24%)

\>20

Female

N (%)

1 (0.00%)

\<=20

Female

N (%)

79 (0.37%)

Male

N (%)

51 (0.24%)

1972-01-01 to 1972-12-31

overall

overall

N (%)

147 (0.68%)

\<=20

overall

N (%)

78 (0.36%)

\>20

overall

N (%)

69 (0.32%)

overall

Female

N (%)

85 (0.39%)

Male

N (%)

62 (0.29%)

\>20

Female

N (%)

69 (0.32%)

\<=20

Male

N (%)

62 (0.29%)

Female

N (%)

16 (0.07%)

1973-01-01 to 1973-12-31

overall

overall

N (%)

164 (0.76%)

\>20

overall

N (%)

90 (0.42%)

\<=20

overall

N (%)

74 (0.34%)

overall

Female

N (%)

90 (0.42%)

Male

N (%)

74 (0.34%)

\>20

Female

N (%)

90 (0.42%)

\<=20

Male

N (%)

74 (0.34%)

1974-01-01 to 1974-12-31

overall

overall

N (%)

179 (0.83%)

\<=20

overall

N (%)

84 (0.39%)

\>20

overall

N (%)

95 (0.44%)

overall

Female

N (%)

95 (0.44%)

Male

N (%)

84 (0.39%)

\<=20

Male

N (%)

84 (0.39%)

\>20

Female

N (%)

95 (0.44%)

1975-01-01 to 1975-12-31

overall

overall

N (%)

230 (1.06%)

\>20

overall

N (%)

103 (0.48%)

\<=20

overall

N (%)

127 (0.59%)

overall

Female

N (%)

103 (0.48%)

Male

N (%)

127 (0.59%)

\>20

Female

N (%)

103 (0.48%)

\<=20

Male

N (%)

127 (0.59%)

1976-01-01 to 1976-12-31

overall

overall

N (%)

304 (1.41%)

\>20

overall

N (%)

109 (0.50%)

\<=20

overall

N (%)

195 (0.90%)

overall

Male

N (%)

196 (0.91%)

Female

N (%)

108 (0.50%)

\<=20

Male

N (%)

195 (0.90%)

\>20

Female

N (%)

108 (0.50%)

Male

N (%)

1 (0.00%)

1977-01-01 to 1977-12-31

overall

overall

N (%)

383 (1.77%)

\<=20

overall

N (%)

222 (1.03%)

\>20

overall

N (%)

161 (0.75%)

overall

Male

N (%)

268 (1.24%)

Female

N (%)

115 (0.53%)

\>20

Female

N (%)

115 (0.53%)

Male

N (%)

46 (0.21%)

\<=20

Male

N (%)

222 (1.03%)

1978-01-01 to 1978-12-31

overall

overall

N (%)

550 (2.55%)

\>20

overall

N (%)

173 (0.80%)

\<=20

overall

N (%)

377 (1.75%)

overall

Male

N (%)

341 (1.58%)

Female

N (%)

209 (0.97%)

\>20

Female

N (%)

117 (0.54%)

Male

N (%)

56 (0.26%)

\<=20

Male

N (%)

285 (1.32%)

Female

N (%)

92 (0.43%)

1979-01-01 to 1979-12-31

overall

overall

N (%)

719 (3.33%)

\<=20

overall

N (%)

520 (2.41%)

\>20

overall

N (%)

199 (0.92%)

overall

Male

N (%)

382 (1.77%)

Female

N (%)

337 (1.56%)

\>20

Female

N (%)

129 (0.60%)

Male

N (%)

70 (0.32%)

\<=20

Male

N (%)

312 (1.44%)

Female

N (%)

208 (0.96%)

1980-01-01 to 1980-12-31

overall

overall

N (%)

560 (2.59%)

\>20

overall

N (%)

298 (1.38%)

\<=20

overall

N (%)

262 (1.21%)

overall

Male

N (%)

413 (1.91%)

Female

N (%)

147 (0.68%)

\>20

Male

N (%)

160 (0.74%)

Female

N (%)

138 (0.64%)

\<=20

Male

N (%)

253 (1.17%)

Female

N (%)

9 (0.04%)

1981-01-01 to 1981-12-31

overall

overall

N (%)

483 (2.24%)

\>20

overall

N (%)

311 (1.44%)

\<=20

overall

N (%)

172 (0.80%)

overall

Male

N (%)

342 (1.58%)

Female

N (%)

141 (0.65%)

\>20

Male

N (%)

170 (0.79%)

Female

N (%)

141 (0.65%)

\<=20

Male

N (%)

172 (0.80%)

1982-01-01 to 1982-12-31

overall

overall

N (%)

516 (2.39%)

\<=20

overall

N (%)

175 (0.81%)

\>20

overall

N (%)

341 (1.58%)

overall

Male

N (%)

369 (1.71%)

Female

N (%)

147 (0.68%)

\<=20

Male

N (%)

175 (0.81%)

\>20

Male

N (%)

194 (0.90%)

Female

N (%)

147 (0.68%)

1983-01-01 to 1983-12-31

overall

overall

N (%)

539 (2.50%)

\<=20

overall

N (%)

168 (0.78%)

\>20

overall

N (%)

371 (1.72%)

overall

Male

N (%)

381 (1.76%)

Female

N (%)

158 (0.73%)

\>20

Male

N (%)

213 (0.99%)

Female

N (%)

158 (0.73%)

\<=20

Male

N (%)

168 (0.78%)

1984-01-01 to 1984-12-31

overall

overall

N (%)

640 (2.96%)

\>20

overall

N (%)

385 (1.78%)

\<=20

overall

N (%)

255 (1.18%)

overall

Male

N (%)

471 (2.18%)

Female

N (%)

169 (0.78%)

\>20

Male

N (%)

216 (1.00%)

Female

N (%)

169 (0.78%)

\<=20

Male

N (%)

255 (1.18%)

1985-01-01 to 1985-12-31

overall

overall

N (%)

764 (3.54%)

\<=20

overall

N (%)

339 (1.57%)

\>20

overall

N (%)

425 (1.97%)

overall

Male

N (%)

564 (2.61%)

Female

N (%)

200 (0.93%)

\>20

Male

N (%)

235 (1.09%)

\<=20

Male

N (%)

329 (1.52%)

\>20

Female

N (%)

190 (0.88%)

\<=20

Female

N (%)

10 (0.05%)

1986-01-01 to 1986-12-31

overall

overall

N (%)

831 (3.85%)

\<=20

overall

N (%)

306 (1.42%)

\>20

overall

N (%)

525 (2.43%)

overall

Male

N (%)

585 (2.71%)

Female

N (%)

246 (1.14%)

\<=20

Male

N (%)

274 (1.27%)

Female

N (%)

32 (0.15%)

\>20

Male

N (%)

311 (1.44%)

Female

N (%)

214 (0.99%)

1987-01-01 to 1987-12-31

overall

overall

N (%)

798 (3.69%)

\<=20

overall

N (%)

229 (1.06%)

\>20

overall

N (%)

569 (2.63%)

overall

Female

N (%)

313 (1.45%)

Male

N (%)

485 (2.25%)

\<=20

Female

N (%)

55 (0.25%)

Male

N (%)

174 (0.81%)

\>20

Male

N (%)

311 (1.44%)

Female

N (%)

258 (1.19%)

1988-01-01 to 1988-12-31

overall

overall

N (%)

917 (4.25%)

\>20

overall

N (%)

680 (3.15%)

\<=20

overall

N (%)

237 (1.10%)

overall

Female

N (%)

386 (1.79%)

Male

N (%)

531 (2.46%)

\>20

Male

N (%)

371 (1.72%)

Female

N (%)

309 (1.43%)

\<=20

Female

N (%)

77 (0.36%)

Male

N (%)

160 (0.74%)

1989-01-01 to 1989-12-31

overall

overall

N (%)

1,016 (4.70%)

\>20

overall

N (%)

709 (3.28%)

\<=20

overall

N (%)

307 (1.42%)

overall

Female

N (%)

435 (2.01%)

Male

N (%)

581 (2.69%)

\<=20

Female

N (%)

103 (0.48%)

Male

N (%)

204 (0.94%)

\>20

Male

N (%)

377 (1.75%)

Female

N (%)

332 (1.54%)

1990-01-01 to 1990-12-31

overall

overall

N (%)

1,190 (5.51%)

\<=20

overall

N (%)

422 (1.95%)

\>20

overall

N (%)

768 (3.56%)

overall

Female

N (%)

531 (2.46%)

Male

N (%)

659 (3.05%)

\<=20

Female

N (%)

147 (0.68%)

Male

N (%)

275 (1.27%)

\>20

Male

N (%)

384 (1.78%)

Female

N (%)

384 (1.78%)

1991-01-01 to 1991-12-31

overall

overall

N (%)

1,378 (6.38%)

\<=20

overall

N (%)

523 (2.42%)

\>20

overall

N (%)

855 (3.96%)

overall

Female

N (%)

626 (2.90%)

Male

N (%)

752 (3.48%)

\<=20

Female

N (%)

186 (0.86%)

Male

N (%)

337 (1.56%)

\>20

Male

N (%)

415 (1.92%)

Female

N (%)

440 (2.04%)

1992-01-01 to 1992-12-31

overall

overall

N (%)

1,516 (7.02%)

\<=20

overall

N (%)

616 (2.85%)

\>20

overall

N (%)

900 (4.17%)

overall

Female

N (%)

689 (3.19%)

Male

N (%)

827 (3.83%)

\<=20

Female

N (%)

220 (1.02%)

Male

N (%)

396 (1.83%)

\>20

Female

N (%)

469 (2.17%)

Male

N (%)

431 (2.00%)

1993-01-01 to 1993-12-31

overall

overall

N (%)

1,600 (7.41%)

\>20

overall

N (%)

974 (4.51%)

\<=20

overall

N (%)

626 (2.90%)

overall

Male

N (%)

854 (3.95%)

Female

N (%)

746 (3.45%)

\<=20

Male

N (%)

427 (1.98%)

\>20

Male

N (%)

427 (1.98%)

Female

N (%)

547 (2.53%)

\<=20

Female

N (%)

199 (0.92%)

1994-01-01 to 1994-12-31

overall

overall

N (%)

1,896 (8.78%)

\>20

overall

N (%)

1,089 (5.04%)

\<=20

overall

N (%)

807 (3.74%)

overall

Male

N (%)

1,036 (4.80%)

Female

N (%)

860 (3.98%)

\>20

Male

N (%)

465 (2.15%)

Female

N (%)

624 (2.89%)

\<=20

Male

N (%)

571 (2.64%)

Female

N (%)

236 (1.09%)

1995-01-01 to 1995-12-31

overall

overall

N (%)

2,304 (10.67%)

\>20

overall

N (%)

1,274 (5.90%)

\<=20

overall

N (%)

1,030 (4.77%)

overall

Male

N (%)

1,256 (5.81%)

Female

N (%)

1,048 (4.85%)

\>20

Male

N (%)

500 (2.31%)

Female

N (%)

774 (3.58%)

\<=20

Male

N (%)

756 (3.50%)

Female

N (%)

274 (1.27%)

1996-01-01 to 1996-12-31

overall

overall

N (%)

2,322 (10.75%)

\<=20

overall

N (%)

1,076 (4.98%)

\>20

overall

N (%)

1,246 (5.77%)

overall

Male

N (%)

1,275 (5.90%)

Female

N (%)

1,047 (4.85%)

\<=20

Male

N (%)

765 (3.54%)

Female

N (%)

311 (1.44%)

\>20

Male

N (%)

510 (2.36%)

Female

N (%)

736 (3.41%)

1997-01-01 to 1997-12-31

overall

overall

N (%)

2,336 (10.81%)

\<=20

overall

N (%)

1,105 (5.12%)

\>20

overall

N (%)

1,231 (5.70%)

overall

Male

N (%)

1,293 (5.99%)

Female

N (%)

1,043 (4.83%)

\>20

Male

N (%)

538 (2.49%)

Female

N (%)

693 (3.21%)

\<=20

Male

N (%)

755 (3.50%)

Female

N (%)

350 (1.62%)

1998-01-01 to 1998-12-31

overall

overall

N (%)

2,652 (12.28%)

\<=20

overall

N (%)

1,131 (5.24%)

\>20

overall

N (%)

1,521 (7.04%)

overall

Male

N (%)

1,524 (7.06%)

Female

N (%)

1,128 (5.22%)

\<=20

Male

N (%)

740 (3.43%)

Female

N (%)

391 (1.81%)

\>20

Male

N (%)

784 (3.63%)

Female

N (%)

737 (3.41%)

1999-01-01 to 1999-12-31

overall

overall

N (%)

2,897 (13.41%)

\>20

overall

N (%)

1,620 (7.50%)

\<=20

overall

N (%)

1,277 (5.91%)

overall

Male

N (%)

1,611 (7.46%)

Female

N (%)

1,286 (5.95%)

\<=20

Male

N (%)

889 (4.12%)

\>20

Male

N (%)

722 (3.34%)

Female

N (%)

898 (4.16%)

\<=20

Female

N (%)

388 (1.80%)

2000-01-01 to 2000-12-31

overall

overall

N (%)

3,037 (14.06%)

\>20

overall

N (%)

1,747 (8.09%)

\<=20

overall

N (%)

1,290 (5.97%)

overall

Female

N (%)

1,399 (6.48%)

Male

N (%)

1,638 (7.58%)

\>20

Male

N (%)

806 (3.73%)

Female

N (%)

941 (4.36%)

\<=20

Female

N (%)

458 (2.12%)

Male

N (%)

832 (3.85%)

2001-01-01 to 2001-12-31

overall

overall

N (%)

3,037 (14.06%)

\<=20

overall

N (%)

1,347 (6.24%)

\>20

overall

N (%)

1,690 (7.82%)

overall

Female

N (%)

1,496 (6.93%)

Male

N (%)

1,541 (7.13%)

\>20

Male

N (%)

762 (3.53%)

Female

N (%)

928 (4.30%)

\<=20

Female

N (%)

568 (2.63%)

Male

N (%)

779 (3.61%)

2002-01-01 to 2002-12-31

overall

overall

N (%)

3,063 (14.18%)

\<=20

overall

N (%)

1,518 (7.03%)

\>20

overall

N (%)

1,545 (7.15%)

overall

Female

N (%)

1,503 (6.96%)

Male

N (%)

1,560 (7.22%)

\<=20

Female

N (%)

634 (2.94%)

\>20

Female

N (%)

869 (4.02%)

Male

N (%)

676 (3.13%)

\<=20

Male

N (%)

884 (4.09%)

2003-01-01 to 2003-12-31

overall

overall

N (%)

3,094 (14.32%)

\>20

overall

N (%)

1,616 (7.48%)

\<=20

overall

N (%)

1,478 (6.84%)

overall

Female

N (%)

1,430 (6.62%)

Male

N (%)

1,664 (7.70%)

\<=20

Female

N (%)

675 (3.12%)

Male

N (%)

803 (3.72%)

\>20

Female

N (%)

755 (3.50%)

Male

N (%)

861 (3.99%)

2004-01-01 to 2004-12-31

overall

overall

N (%)

2,912 (13.48%)

\>20

overall

N (%)

1,786 (8.27%)

\<=20

overall

N (%)

1,126 (5.21%)

overall

Female

N (%)

1,287 (5.96%)

Male

N (%)

1,625 (7.52%)

\<=20

Female

N (%)

525 (2.43%)

Male

N (%)

601 (2.78%)

\>20

Male

N (%)

1,024 (4.74%)

Female

N (%)

762 (3.53%)

2005-01-01 to 2005-12-31

overall

overall

N (%)

2,819 (13.05%)

\<=20

overall

N (%)

1,075 (4.98%)

\>20

overall

N (%)

1,744 (8.07%)

overall

Male

N (%)

1,587 (7.35%)

Female

N (%)

1,232 (5.70%)

\<=20

Male

N (%)

525 (2.43%)

\>20

Male

N (%)

1,062 (4.92%)

Female

N (%)

682 (3.16%)

\<=20

Female

N (%)

550 (2.55%)

2006-01-01 to 2006-12-31

overall

overall

N (%)

2,874 (13.31%)

\<=20

overall

N (%)

956 (4.43%)

\>20

overall

N (%)

1,918 (8.88%)

overall

Male

N (%)

1,646 (7.62%)

Female

N (%)

1,228 (5.69%)

\<=20

Male

N (%)

410 (1.90%)

\>20

Male

N (%)

1,236 (5.72%)

Female

N (%)

682 (3.16%)

\<=20

Female

N (%)

546 (2.53%)

2007-01-01 to 2007-12-31

overall

overall

N (%)

3,423 (15.85%)

\<=20

overall

N (%)

1,286 (5.95%)

\>20

overall

N (%)

2,137 (9.89%)

overall

Male

N (%)

1,953 (9.04%)

Female

N (%)

1,470 (6.81%)

\<=20

Male

N (%)

491 (2.27%)

Female

N (%)

795 (3.68%)

\>20

Male

N (%)

1,462 (6.77%)

Female

N (%)

675 (3.12%)

2008-01-01 to 2008-12-31

overall

overall

N (%)

3,027 (14.01%)

\>20

overall

N (%)

2,061 (9.54%)

\<=20

overall

N (%)

966 (4.47%)

overall

Male

N (%)

1,721 (7.97%)

Female

N (%)

1,306 (6.05%)

\<=20

Male

N (%)

495 (2.29%)

Female

N (%)

471 (2.18%)

\>20

Male

N (%)

1,226 (5.68%)

Female

N (%)

835 (3.87%)

2009-01-01 to 2009-12-31

overall

overall

N (%)

3,238 (14.99%)

\<=20

overall

N (%)

1,069 (4.95%)

\>20

overall

N (%)

2,169 (10.04%)

overall

Female

N (%)

1,596 (7.39%)

Male

N (%)

1,642 (7.60%)

\<=20

Male

N (%)

521 (2.41%)

Female

N (%)

548 (2.54%)

\>20

Female

N (%)

1,048 (4.85%)

Male

N (%)

1,121 (5.19%)

2010-01-01 to 2010-12-31

overall

overall

N (%)

3,149 (14.58%)

\<=20

overall

N (%)

782 (3.62%)

\>20

overall

N (%)

2,367 (10.96%)

overall

Male

N (%)

1,684 (7.80%)

Female

N (%)

1,465 (6.78%)

\<=20

Male

N (%)

472 (2.19%)

\>20

Female

N (%)

1,155 (5.35%)

Male

N (%)

1,212 (5.61%)

\<=20

Female

N (%)

310 (1.44%)

2011-01-01 to 2011-12-31

overall

overall

N (%)

3,097 (14.34%)

\>20

overall

N (%)

2,534 (11.73%)

\<=20

overall

N (%)

563 (2.61%)

overall

Female

N (%)

1,799 (8.33%)

Male

N (%)

1,298 (6.01%)

\<=20

Male

N (%)

290 (1.34%)

Female

N (%)

273 (1.26%)

\>20

Female

N (%)

1,526 (7.06%)

Male

N (%)

1,008 (4.67%)

2012-01-01 to 2012-12-31

overall

overall

N (%)

2,998 (13.88%)

\>20

overall

N (%)

2,612 (12.09%)

\<=20

overall

N (%)

386 (1.79%)

overall

Male

N (%)

1,226 (5.68%)

Female

N (%)

1,772 (8.20%)

\>20

Male

N (%)

1,054 (4.88%)

Female

N (%)

1,558 (7.21%)

\<=20

Female

N (%)

214 (0.99%)

Male

N (%)

172 (0.80%)

2013-01-01 to 2013-12-31

overall

overall

N (%)

2,764 (12.80%)

\<=20

overall

N (%)

308 (1.43%)

\>20

overall

N (%)

2,456 (11.37%)

overall

Male

N (%)

1,176 (5.44%)

Female

N (%)

1,588 (7.35%)

\>20

Male

N (%)

1,000 (4.63%)

Female

N (%)

1,456 (6.74%)

\<=20

Male

N (%)

176 (0.81%)

Female

N (%)

132 (0.61%)

2014-01-01 to 2014-12-31

overall

overall

N (%)

2,634 (12.19%)

\>20

overall

N (%)

2,191 (10.14%)

\<=20

overall

N (%)

443 (2.05%)

overall

Male

N (%)

1,078 (4.99%)

Female

N (%)

1,556 (7.20%)

\<=20

Male

N (%)

275 (1.27%)

Female

N (%)

168 (0.78%)

\>20

Male

N (%)

803 (3.72%)

Female

N (%)

1,388 (6.43%)

2015-01-01 to 2015-12-31

overall

overall

N (%)

1,897 (8.78%)

\>20

overall

N (%)

1,580 (7.31%)

\<=20

overall

N (%)

317 (1.47%)

overall

Female

N (%)

1,240 (5.74%)

Male

N (%)

657 (3.04%)

\<=20

Male

N (%)

228 (1.06%)

Female

N (%)

89 (0.41%)

\>20

Female

N (%)

1,151 (5.33%)

Male

N (%)

429 (1.99%)

2016-01-01 to 2016-12-31

overall

overall

N (%)

1,838 (8.51%)

\<=20

overall

N (%)

498 (2.31%)

\>20

overall

N (%)

1,340 (6.20%)

overall

Female

N (%)

1,396 (6.46%)

Male

N (%)

442 (2.05%)

\<=20

Male

N (%)

211 (0.98%)

Female

N (%)

287 (1.33%)

\>20

Female

N (%)

1,109 (5.13%)

Male

N (%)

231 (1.07%)

2017-01-01 to 2017-12-31

overall

overall

N (%)

1,592 (7.37%)

\<=20

overall

N (%)

417 (1.93%)

\>20

overall

N (%)

1,175 (5.44%)

overall

Female

N (%)

1,008 (4.67%)

Male

N (%)

584 (2.70%)

\>20

Female

N (%)

867 (4.01%)

Male

N (%)

308 (1.43%)

\<=20

Male

N (%)

276 (1.28%)

Female

N (%)

141 (0.65%)

2018-01-01 to 2018-12-31

overall

overall

N (%)

1,507 (6.98%)

\>20

overall

N (%)

1,118 (5.18%)

\<=20

overall

N (%)

389 (1.80%)

overall

Male

N (%)

921 (4.26%)

Female

N (%)

586 (2.71%)

\<=20

Male

N (%)

389 (1.80%)

\>20

Female

N (%)

586 (2.71%)

Male

N (%)

532 (2.46%)

2019-01-01 to 2019-12-31

overall

overall

N (%)

1,205 (5.58%)

\>20

overall

N (%)

1,105 (5.12%)

\<=20

overall

N (%)

100 (0.46%)

overall

Male

N (%)

592 (2.74%)

Female

N (%)

613 (2.84%)

\<=20

Male

N (%)

100 (0.46%)

\>20

Male

N (%)

492 (2.28%)

Female

N (%)

613 (2.84%)

overall

overall

overall

N (%)

21,600 (100.00%)

\>20

overall

N (%)

12,824 (59.37%)

\<=20

overall

N (%)

8,776 (40.63%)

overall

Female

N (%)

10,579 (48.98%)

Male

N (%)

11,021 (51.02%)

\>20

Female

N (%)

7,201 (33.34%)

Male

N (%)

5,623 (26.03%)

\<=20

Female

N (%)

3,378 (15.64%)

Male

N (%)

5,398 (24.99%)

episode; condition_occurrence

Number of records

1957-01-01 to 1957-12-31

overall

overall

N (%)

5 (0.06%)

\<=20

overall

N (%)

5 (0.06%)

overall

Female

N (%)

5 (0.06%)

\<=20

Female

N (%)

5 (0.06%)

1958-01-01 to 1958-12-31

overall

overall

N (%)

7 (0.08%)

\<=20

overall

N (%)

7 (0.08%)

overall

Female

N (%)

7 (0.08%)

\<=20

Female

N (%)

7 (0.08%)

1959-01-01 to 1959-12-31

overall

overall

N (%)

9 (0.11%)

\<=20

overall

N (%)

9 (0.11%)

overall

Female

N (%)

9 (0.11%)

\<=20

Female

N (%)

9 (0.11%)

1960-01-01 to 1960-12-31

overall

overall

N (%)

10 (0.12%)

\<=20

overall

N (%)

10 (0.12%)

overall

Female

N (%)

9 (0.11%)

Male

N (%)

1 (0.01%)

\<=20

Female

N (%)

9 (0.11%)

Male

N (%)

1 (0.01%)

1961-01-01 to 1961-12-31

overall

overall

N (%)

13 (0.15%)

\<=20

overall

N (%)

13 (0.15%)

overall

Female

N (%)

11 (0.13%)

Male

N (%)

2 (0.02%)

\<=20

Female

N (%)

11 (0.13%)

Male

N (%)

2 (0.02%)

1962-01-01 to 1962-12-31

overall

overall

N (%)

17 (0.20%)

\<=20

overall

N (%)

17 (0.20%)

overall

Male

N (%)

6 (0.07%)

Female

N (%)

11 (0.13%)

\<=20

Male

N (%)

6 (0.07%)

Female

N (%)

11 (0.13%)

1963-01-01 to 1963-12-31

overall

overall

N (%)

24 (0.29%)

\<=20

overall

N (%)

24 (0.29%)

overall

Male

N (%)

11 (0.13%)

Female

N (%)

13 (0.15%)

\<=20

Male

N (%)

11 (0.13%)

Female

N (%)

13 (0.15%)

1964-01-01 to 1964-12-31

overall

overall

N (%)

29 (0.35%)

\<=20

overall

N (%)

29 (0.35%)

overall

Male

N (%)

13 (0.15%)

Female

N (%)

16 (0.19%)

\<=20

Male

N (%)

13 (0.15%)

Female

N (%)

16 (0.19%)

1965-01-01 to 1965-12-31

overall

overall

N (%)

31 (0.37%)

\<=20

overall

N (%)

31 (0.37%)

overall

Male

N (%)

13 (0.15%)

Female

N (%)

18 (0.21%)

\<=20

Male

N (%)

13 (0.15%)

Female

N (%)

18 (0.21%)

1966-01-01 to 1966-12-31

overall

overall

N (%)

35 (0.42%)

\<=20

overall

N (%)

35 (0.42%)

overall

Male

N (%)

15 (0.18%)

Female

N (%)

20 (0.24%)

\<=20

Male

N (%)

15 (0.18%)

Female

N (%)

20 (0.24%)

1967-01-01 to 1967-12-31

overall

overall

N (%)

36 (0.43%)

\<=20

overall

N (%)

36 (0.43%)

overall

Male

N (%)

16 (0.19%)

Female

N (%)

20 (0.24%)

\<=20

Male

N (%)

16 (0.19%)

Female

N (%)

20 (0.24%)

1968-01-01 to 1968-12-31

overall

overall

N (%)

41 (0.49%)

\<=20

overall

N (%)

41 (0.49%)

overall

Male

N (%)

18 (0.21%)

Female

N (%)

23 (0.27%)

\<=20

Male

N (%)

18 (0.21%)

Female

N (%)

23 (0.27%)

1969-01-01 to 1969-12-31

overall

overall

N (%)

43 (0.51%)

\<=20

overall

N (%)

43 (0.51%)

overall

Male

N (%)

18 (0.21%)

Female

N (%)

25 (0.30%)

\<=20

Male

N (%)

18 (0.21%)

Female

N (%)

25 (0.30%)

1970-01-01 to 1970-12-31

overall

overall

N (%)

45 (0.54%)

\<=20

overall

N (%)

45 (0.54%)

overall

Male

N (%)

18 (0.21%)

Female

N (%)

27 (0.32%)

\<=20

Male

N (%)

18 (0.21%)

Female

N (%)

27 (0.32%)

1971-01-01 to 1971-12-31

overall

overall

N (%)

54 (0.64%)

\<=20

overall

N (%)

53 (0.63%)

\>20

overall

N (%)

1 (0.01%)

overall

Male

N (%)

22 (0.26%)

Female

N (%)

32 (0.38%)

\<=20

Male

N (%)

22 (0.26%)

Female

N (%)

31 (0.37%)

\>20

Female

N (%)

1 (0.01%)

1972-01-01 to 1972-12-31

overall

overall

N (%)

66 (0.79%)

\<=20

overall

N (%)

40 (0.48%)

\>20

overall

N (%)

26 (0.31%)

overall

Male

N (%)

32 (0.38%)

Female

N (%)

34 (0.40%)

\<=20

Male

N (%)

32 (0.38%)

Female

N (%)

8 (0.10%)

\>20

Female

N (%)

26 (0.31%)

1973-01-01 to 1973-12-31

overall

overall

N (%)

72 (0.86%)

\>20

overall

N (%)

38 (0.45%)

\<=20

overall

N (%)

34 (0.40%)

overall

Male

N (%)

34 (0.40%)

Female

N (%)

38 (0.45%)

\<=20

Male

N (%)

34 (0.40%)

\>20

Female

N (%)

38 (0.45%)

1974-01-01 to 1974-12-31

overall

overall

N (%)

80 (0.95%)

\<=20

overall

N (%)

40 (0.48%)

\>20

overall

N (%)

40 (0.48%)

overall

Male

N (%)

40 (0.48%)

Female

N (%)

40 (0.48%)

\>20

Female

N (%)

40 (0.48%)

\<=20

Male

N (%)

40 (0.48%)

1975-01-01 to 1975-12-31

overall

overall

N (%)

99 (1.18%)

\>20

overall

N (%)

42 (0.50%)

\<=20

overall

N (%)

57 (0.68%)

overall

Male

N (%)

57 (0.68%)

Female

N (%)

42 (0.50%)

\>20

Female

N (%)

42 (0.50%)

\<=20

Male

N (%)

57 (0.68%)

1976-01-01 to 1976-12-31

overall

overall

N (%)

132 (1.57%)

\>20

overall

N (%)

47 (0.56%)

\<=20

overall

N (%)

85 (1.01%)

overall

Male

N (%)

86 (1.02%)

Female

N (%)

46 (0.55%)

\<=20

Male

N (%)

85 (1.01%)

\>20

Female

N (%)

46 (0.55%)

Male

N (%)

1 (0.01%)

1977-01-01 to 1977-12-31

overall

overall

N (%)

162 (1.93%)

\<=20

overall

N (%)

82 (0.98%)

\>20

overall

N (%)

80 (0.95%)

overall

Male

N (%)

112 (1.33%)

Female

N (%)

50 (0.60%)

\>20

Male

N (%)

30 (0.36%)

Female

N (%)

50 (0.60%)

\<=20

Male

N (%)

82 (0.98%)

1978-01-01 to 1978-12-31

overall

overall

N (%)

221 (2.63%)

\>20

overall

N (%)

91 (1.08%)

\<=20

overall

N (%)

130 (1.55%)

overall

Male

N (%)

133 (1.58%)

Female

N (%)

88 (1.05%)

\>20

Male

N (%)

36 (0.43%)

Female

N (%)

55 (0.65%)

\<=20

Male

N (%)

97 (1.15%)

Female

N (%)

33 (0.39%)

1979-01-01 to 1979-12-31

overall

overall

N (%)

289 (3.44%)

\<=20

overall

N (%)

192 (2.29%)

\>20

overall

N (%)

97 (1.15%)

overall

Male

N (%)

174 (2.07%)

Female

N (%)

115 (1.37%)

\>20

Male

N (%)

43 (0.51%)

Female

N (%)

54 (0.64%)

\<=20

Male

N (%)

131 (1.56%)

Female

N (%)

61 (0.73%)

1980-01-01 to 1980-12-31

overall

overall

N (%)

249 (2.96%)

\>20

overall

N (%)

143 (1.70%)

\<=20

overall

N (%)

106 (1.26%)

overall

Male

N (%)

189 (2.25%)

Female

N (%)

60 (0.71%)

\<=20

Male

N (%)

102 (1.21%)

Female

N (%)

4 (0.05%)

\>20

Male

N (%)

87 (1.04%)

Female

N (%)

56 (0.67%)

1981-01-01 to 1981-12-31

overall

overall

N (%)

232 (2.76%)

\>20

overall

N (%)

158 (1.88%)

\<=20

overall

N (%)

74 (0.88%)

overall

Male

N (%)

171 (2.04%)

Female

N (%)

61 (0.73%)

\>20

Male

N (%)

97 (1.15%)

Female

N (%)

61 (0.73%)

\<=20

Male

N (%)

74 (0.88%)

1982-01-01 to 1982-12-31

overall

overall

N (%)

234 (2.79%)

\<=20

overall

N (%)

68 (0.81%)

\>20

overall

N (%)

166 (1.98%)

overall

Male

N (%)

172 (2.05%)

Female

N (%)

62 (0.74%)

\<=20

Male

N (%)

68 (0.81%)

\>20

Male

N (%)

104 (1.24%)

Female

N (%)

62 (0.74%)

1983-01-01 to 1983-12-31

overall

overall

N (%)

245 (2.92%)

\<=20

overall

N (%)

68 (0.81%)

\>20

overall

N (%)

177 (2.11%)

overall

Female

N (%)

68 (0.81%)

Male

N (%)

177 (2.11%)

\>20

Female

N (%)

68 (0.81%)

Male

N (%)

109 (1.30%)

\<=20

Male

N (%)

68 (0.81%)

1984-01-01 to 1984-12-31

overall

overall

N (%)

277 (3.30%)

\>20

overall

N (%)

179 (2.13%)

\<=20

overall

N (%)

98 (1.17%)

overall

Female

N (%)

69 (0.82%)

Male

N (%)

208 (2.48%)

\<=20

Male

N (%)

98 (1.17%)

\>20

Female

N (%)

69 (0.82%)

Male

N (%)

110 (1.31%)

1985-01-01 to 1985-12-31

overall

overall

N (%)

308 (3.67%)

\<=20

overall

N (%)

118 (1.40%)

\>20

overall

N (%)

190 (2.26%)

overall

Female

N (%)

80 (0.95%)

Male

N (%)

228 (2.71%)

\>20

Female

N (%)

78 (0.93%)

Male

N (%)

112 (1.33%)

\<=20

Male

N (%)

116 (1.38%)

Female

N (%)

2 (0.02%)

1986-01-01 to 1986-12-31

overall

overall

N (%)

368 (4.38%)

\<=20

overall

N (%)

134 (1.60%)

\>20

overall

N (%)

234 (2.79%)

overall

Female

N (%)

106 (1.26%)

Male

N (%)

262 (3.12%)

\>20

Female

N (%)

94 (1.12%)

Male

N (%)

140 (1.67%)

\<=20

Male

N (%)

122 (1.45%)

Female

N (%)

12 (0.14%)

1987-01-01 to 1987-12-31

overall

overall

N (%)

339 (4.04%)

\<=20

overall

N (%)

95 (1.13%)

\>20

overall

N (%)

244 (2.90%)

overall

Female

N (%)

128 (1.52%)

Male

N (%)

211 (2.51%)

\<=20

Female

N (%)

26 (0.31%)

Male

N (%)

69 (0.82%)

\>20

Female

N (%)

102 (1.21%)

Male

N (%)

142 (1.69%)

1988-01-01 to 1988-12-31

overall

overall

N (%)

378 (4.50%)

\>20

overall

N (%)

283 (3.37%)

\<=20

overall

N (%)

95 (1.13%)

overall

Female

N (%)

150 (1.79%)

Male

N (%)

228 (2.71%)

\>20

Female

N (%)

114 (1.36%)

Male

N (%)

169 (2.01%)

\<=20

Female

N (%)

36 (0.43%)

Male

N (%)

59 (0.70%)

1989-01-01 to 1989-12-31

overall

overall

N (%)

412 (4.90%)

\>20

overall

N (%)

286 (3.40%)

\<=20

overall

N (%)

126 (1.50%)

overall

Female

N (%)

160 (1.90%)

Male

N (%)

252 (3.00%)

\>20

Female

N (%)

118 (1.40%)

\<=20

Female

N (%)

42 (0.50%)

Male

N (%)

84 (1.00%)

\>20

Male

N (%)

168 (2.00%)

1990-01-01 to 1990-12-31

overall

overall

N (%)

477 (5.68%)

\<=20

overall

N (%)

160 (1.90%)

\>20

overall

N (%)

317 (3.77%)

overall

Female

N (%)

183 (2.18%)

Male

N (%)

294 (3.50%)

\>20

Female

N (%)

135 (1.61%)

Male

N (%)

182 (2.17%)

\<=20

Female

N (%)

48 (0.57%)

Male

N (%)

112 (1.33%)

1991-01-01 to 1991-12-31

overall

overall

N (%)

550 (6.55%)

\<=20

overall

N (%)

203 (2.42%)

\>20

overall

N (%)

347 (4.13%)

overall

Female

N (%)

234 (2.79%)

Male

N (%)

316 (3.76%)

\>20

Female

N (%)

166 (1.98%)

\<=20

Male

N (%)

135 (1.61%)

\>20

Male

N (%)

181 (2.15%)

\<=20

Female

N (%)

68 (0.81%)

1992-01-01 to 1992-12-31

overall

overall

N (%)

613 (7.30%)

\<=20

overall

N (%)

249 (2.96%)

\>20

overall

N (%)

364 (4.33%)

overall

Female

N (%)

273 (3.25%)

Male

N (%)

340 (4.05%)

\>20

Female

N (%)

184 (2.19%)

Male

N (%)

180 (2.14%)

\<=20

Male

N (%)

160 (1.90%)

Female

N (%)

89 (1.06%)

1993-01-01 to 1993-12-31

overall

overall

N (%)

651 (7.75%)

\>20

overall

N (%)

389 (4.63%)

\<=20

overall

N (%)

262 (3.12%)

overall

Female

N (%)

283 (3.37%)

Male

N (%)

368 (4.38%)

\>20

Female

N (%)

204 (2.43%)

\<=20

Male

N (%)

183 (2.18%)

\>20

Male

N (%)

185 (2.20%)

\<=20

Female

N (%)

79 (0.94%)

1994-01-01 to 1994-12-31

overall

overall

N (%)

778 (9.26%)

\>20

overall

N (%)

431 (5.13%)

\<=20

overall

N (%)

347 (4.13%)

overall

Female

N (%)

325 (3.87%)

Male

N (%)

453 (5.39%)

\>20

Female

N (%)

227 (2.70%)

Male

N (%)

204 (2.43%)

\<=20

Male

N (%)

249 (2.96%)

Female

N (%)

98 (1.17%)

1995-01-01 to 1995-12-31

overall

overall

N (%)

925 (11.01%)

\>20

overall

N (%)

497 (5.92%)

\<=20

overall

N (%)

428 (5.10%)

overall

Female

N (%)

394 (4.69%)

Male

N (%)

531 (6.32%)

\>20

Female

N (%)

284 (3.38%)

Male

N (%)

213 (2.54%)

\<=20

Male

N (%)

318 (3.79%)

Female

N (%)

110 (1.31%)

1996-01-01 to 1996-12-31

overall

overall

N (%)

918 (10.93%)

\<=20

overall

N (%)

428 (5.10%)

\>20

overall

N (%)

490 (5.83%)

overall

Female

N (%)

391 (4.65%)

Male

N (%)

527 (6.27%)

\<=20

Male

N (%)

313 (3.73%)

Female

N (%)

115 (1.37%)

\>20

Female

N (%)

276 (3.29%)

Male

N (%)

214 (2.55%)

1997-01-01 to 1997-12-31

overall

overall

N (%)

926 (11.02%)

\<=20

overall

N (%)

451 (5.37%)

\>20

overall

N (%)

475 (5.65%)

overall

Female

N (%)

383 (4.56%)

Male

N (%)

543 (6.46%)

\>20

Female

N (%)

248 (2.95%)

\<=20

Female

N (%)

135 (1.61%)

Male

N (%)

316 (3.76%)

\>20

Male

N (%)

227 (2.70%)

1998-01-01 to 1998-12-31

overall

overall

N (%)

1,059 (12.61%)

\<=20

overall

N (%)

457 (5.44%)

\>20

overall

N (%)

602 (7.17%)

overall

Female

N (%)

437 (5.20%)

Male

N (%)

622 (7.40%)

\>20

Female

N (%)

282 (3.36%)

Male

N (%)

320 (3.81%)

\<=20

Female

N (%)

155 (1.85%)

Male

N (%)

302 (3.60%)

1999-01-01 to 1999-12-31

overall

overall

N (%)

1,142 (13.60%)

\>20

overall

N (%)

628 (7.48%)

\<=20

overall

N (%)

514 (6.12%)

overall

Female

N (%)

516 (6.14%)

Male

N (%)

626 (7.45%)

\>20

Female

N (%)

348 (4.14%)

\<=20

Female

N (%)

168 (2.00%)

Male

N (%)

346 (4.12%)

\>20

Male

N (%)

280 (3.33%)

2000-01-01 to 2000-12-31

overall

overall

N (%)

1,197 (14.25%)

\>20

overall

N (%)

676 (8.05%)

\<=20

overall

N (%)

521 (6.20%)

overall

Female

N (%)

577 (6.87%)

Male

N (%)

620 (7.38%)

\>20

Female

N (%)

373 (4.44%)

Male

N (%)

303 (3.61%)

\<=20

Female

N (%)

204 (2.43%)

Male

N (%)

317 (3.77%)

2001-01-01 to 2001-12-31

overall

overall

N (%)

1,177 (14.01%)

\<=20

overall

N (%)

541 (6.44%)

\>20

overall

N (%)

636 (7.57%)

overall

Female

N (%)

584 (6.95%)

Male

N (%)

593 (7.06%)

\<=20

Female

N (%)

233 (2.77%)

Male

N (%)

308 (3.67%)

\>20

Female

N (%)

351 (4.18%)

Male

N (%)

285 (3.39%)

2002-01-01 to 2002-12-31

overall

overall

N (%)

1,188 (14.14%)

\<=20

overall

N (%)

596 (7.10%)

\>20

overall

N (%)

592 (7.05%)

overall

Female

N (%)

587 (6.99%)

Male

N (%)

601 (7.15%)

\>20

Female

N (%)

326 (3.88%)

\<=20

Female

N (%)

261 (3.11%)

Male

N (%)

335 (3.99%)

\>20

Male

N (%)

266 (3.17%)

2003-01-01 to 2003-12-31

overall

overall

N (%)

1,196 (14.24%)

\>20

overall

N (%)

618 (7.36%)

\<=20

overall

N (%)

578 (6.88%)

overall

Male

N (%)

645 (7.68%)

Female

N (%)

551 (6.56%)

\<=20

Male

N (%)

305 (3.63%)

Female

N (%)

273 (3.25%)

\>20

Male

N (%)

340 (4.05%)

Female

N (%)

278 (3.31%)

2004-01-01 to 2004-12-31

overall

overall

N (%)

1,142 (13.60%)

\>20

overall

N (%)

676 (8.05%)

\<=20

overall

N (%)

466 (5.55%)

overall

Male

N (%)

635 (7.56%)

Female

N (%)

507 (6.04%)

\>20

Male

N (%)

394 (4.69%)

Female

N (%)

282 (3.36%)

\<=20

Female

N (%)

225 (2.68%)

Male

N (%)

241 (2.87%)

2005-01-01 to 2005-12-31

overall

overall

N (%)

1,087 (12.94%)

\<=20

overall

N (%)

444 (5.29%)

\>20

overall

N (%)

643 (7.65%)

overall

Male

N (%)

611 (7.27%)

Female

N (%)

476 (5.67%)

\>20

Male

N (%)

395 (4.70%)

\<=20

Female

N (%)

228 (2.71%)

\>20

Female

N (%)

248 (2.95%)

\<=20

Male

N (%)

216 (2.57%)

2006-01-01 to 2006-12-31

overall

overall

N (%)

1,108 (13.19%)

\<=20

overall

N (%)

376 (4.48%)

\>20

overall

N (%)

732 (8.71%)

overall

Female

N (%)

475 (5.65%)

Male

N (%)

633 (7.54%)

\>20

Female

N (%)

249 (2.96%)

Male

N (%)

483 (5.75%)

\<=20

Male

N (%)

150 (1.79%)

Female

N (%)

226 (2.69%)

2007-01-01 to 2007-12-31

overall

overall

N (%)

1,339 (15.94%)

\<=20

overall

N (%)

502 (5.98%)

\>20

overall

N (%)

837 (9.96%)

overall

Female

N (%)

570 (6.79%)

Male

N (%)

769 (9.15%)

\<=20

Male

N (%)

176 (2.10%)

Female

N (%)

326 (3.88%)

\>20

Female

N (%)

244 (2.90%)

Male

N (%)

593 (7.06%)

2008-01-01 to 2008-12-31

overall

overall

N (%)

1,166 (13.88%)

\>20

overall

N (%)

804 (9.57%)

\<=20

overall

N (%)

362 (4.31%)

overall

Male

N (%)

684 (8.14%)

Female

N (%)

482 (5.74%)

\<=20

Female

N (%)

186 (2.21%)

Male

N (%)

176 (2.10%)

\>20

Male

N (%)

508 (6.05%)

Female

N (%)

296 (3.52%)

2009-01-01 to 2009-12-31

overall

overall

N (%)

1,240 (14.76%)

\<=20

overall

N (%)

408 (4.86%)

\>20

overall

N (%)

832 (9.90%)

overall

Male

N (%)

654 (7.79%)

Female

N (%)

586 (6.98%)

\<=20

Male

N (%)

192 (2.29%)

Female

N (%)

216 (2.57%)

\>20

Male

N (%)

462 (5.50%)

Female

N (%)

370 (4.40%)

2010-01-01 to 2010-12-31

overall

overall

N (%)

1,197 (14.25%)

\<=20

overall

N (%)

309 (3.68%)

\>20

overall

N (%)

888 (10.57%)

overall

Male

N (%)

631 (7.51%)

Female

N (%)

566 (6.74%)

\>20

Male

N (%)

451 (5.37%)

Female

N (%)

437 (5.20%)

\<=20

Male

N (%)

180 (2.14%)

Female

N (%)

129 (1.54%)

2011-01-01 to 2011-12-31

overall

overall

N (%)

1,181 (14.06%)

\>20

overall

N (%)

963 (11.46%)

\<=20

overall

N (%)

218 (2.60%)

overall

Male

N (%)

495 (5.89%)

Female

N (%)

686 (8.17%)

\<=20

Male

N (%)

107 (1.27%)

Female

N (%)

111 (1.32%)

\>20

Male

N (%)

388 (4.62%)

Female

N (%)

575 (6.85%)

2012-01-01 to 2012-12-31

overall

overall

N (%)

1,123 (13.37%)

\>20

overall

N (%)

993 (11.82%)

\<=20

overall

N (%)

130 (1.55%)

overall

Male

N (%)

443 (5.27%)

Female

N (%)

680 (8.10%)

\<=20

Male

N (%)

56 (0.67%)

Female

N (%)

74 (0.88%)

\>20

Male

N (%)

387 (4.61%)

Female

N (%)

606 (7.21%)

2013-01-01 to 2013-12-31

overall

overall

N (%)

1,079 (12.85%)

\<=20

overall

N (%)

117 (1.39%)

\>20

overall

N (%)

962 (11.45%)

overall

Male

N (%)

438 (5.21%)

Female

N (%)

641 (7.63%)

\>20

Male

N (%)

373 (4.44%)

Female

N (%)

589 (7.01%)

\<=20

Female

N (%)

52 (0.62%)

Male

N (%)

65 (0.77%)

2014-01-01 to 2014-12-31

overall

overall

N (%)

1,037 (12.35%)

\>20

overall

N (%)

858 (10.21%)

\<=20

overall

N (%)

179 (2.13%)

overall

Male

N (%)

430 (5.12%)

Female

N (%)

607 (7.23%)

\<=20

Male

N (%)

113 (1.35%)

Female

N (%)

66 (0.79%)

\>20

Male

N (%)

317 (3.77%)

Female

N (%)

541 (6.44%)

2015-01-01 to 2015-12-31

overall

overall

N (%)

757 (9.01%)

\>20

overall

N (%)

625 (7.44%)

\<=20

overall

N (%)

132 (1.57%)

overall

Male

N (%)

274 (3.26%)

Female

N (%)

483 (5.75%)

\>20

Male

N (%)

176 (2.10%)

Female

N (%)

449 (5.35%)

\<=20

Female

N (%)

34 (0.40%)

Male

N (%)

98 (1.17%)

2016-01-01 to 2016-12-31

overall

overall

N (%)

712 (8.48%)

\<=20

overall

N (%)

206 (2.45%)

\>20

overall

N (%)

506 (6.02%)

overall

Female

N (%)

537 (6.39%)

Male

N (%)

175 (2.08%)

\<=20

Female

N (%)

118 (1.40%)

Male

N (%)

88 (1.05%)

\>20

Female

N (%)

419 (4.99%)

Male

N (%)

87 (1.04%)

2017-01-01 to 2017-12-31

overall

overall

N (%)

619 (7.37%)

\<=20

overall

N (%)

172 (2.05%)

\>20

overall

N (%)

447 (5.32%)

overall

Male

N (%)

229 (2.73%)

Female

N (%)

390 (4.64%)

\<=20

Male

N (%)

115 (1.37%)

\>20

Female

N (%)

333 (3.96%)

\<=20

Female

N (%)

57 (0.68%)

\>20

Male

N (%)

114 (1.36%)

2018-01-01 to 2018-12-31

overall

overall

N (%)

578 (6.88%)

\>20

overall

N (%)

429 (5.11%)

\<=20

overall

N (%)

149 (1.77%)

overall

Male

N (%)

356 (4.24%)

Female

N (%)

222 (2.64%)

\<=20

Male

N (%)

149 (1.77%)

\>20

Male

N (%)

207 (2.46%)

Female

N (%)

222 (2.64%)

2019-01-01 to 2019-12-31

overall

overall

N (%)

462 (5.50%)

\>20

overall

N (%)

428 (5.10%)

\<=20

overall

N (%)

34 (0.40%)

overall

Male

N (%)

235 (2.80%)

Female

N (%)

227 (2.70%)

\<=20

Male

N (%)

34 (0.40%)

\>20

Female

N (%)

227 (2.70%)

Male

N (%)

201 (2.39%)

overall

overall

overall

N (%)

8,400 (100.00%)

\>20

overall

N (%)

4,981 (59.30%)

\<=20

overall

N (%)

3,419 (40.70%)

overall

Male

N (%)

4,295 (51.13%)

Female

N (%)

4,105 (48.87%)

\<=20

Female

N (%)

1,301 (15.49%)

Male

N (%)

2,118 (25.21%)

\>20

Male

N (%)

2,177 (25.92%)

Female

N (%)

2,804 (33.38%)

CDMConnector::[cdmDisconnect](https://darwin-eu.github.io/omopgenerics/reference/cdmDisconnect.html)(cdm
= cdm) \# }
