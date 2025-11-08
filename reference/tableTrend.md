# Create a visual table from a summariseTrend() result.

Create a visual table from a summariseTrend() result.

## Usage

``` r
tableTrend(result, type = "gt", style = "default")
```

## Arguments

- result:

  A summarised_result object.

- type:

  Type of formatting output table between `gt`, `datatable` and
  `reactable`. Default is `"gt"`.

- style:

  Named list that specifies how to style the different parts of the gt
  or flextable table generated. Accepted style entries are: title,
  subtitle, header, header_name, header_level, column_name, group_label,
  and body. Alternatively, use "default" to get visOmopResults style, or
  NULL for gt/flextable style. Keep in mind that styling code is
  different for gt and flextable. Additionally, "datatable" and
  "reactable" have their own style functions. To see style options for
  each table type use
  [`visOmopResults::tableStyle()`](https://darwin-eu.github.io/visOmopResults/reference/tableStyle.html)

## Value

A formatted table object with the summarised data.

## Examples

``` r
# \donttest{
library(OmopSketch)
library(dplyr, warn.conflicts = FALSE)

cdm <- mockOmopSketch()
#> ℹ Reading GiBleed tables.

summarisedResult <- summariseTrend(
  cdm = cdm,
  episode = "observation_period",
  event = c("drug_exposure", "condition_occurrence"),
  interval = "years",
  ageGroup = list("<=20" = c(0, 20), ">20" = c(21, Inf)),
  sex = TRUE
)

tableTrend(result = summarisedResult)


  
Summary of Number of records by years in drug_exposure, condition_occurrence, observation_period tables

  

Variable name
```

Time interval

Age group

Sex

Estimate name

Database name

mockOmopSketch

event; drug_exposure

Number of records

1957-01-01 to 1957-12-31

overall

overall

N (%)

4 (0.02%)

\<=20

overall

N (%)

4 (0.02%)

overall

Male

N (%)

4 (0.02%)

\<=20

Male

N (%)

4 (0.02%)

1958-01-01 to 1958-12-31

overall

overall

N (%)

9 (0.04%)

\<=20

overall

N (%)

9 (0.04%)

overall

Male

N (%)

9 (0.04%)

\<=20

Male

N (%)

9 (0.04%)

1959-01-01 to 1959-12-31

overall

overall

N (%)

46 (0.21%)

\<=20

overall

N (%)

46 (0.21%)

overall

Female

N (%)

36 (0.17%)

Male

N (%)

10 (0.05%)

\<=20

Male

N (%)

10 (0.05%)

Female

N (%)

36 (0.17%)

1960-01-01 to 1960-12-31

overall

overall

N (%)

51 (0.24%)

\<=20

overall

N (%)

51 (0.24%)

overall

Female

N (%)

44 (0.20%)

Male

N (%)

7 (0.03%)

\<=20

Male

N (%)

7 (0.03%)

Female

N (%)

44 (0.20%)

1961-01-01 to 1961-12-31

overall

overall

N (%)

39 (0.18%)

\<=20

overall

N (%)

39 (0.18%)

overall

Male

N (%)

6 (0.03%)

Female

N (%)

33 (0.15%)

\<=20

Female

N (%)

33 (0.15%)

Male

N (%)

6 (0.03%)

1962-01-01 to 1962-12-31

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

27 (0.12%)

Male

N (%)

7 (0.03%)

\<=20

Male

N (%)

7 (0.03%)

Female

N (%)

27 (0.12%)

1963-01-01 to 1963-12-31

overall

overall

N (%)

66 (0.31%)

\<=20

overall

N (%)

66 (0.31%)

overall

Male

N (%)

9 (0.04%)

Female

N (%)

57 (0.26%)

\<=20

Female

N (%)

57 (0.26%)

Male

N (%)

9 (0.04%)

1964-01-01 to 1964-12-31

overall

overall

N (%)

91 (0.42%)

\<=20

overall

N (%)

91 (0.42%)

overall

Female

N (%)

81 (0.38%)

Male

N (%)

10 (0.05%)

\<=20

Female

N (%)

81 (0.38%)

Male

N (%)

10 (0.05%)

1965-01-01 to 1965-12-31

overall

overall

N (%)

53 (0.25%)

\<=20

overall

N (%)

53 (0.25%)

overall

Male

N (%)

12 (0.06%)

Female

N (%)

41 (0.19%)

\<=20

Female

N (%)

41 (0.19%)

Male

N (%)

12 (0.06%)

1966-01-01 to 1966-12-31

overall

overall

N (%)

73 (0.34%)

\<=20

overall

N (%)

73 (0.34%)

overall

Female

N (%)

65 (0.30%)

Male

N (%)

8 (0.04%)

\<=20

Male

N (%)

8 (0.04%)

Female

N (%)

65 (0.30%)

1967-01-01 to 1967-12-31

overall

overall

N (%)

67 (0.31%)

\<=20

overall

N (%)

67 (0.31%)

overall

Female

N (%)

56 (0.26%)

Male

N (%)

11 (0.05%)

\<=20

Male

N (%)

11 (0.05%)

Female

N (%)

56 (0.26%)

1968-01-01 to 1968-12-31

overall

overall

N (%)

72 (0.33%)

\<=20

overall

N (%)

72 (0.33%)

overall

Male

N (%)

11 (0.05%)

Female

N (%)

61 (0.28%)

\<=20

Male

N (%)

11 (0.05%)

Female

N (%)

61 (0.28%)

1969-01-01 to 1969-12-31

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

28 (0.13%)

Male

N (%)

14 (0.06%)

\<=20

Male

N (%)

14 (0.06%)

Female

N (%)

28 (0.13%)

1970-01-01 to 1970-12-31

overall

overall

N (%)

51 (0.24%)

\<=20

overall

N (%)

51 (0.24%)

overall

Male

N (%)

22 (0.10%)

Female

N (%)

29 (0.13%)

\<=20

Female

N (%)

29 (0.13%)

Male

N (%)

22 (0.10%)

1971-01-01 to 1971-12-31

overall

overall

N (%)

55 (0.25%)

\>20

overall

N (%)

1 (0.00%)

\<=20

overall

N (%)

54 (0.25%)

overall

Female

N (%)

34 (0.16%)

Male

N (%)

21 (0.10%)

\<=20

Male

N (%)

21 (0.10%)

Female

N (%)

33 (0.15%)

\>20

Female

N (%)

1 (0.00%)

1972-01-01 to 1972-12-31

overall

overall

N (%)

88 (0.41%)

\<=20

overall

N (%)

65 (0.30%)

\>20

overall

N (%)

23 (0.11%)

overall

Male

N (%)

38 (0.18%)

Female

N (%)

50 (0.23%)

\<=20

Female

N (%)

34 (0.16%)

\>20

Female

N (%)

16 (0.07%)

\<=20

Male

N (%)

31 (0.14%)

\>20

Male

N (%)

7 (0.03%)

1973-01-01 to 1973-12-31

overall

overall

N (%)

84 (0.39%)

\>20

overall

N (%)

28 (0.13%)

\<=20

overall

N (%)

56 (0.26%)

overall

Female

N (%)

50 (0.23%)

Male

N (%)

34 (0.16%)

\<=20

Male

N (%)

21 (0.10%)

\>20

Male

N (%)

13 (0.06%)

Female

N (%)

15 (0.07%)

\<=20

Female

N (%)

35 (0.16%)

1974-01-01 to 1974-12-31

overall

overall

N (%)

75 (0.35%)

\>20

overall

N (%)

24 (0.11%)

\<=20

overall

N (%)

51 (0.24%)

overall

Female

N (%)

47 (0.22%)

Male

N (%)

28 (0.13%)

\<=20

Male

N (%)

18 (0.08%)

\>20

Male

N (%)

10 (0.05%)

\<=20

Female

N (%)

33 (0.15%)

\>20

Female

N (%)

14 (0.06%)

1975-01-01 to 1975-12-31

overall

overall

N (%)

103 (0.48%)

\<=20

overall

N (%)

69 (0.32%)

\>20

overall

N (%)

34 (0.16%)

overall

Female

N (%)

57 (0.26%)

Male

N (%)

46 (0.21%)

\<=20

Female

N (%)

38 (0.18%)

\>20

Female

N (%)

19 (0.09%)

Male

N (%)

15 (0.07%)

\<=20

Male

N (%)

31 (0.14%)

1976-01-01 to 1976-12-31

overall

overall

N (%)

198 (0.92%)

\<=20

overall

N (%)

159 (0.74%)

\>20

overall

N (%)

39 (0.18%)

overall

Male

N (%)

65 (0.30%)

Female

N (%)

133 (0.62%)

\>20

Female

N (%)

23 (0.11%)

\<=20

Female

N (%)

110 (0.51%)

Male

N (%)

49 (0.23%)

\>20

Male

N (%)

16 (0.07%)

1977-01-01 to 1977-12-31

overall

overall

N (%)

249 (1.15%)

\>20

overall

N (%)

30 (0.14%)

\<=20

overall

N (%)

219 (1.01%)

overall

Male

N (%)

64 (0.30%)

Female

N (%)

185 (0.86%)

\>20

Male

N (%)

8 (0.04%)

\<=20

Male

N (%)

56 (0.26%)

Female

N (%)

163 (0.75%)

\>20

Female

N (%)

22 (0.10%)

1978-01-01 to 1978-12-31

overall

overall

N (%)

194 (0.90%)

\<=20

overall

N (%)

163 (0.75%)

\>20

overall

N (%)

31 (0.14%)

overall

Male

N (%)

56 (0.26%)

Female

N (%)

138 (0.64%)

\>20

Female

N (%)

24 (0.11%)

\<=20

Female

N (%)

114 (0.53%)

Male

N (%)

49 (0.23%)

\>20

Male

N (%)

7 (0.03%)

1979-01-01 to 1979-12-31

overall

overall

N (%)

205 (0.95%)

\<=20

overall

N (%)

159 (0.74%)

\>20

overall

N (%)

46 (0.21%)

overall

Female

N (%)

126 (0.58%)

Male

N (%)

79 (0.37%)

\<=20

Female

N (%)

90 (0.42%)

\>20

Female

N (%)

36 (0.17%)

Male

N (%)

10 (0.05%)

\<=20

Male

N (%)

69 (0.32%)

1980-01-01 to 1980-12-31

overall

overall

N (%)

201 (0.93%)

\>20

overall

N (%)

49 (0.23%)

\<=20

overall

N (%)

152 (0.70%)

overall

Female

N (%)

107 (0.50%)

Male

N (%)

94 (0.44%)

\<=20

Male

N (%)

94 (0.44%)

\>20

Female

N (%)

49 (0.23%)

\<=20

Female

N (%)

58 (0.27%)

1981-01-01 to 1981-12-31

overall

overall

N (%)

165 (0.76%)

\<=20

overall

N (%)

95 (0.44%)

\>20

overall

N (%)

70 (0.32%)

overall

Male

N (%)

71 (0.33%)

Female

N (%)

94 (0.44%)

\>20

Female

N (%)

70 (0.32%)

\<=20

Female

N (%)

24 (0.11%)

Male

N (%)

71 (0.33%)

1982-01-01 to 1982-12-31

overall

overall

N (%)

192 (0.89%)

\<=20

overall

N (%)

105 (0.49%)

\>20

overall

N (%)

87 (0.40%)

overall

Female

N (%)

121 (0.56%)

Male

N (%)

71 (0.33%)

\<=20

Female

N (%)

37 (0.17%)

\>20

Female

N (%)

84 (0.39%)

Male

N (%)

3 (0.01%)

\<=20

Male

N (%)

68 (0.31%)

1983-01-01 to 1983-12-31

overall

overall

N (%)

156 (0.72%)

\<=20

overall

N (%)

103 (0.48%)

\>20

overall

N (%)

53 (0.25%)

overall

Male

N (%)

67 (0.31%)

Female

N (%)

89 (0.41%)

\<=20

Female

N (%)

52 (0.24%)

\>20

Female

N (%)

37 (0.17%)

\<=20

Male

N (%)

51 (0.24%)

\>20

Male

N (%)

16 (0.07%)

1984-01-01 to 1984-12-31

overall

overall

N (%)

148 (0.69%)

\>20

overall

N (%)

59 (0.27%)

\<=20

overall

N (%)

89 (0.41%)

overall

Male

N (%)

60 (0.28%)

Female

N (%)

88 (0.41%)

\>20

Male

N (%)

26 (0.12%)

\<=20

Male

N (%)

34 (0.16%)

Female

N (%)

55 (0.25%)

\>20

Female

N (%)

33 (0.15%)

1985-01-01 to 1985-12-31

overall

overall

N (%)

140 (0.65%)

\>20

overall

N (%)

72 (0.33%)

\<=20

overall

N (%)

68 (0.31%)

overall

Female

N (%)

105 (0.49%)

Male

N (%)

35 (0.16%)

\<=20

Male

N (%)

20 (0.09%)

\>20

Male

N (%)

15 (0.07%)

\<=20

Female

N (%)

48 (0.22%)

\>20

Female

N (%)

57 (0.26%)

1986-01-01 to 1986-12-31

overall

overall

N (%)

165 (0.76%)

\>20

overall

N (%)

77 (0.36%)

\<=20

overall

N (%)

88 (0.41%)

overall

Female

N (%)

109 (0.50%)

Male

N (%)

56 (0.26%)

\<=20

Male

N (%)

21 (0.10%)

\>20

Male

N (%)

35 (0.16%)

\<=20

Female

N (%)

67 (0.31%)

\>20

Female

N (%)

42 (0.19%)

1987-01-01 to 1987-12-31

overall

overall

N (%)

131 (0.61%)

\<=20

overall

N (%)

75 (0.35%)

\>20

overall

N (%)

56 (0.26%)

overall

Female

N (%)

76 (0.35%)

Male

N (%)

55 (0.25%)

\>20

Female

N (%)

31 (0.14%)

\<=20

Female

N (%)

45 (0.21%)

\>20

Male

N (%)

25 (0.12%)

\<=20

Male

N (%)

30 (0.14%)

1988-01-01 to 1988-12-31

overall

overall

N (%)

115 (0.53%)

\>20

overall

N (%)

52 (0.24%)

\<=20

overall

N (%)

63 (0.29%)

overall

Female

N (%)

77 (0.36%)

Male

N (%)

38 (0.18%)

\<=20

Male

N (%)

20 (0.09%)

\>20

Male

N (%)

18 (0.08%)

\<=20

Female

N (%)

43 (0.20%)

\>20

Female

N (%)

34 (0.16%)

1989-01-01 to 1989-12-31

overall

overall

N (%)

190 (0.88%)

\<=20

overall

N (%)

116 (0.54%)

\>20

overall

N (%)

74 (0.34%)

overall

Female

N (%)

76 (0.35%)

Male

N (%)

114 (0.53%)

\<=20

Female

N (%)

37 (0.17%)

\>20

Female

N (%)

39 (0.18%)

Male

N (%)

35 (0.16%)

\<=20

Male

N (%)

79 (0.37%)

1990-01-01 to 1990-12-31

overall

overall

N (%)

387 (1.79%)

\<=20

overall

N (%)

284 (1.31%)

\>20

overall

N (%)

103 (0.48%)

overall

Male

N (%)

298 (1.38%)

Female

N (%)

89 (0.41%)

\>20

Female

N (%)

48 (0.22%)

\<=20

Female

N (%)

41 (0.19%)

Male

N (%)

243 (1.12%)

\>20

Male

N (%)

55 (0.25%)

1991-01-01 to 1991-12-31

overall

overall

N (%)

408 (1.89%)

\>20

overall

N (%)

114 (0.53%)

\<=20

overall

N (%)

294 (1.36%)

overall

Male

N (%)

187 (0.87%)

Female

N (%)

221 (1.02%)

\>20

Male

N (%)

50 (0.23%)

\<=20

Male

N (%)

137 (0.63%)

Female

N (%)

157 (0.73%)

\>20

Female

N (%)

64 (0.30%)

1992-01-01 to 1992-12-31

overall

overall

N (%)

352 (1.63%)

\<=20

overall

N (%)

221 (1.02%)

\>20

overall

N (%)

131 (0.61%)

overall

Male

N (%)

177 (0.82%)

Female

N (%)

175 (0.81%)

\<=20

Female

N (%)

120 (0.56%)

\>20

Female

N (%)

55 (0.25%)

\<=20

Male

N (%)

101 (0.47%)

\>20

Male

N (%)

76 (0.35%)

1993-01-01 to 1993-12-31

overall

overall

N (%)

293 (1.36%)

\>20

overall

N (%)

193 (0.89%)

\<=20

overall

N (%)

100 (0.46%)

overall

Female

N (%)

116 (0.54%)

Male

N (%)

177 (0.82%)

\<=20

Male

N (%)

43 (0.20%)

\>20

Male

N (%)

134 (0.62%)

Female

N (%)

59 (0.27%)

\<=20

Female

N (%)

57 (0.26%)

1994-01-01 to 1994-12-31

overall

overall

N (%)

286 (1.32%)

\>20

overall

N (%)

201 (0.93%)

\<=20

overall

N (%)

85 (0.39%)

overall

Male

N (%)

190 (0.88%)

Female

N (%)

96 (0.44%)

\>20

Male

N (%)

149 (0.69%)

\<=20

Male

N (%)

41 (0.19%)

Female

N (%)

44 (0.20%)

\>20

Female

N (%)

52 (0.24%)

1995-01-01 to 1995-12-31

overall

overall

N (%)

266 (1.23%)

\>20

overall

N (%)

196 (0.91%)

\<=20

overall

N (%)

70 (0.32%)

overall

Female

N (%)

159 (0.74%)

Male

N (%)

107 (0.50%)

\<=20

Male

N (%)

8 (0.04%)

\>20

Male

N (%)

99 (0.46%)

\<=20

Female

N (%)

62 (0.29%)

\>20

Female

N (%)

97 (0.45%)

1996-01-01 to 1996-12-31

overall

overall

N (%)

328 (1.52%)

\>20

overall

N (%)

227 (1.05%)

\<=20

overall

N (%)

101 (0.47%)

overall

Female

N (%)

214 (0.99%)

Male

N (%)

114 (0.53%)

\<=20

Male

N (%)

5 (0.02%)

\>20

Male

N (%)

109 (0.50%)

Female

N (%)

118 (0.55%)

\<=20

Female

N (%)

96 (0.44%)

1997-01-01 to 1997-12-31

overall

overall

N (%)

388 (1.80%)

\>20

overall

N (%)

287 (1.33%)

\<=20

overall

N (%)

101 (0.47%)

overall

Female

N (%)

252 (1.17%)

Male

N (%)

136 (0.63%)

\<=20

Male

N (%)

4 (0.02%)

\>20

Male

N (%)

132 (0.61%)

\<=20

Female

N (%)

97 (0.45%)

\>20

Female

N (%)

155 (0.72%)

1998-01-01 to 1998-12-31

overall

overall

N (%)

457 (2.12%)

\>20

overall

N (%)

307 (1.42%)

\<=20

overall

N (%)

150 (0.69%)

overall

Female

N (%)

296 (1.37%)

Male

N (%)

161 (0.75%)

\<=20

Male

N (%)

9 (0.04%)

\>20

Male

N (%)

152 (0.70%)

\<=20

Female

N (%)

141 (0.65%)

\>20

Female

N (%)

155 (0.72%)

1999-01-01 to 1999-12-31

overall

overall

N (%)

794 (3.68%)

\>20

overall

N (%)

401 (1.86%)

\<=20

overall

N (%)

393 (1.82%)

overall

Male

N (%)

273 (1.26%)

Female

N (%)

521 (2.41%)

\>20

Male

N (%)

250 (1.16%)

\<=20

Male

N (%)

23 (0.11%)

Female

N (%)

370 (1.71%)

\>20

Female

N (%)

151 (0.70%)

2000-01-01 to 2000-12-31

overall

overall

N (%)

645 (2.99%)

\<=20

overall

N (%)

186 (0.86%)

\>20

overall

N (%)

459 (2.12%)

overall

Male

N (%)

369 (1.71%)

Female

N (%)

276 (1.28%)

\>20

Female

N (%)

106 (0.49%)

\<=20

Female

N (%)

170 (0.79%)

Male

N (%)

16 (0.07%)

\>20

Male

N (%)

353 (1.63%)

2001-01-01 to 2001-12-31

overall

overall

N (%)

584 (2.70%)

\>20

overall

N (%)

414 (1.92%)

\<=20

overall

N (%)

170 (0.79%)

overall

Female

N (%)

224 (1.04%)

Male

N (%)

360 (1.67%)

\<=20

Male

N (%)

32 (0.15%)

\>20

Male

N (%)

328 (1.52%)

\<=20

Female

N (%)

138 (0.64%)

\>20

Female

N (%)

86 (0.40%)

2002-01-01 to 2002-12-31

overall

overall

N (%)

512 (2.37%)

\>20

overall

N (%)

334 (1.55%)

\<=20

overall

N (%)

178 (0.82%)

overall

Male

N (%)

256 (1.19%)

Female

N (%)

256 (1.19%)

\>20

Male

N (%)

223 (1.03%)

\<=20

Male

N (%)

33 (0.15%)

Female

N (%)

145 (0.67%)

\>20

Female

N (%)

111 (0.51%)

2003-01-01 to 2003-12-31

overall

overall

N (%)

627 (2.90%)

\<=20

overall

N (%)

202 (0.94%)

\>20

overall

N (%)

425 (1.97%)

overall

Male

N (%)

267 (1.24%)

Female

N (%)

360 (1.67%)

\<=20

Female

N (%)

156 (0.72%)

\>20

Female

N (%)

204 (0.94%)

\<=20

Male

N (%)

46 (0.21%)

\>20

Male

N (%)

221 (1.02%)

2004-01-01 to 2004-12-31

overall

overall

N (%)

528 (2.44%)

\<=20

overall

N (%)

172 (0.80%)

\>20

overall

N (%)

356 (1.65%)

overall

Female

N (%)

257 (1.19%)

Male

N (%)

271 (1.25%)

\>20

Female

N (%)

159 (0.74%)

\<=20

Female

N (%)

98 (0.45%)

\>20

Male

N (%)

197 (0.91%)

\<=20

Male

N (%)

74 (0.34%)

2005-01-01 to 2005-12-31

overall

overall

N (%)

635 (2.94%)

\>20

overall

N (%)

442 (2.05%)

\<=20

overall

N (%)

193 (0.89%)

overall

Female

N (%)

353 (1.63%)

Male

N (%)

282 (1.31%)

\<=20

Male

N (%)

79 (0.37%)

\>20

Male

N (%)

203 (0.94%)

\<=20

Female

N (%)

114 (0.53%)

\>20

Female

N (%)

239 (1.11%)

2006-01-01 to 2006-12-31

overall

overall

N (%)

638 (2.95%)

\>20

overall

N (%)

442 (2.05%)

\<=20

overall

N (%)

196 (0.91%)

overall

Male

N (%)

364 (1.69%)

Female

N (%)

274 (1.27%)

\>20

Male

N (%)

243 (1.12%)

\<=20

Male

N (%)

121 (0.56%)

\>20

Female

N (%)

199 (0.92%)

\<=20

Female

N (%)

75 (0.35%)

2007-01-01 to 2007-12-31

overall

overall

N (%)

676 (3.13%)

\>20

overall

N (%)

491 (2.27%)

\<=20

overall

N (%)

185 (0.86%)

overall

Male

N (%)

390 (1.81%)

Female

N (%)

286 (1.32%)

\>20

Male

N (%)

250 (1.16%)

\<=20

Male

N (%)

140 (0.65%)

\>20

Female

N (%)

241 (1.12%)

\<=20

Female

N (%)

45 (0.21%)

2008-01-01 to 2008-12-31

overall

overall

N (%)

622 (2.88%)

\>20

overall

N (%)

394 (1.82%)

\<=20

overall

N (%)

228 (1.06%)

overall

Female

N (%)

213 (0.99%)

Male

N (%)

409 (1.89%)

\<=20

Male

N (%)

184 (0.85%)

\>20

Male

N (%)

225 (1.04%)

\<=20

Female

N (%)

44 (0.20%)

\>20

Female

N (%)

169 (0.78%)

2009-01-01 to 2009-12-31

overall

overall

N (%)

569 (2.63%)

\<=20

overall

N (%)

165 (0.76%)

\>20

overall

N (%)

404 (1.87%)

overall

Male

N (%)

396 (1.83%)

Female

N (%)

173 (0.80%)

\>20

Female

N (%)

138 (0.64%)

\<=20

Female

N (%)

35 (0.16%)

Male

N (%)

130 (0.60%)

\>20

Male

N (%)

266 (1.23%)

2010-01-01 to 2010-12-31

overall

overall

N (%)

512 (2.37%)

\<=20

overall

N (%)

70 (0.32%)

\>20

overall

N (%)

442 (2.05%)

overall

Male

N (%)

362 (1.68%)

Female

N (%)

150 (0.69%)

\>20

Female

N (%)

128 (0.59%)

\<=20

Female

N (%)

22 (0.10%)

Male

N (%)

48 (0.22%)

\>20

Male

N (%)

314 (1.45%)

2011-01-01 to 2011-12-31

overall

overall

N (%)

510 (2.36%)

\<=20

overall

N (%)

95 (0.44%)

\>20

overall

N (%)

415 (1.92%)

overall

Female

N (%)

123 (0.57%)

Male

N (%)

387 (1.79%)

\<=20

Female

N (%)

52 (0.24%)

\>20

Female

N (%)

71 (0.33%)

Male

N (%)

344 (1.59%)

\<=20

Male

N (%)

43 (0.20%)

2012-01-01 to 2012-12-31

overall

overall

N (%)

477 (2.21%)

\<=20

overall

N (%)

171 (0.79%)

\>20

overall

N (%)

306 (1.42%)

overall

Female

N (%)

213 (0.99%)

Male

N (%)

264 (1.22%)

\>20

Female

N (%)

109 (0.50%)

\<=20

Female

N (%)

104 (0.48%)

\>20

Male

N (%)

197 (0.91%)

\<=20

Male

N (%)

67 (0.31%)

2013-01-01 to 2013-12-31

overall

overall

N (%)

748 (3.46%)

\<=20

overall

N (%)

197 (0.91%)

\>20

overall

N (%)

551 (2.55%)

overall

Male

N (%)

444 (2.06%)

Female

N (%)

304 (1.41%)

\>20

Female

N (%)

163 (0.75%)

\<=20

Female

N (%)

141 (0.65%)

Male

N (%)

56 (0.26%)

\>20

Male

N (%)

388 (1.80%)

2014-01-01 to 2014-12-31

overall

overall

N (%)

1,044 (4.83%)

\>20

overall

N (%)

817 (3.78%)

\<=20

overall

N (%)

227 (1.05%)

overall

Male

N (%)

399 (1.85%)

Female

N (%)

645 (2.99%)

\>20

Male

N (%)

363 (1.68%)

\<=20

Male

N (%)

36 (0.17%)

\>20

Female

N (%)

454 (2.10%)

\<=20

Female

N (%)

191 (0.88%)

2015-01-01 to 2015-12-31

overall

overall

N (%)

701 (3.25%)

\<=20

overall

N (%)

162 (0.75%)

\>20

overall

N (%)

539 (2.50%)

overall

Male

N (%)

290 (1.34%)

Female

N (%)

411 (1.90%)

\>20

Female

N (%)

285 (1.32%)

\<=20

Female

N (%)

126 (0.58%)

Male

N (%)

36 (0.17%)

\>20

Male

N (%)

254 (1.18%)

2016-01-01 to 2016-12-31

overall

overall

N (%)

749 (3.47%)

\<=20

overall

N (%)

57 (0.26%)

\>20

overall

N (%)

692 (3.20%)

overall

Male

N (%)

323 (1.50%)

Female

N (%)

426 (1.97%)

\>20

Female

N (%)

410 (1.90%)

\<=20

Female

N (%)

16 (0.07%)

Male

N (%)

41 (0.19%)

\>20

Male

N (%)

282 (1.31%)

2017-01-01 to 2017-12-31

overall

overall

N (%)

986 (4.56%)

\<=20

overall

N (%)

48 (0.22%)

\>20

overall

N (%)

938 (4.34%)

overall

Female

N (%)

387 (1.79%)

Male

N (%)

599 (2.77%)

\>20

Female

N (%)

387 (1.79%)

Male

N (%)

551 (2.55%)

\<=20

Male

N (%)

48 (0.22%)

2018-01-01 to 2018-12-31

overall

overall

N (%)

1,034 (4.79%)

\>20

overall

N (%)

886 (4.10%)

\<=20

overall

N (%)

148 (0.69%)

overall

Female

N (%)

473 (2.19%)

Male

N (%)

561 (2.60%)

\<=20

Male

N (%)

148 (0.69%)

\>20

Male

N (%)

413 (1.91%)

Female

N (%)

473 (2.19%)

2019-01-01 to 2019-12-31

overall

overall

N (%)

1,292 (5.98%)

\>20

overall

N (%)

1,292 (5.98%)

overall

Male

N (%)

779 (3.61%)

Female

N (%)

513 (2.38%)

\>20

Female

N (%)

513 (2.38%)

Male

N (%)

779 (3.61%)

overall

overall

overall

N (%)

21,600 (100.00%)

\>20

overall

N (%)

14,104 (65.30%)

\<=20

overall

N (%)

7,496 (34.70%)

overall

Female

N (%)

10,776 (49.89%)

Male

N (%)

10,824 (50.11%)

\>20

Female

N (%)

6,245 (28.91%)

Male

N (%)

7,859 (36.38%)

\<=20

Female

N (%)

4,531 (20.98%)

Male

N (%)

2,965 (13.73%)

event; condition_occurrence

Number of records

1957-01-01 to 1957-12-31

overall

overall

N (%)

2 (0.02%)

\<=20

overall

N (%)

2 (0.02%)

overall

Male

N (%)

2 (0.02%)

\<=20

Male

N (%)

2 (0.02%)

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

Male

N (%)

7 (0.08%)

\<=20

Male

N (%)

7 (0.08%)

1959-01-01 to 1959-12-31

overall

overall

N (%)

17 (0.20%)

\<=20

overall

N (%)

17 (0.20%)

overall

Female

N (%)

16 (0.19%)

Male

N (%)

1 (0.01%)

\<=20

Male

N (%)

1 (0.01%)

Female

N (%)

16 (0.19%)

1960-01-01 to 1960-12-31

overall

overall

N (%)

14 (0.17%)

\<=20

overall

N (%)

14 (0.17%)

overall

Female

N (%)

8 (0.10%)

Male

N (%)

6 (0.07%)

\<=20

Male

N (%)

6 (0.07%)

Female

N (%)

8 (0.10%)

1961-01-01 to 1961-12-31

overall

overall

N (%)

24 (0.29%)

\<=20

overall

N (%)

24 (0.29%)

overall

Female

N (%)

20 (0.24%)

Male

N (%)

4 (0.05%)

\<=20

Female

N (%)

20 (0.24%)

Male

N (%)

4 (0.05%)

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

Female

N (%)

12 (0.14%)

Male

N (%)

5 (0.06%)

\<=20

Male

N (%)

5 (0.06%)

Female

N (%)

12 (0.14%)

1963-01-01 to 1963-12-31

overall

overall

N (%)

30 (0.36%)

\<=20

overall

N (%)

30 (0.36%)

overall

Female

N (%)

27 (0.32%)

Male

N (%)

3 (0.04%)

\<=20

Female

N (%)

27 (0.32%)

Male

N (%)

3 (0.04%)

1964-01-01 to 1964-12-31

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

2 (0.02%)

Female

N (%)

39 (0.46%)

\<=20

Female

N (%)

39 (0.46%)

Male

N (%)

2 (0.02%)

1965-01-01 to 1965-12-31

overall

overall

N (%)

24 (0.29%)

\<=20

overall

N (%)

24 (0.29%)

overall

Female

N (%)

16 (0.19%)

Male

N (%)

8 (0.10%)

\<=20

Female

N (%)

16 (0.19%)

Male

N (%)

8 (0.10%)

1966-01-01 to 1966-12-31

overall

overall

N (%)

25 (0.30%)

\<=20

overall

N (%)

25 (0.30%)

overall

Female

N (%)

23 (0.27%)

Male

N (%)

2 (0.02%)

\<=20

Male

N (%)

2 (0.02%)

Female

N (%)

23 (0.27%)

1967-01-01 to 1967-12-31

overall

overall

N (%)

37 (0.44%)

\<=20

overall

N (%)

37 (0.44%)

overall

Female

N (%)

36 (0.43%)

Male

N (%)

1 (0.01%)

\<=20

Male

N (%)

1 (0.01%)

Female

N (%)

36 (0.43%)

1968-01-01 to 1968-12-31

overall

overall

N (%)

26 (0.31%)

\<=20

overall

N (%)

26 (0.31%)

overall

Male

N (%)

3 (0.04%)

Female

N (%)

23 (0.27%)

\<=20

Male

N (%)

3 (0.04%)

Female

N (%)

23 (0.27%)

1969-01-01 to 1969-12-31

overall

overall

N (%)

18 (0.21%)

\<=20

overall

N (%)

18 (0.21%)

overall

Female

N (%)

15 (0.18%)

Male

N (%)

3 (0.04%)

\<=20

Male

N (%)

3 (0.04%)

Female

N (%)

15 (0.18%)

1970-01-01 to 1970-12-31

overall

overall

N (%)

27 (0.32%)

\<=20

overall

N (%)

27 (0.32%)

overall

Female

N (%)

15 (0.18%)

Male

N (%)

12 (0.14%)

\<=20

Female

N (%)

15 (0.18%)

Male

N (%)

12 (0.14%)

1971-01-01 to 1971-12-31

overall

overall

N (%)

27 (0.32%)

\<=20

overall

N (%)

27 (0.32%)

overall

Female

N (%)

14 (0.17%)

Male

N (%)

13 (0.15%)

\<=20

Male

N (%)

13 (0.15%)

Female

N (%)

14 (0.17%)

1972-01-01 to 1972-12-31

overall

overall

N (%)

17 (0.20%)

\<=20

overall

N (%)

12 (0.14%)

\>20

overall

N (%)

5 (0.06%)

overall

Female

N (%)

7 (0.08%)

Male

N (%)

10 (0.12%)

\>20

Female

N (%)

3 (0.04%)

\<=20

Female

N (%)

4 (0.05%)

Male

N (%)

8 (0.10%)

\>20

Male

N (%)

2 (0.02%)

1973-01-01 to 1973-12-31

overall

overall

N (%)

38 (0.45%)

\>20

overall

N (%)

11 (0.13%)

\<=20

overall

N (%)

27 (0.32%)

overall

Female

N (%)

26 (0.31%)

Male

N (%)

12 (0.14%)

\>20

Male

N (%)

5 (0.06%)

\<=20

Male

N (%)

7 (0.08%)

Female

N (%)

20 (0.24%)

\>20

Female

N (%)

6 (0.07%)

1974-01-01 to 1974-12-31

overall

overall

N (%)

30 (0.36%)

\>20

overall

N (%)

9 (0.11%)

\<=20

overall

N (%)

21 (0.25%)

overall

Female

N (%)

18 (0.21%)

Male

N (%)

12 (0.14%)

\>20

Male

N (%)

6 (0.07%)

\<=20

Male

N (%)

6 (0.07%)

\>20

Female

N (%)

3 (0.04%)

\<=20

Female

N (%)

15 (0.18%)

1975-01-01 to 1975-12-31

overall

overall

N (%)

31 (0.37%)

\<=20

overall

N (%)

24 (0.29%)

\>20

overall

N (%)

7 (0.08%)

overall

Male

N (%)

15 (0.18%)

Female

N (%)

16 (0.19%)

\>20

Female

N (%)

4 (0.05%)

\<=20

Female

N (%)

12 (0.14%)

\>20

Male

N (%)

3 (0.04%)

\<=20

Male

N (%)

12 (0.14%)

1976-01-01 to 1976-12-31

overall

overall

N (%)

74 (0.88%)

\<=20

overall

N (%)

64 (0.76%)

\>20

overall

N (%)

10 (0.12%)

overall

Female

N (%)

49 (0.58%)

Male

N (%)

25 (0.30%)

\<=20

Female

N (%)

41 (0.49%)

\>20

Female

N (%)

8 (0.10%)

\<=20

Male

N (%)

23 (0.27%)

\>20

Male

N (%)

2 (0.02%)

1977-01-01 to 1977-12-31

overall

overall

N (%)

91 (1.08%)

\>20

overall

N (%)

19 (0.23%)

\<=20

overall

N (%)

72 (0.86%)

overall

Male

N (%)

28 (0.33%)

Female

N (%)

63 (0.75%)

\<=20

Male

N (%)

23 (0.27%)

\>20

Male

N (%)

5 (0.06%)

\<=20

Female

N (%)

49 (0.58%)

\>20

Female

N (%)

14 (0.17%)

1978-01-01 to 1978-12-31

overall

overall

N (%)

62 (0.74%)

\<=20

overall

N (%)

53 (0.63%)

\>20

overall

N (%)

9 (0.11%)

overall

Female

N (%)

40 (0.48%)

Male

N (%)

22 (0.26%)

\<=20

Female

N (%)

35 (0.42%)

\>20

Female

N (%)

5 (0.06%)

\<=20

Male

N (%)

18 (0.21%)

\>20

Male

N (%)

4 (0.05%)

1979-01-01 to 1979-12-31

overall

overall

N (%)

83 (0.99%)

\<=20

overall

N (%)

69 (0.82%)

\>20

overall

N (%)

14 (0.17%)

overall

Male

N (%)

32 (0.38%)

Female

N (%)

51 (0.61%)

\<=20

Female

N (%)

40 (0.48%)

\>20

Female

N (%)

11 (0.13%)

Male

N (%)

3 (0.04%)

\<=20

Male

N (%)

29 (0.35%)

1980-01-01 to 1980-12-31

overall

overall

N (%)

83 (0.99%)

\>20

overall

N (%)

21 (0.25%)

\<=20

overall

N (%)

62 (0.74%)

overall

Female

N (%)

47 (0.56%)

Male

N (%)

36 (0.43%)

\<=20

Male

N (%)

36 (0.43%)

Female

N (%)

26 (0.31%)

\>20

Female

N (%)

21 (0.25%)

1981-01-01 to 1981-12-31

overall

overall

N (%)

66 (0.79%)

\<=20

overall

N (%)

41 (0.49%)

\>20

overall

N (%)

25 (0.30%)

overall

Female

N (%)

35 (0.42%)

Male

N (%)

31 (0.37%)

\>20

Female

N (%)

25 (0.30%)

\<=20

Female

N (%)

10 (0.12%)

Male

N (%)

31 (0.37%)

1982-01-01 to 1982-12-31

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

33 (0.39%)

Female

N (%)

33 (0.39%)

\<=20

Female

N (%)

12 (0.14%)

\>20

Female

N (%)

21 (0.25%)

Male

N (%)

5 (0.06%)

\<=20

Male

N (%)

28 (0.33%)

1983-01-01 to 1983-12-31

overall

overall

N (%)

52 (0.62%)

\<=20

overall

N (%)

33 (0.39%)

\>20

overall

N (%)

19 (0.23%)

overall

Female

N (%)

27 (0.32%)

Male

N (%)

25 (0.30%)

\>20

Female

N (%)

12 (0.14%)

\<=20

Female

N (%)

15 (0.18%)

Male

N (%)

18 (0.21%)

\>20

Male

N (%)

7 (0.08%)

1984-01-01 to 1984-12-31

overall

overall

N (%)

60 (0.71%)

\>20

overall

N (%)

32 (0.38%)

\<=20

overall

N (%)

28 (0.33%)

overall

Male

N (%)

20 (0.24%)

Female

N (%)

40 (0.48%)

\<=20

Male

N (%)

10 (0.12%)

\>20

Male

N (%)

10 (0.12%)

Female

N (%)

22 (0.26%)

\<=20

Female

N (%)

18 (0.21%)

1985-01-01 to 1985-12-31

overall

overall

N (%)

64 (0.76%)

\>20

overall

N (%)

29 (0.35%)

\<=20

overall

N (%)

35 (0.42%)

overall

Female

N (%)

45 (0.54%)

Male

N (%)

19 (0.23%)

\>20

Male

N (%)

13 (0.15%)

\<=20

Male

N (%)

6 (0.07%)

\>20

Female

N (%)

16 (0.19%)

\<=20

Female

N (%)

29 (0.35%)

1986-01-01 to 1986-12-31

overall

overall

N (%)

58 (0.69%)

\>20

overall

N (%)

29 (0.35%)

\<=20

overall

N (%)

29 (0.35%)

overall

Female

N (%)

40 (0.48%)

Male

N (%)

18 (0.21%)

\>20

Male

N (%)

8 (0.10%)

\<=20

Male

N (%)

10 (0.12%)

\>20

Female

N (%)

21 (0.25%)

\<=20

Female

N (%)

19 (0.23%)

1987-01-01 to 1987-12-31

overall

overall

N (%)

46 (0.55%)

\<=20

overall

N (%)

27 (0.32%)

\>20

overall

N (%)

19 (0.23%)

overall

Male

N (%)

19 (0.23%)

Female

N (%)

27 (0.32%)

\>20

Female

N (%)

11 (0.13%)

\<=20

Female

N (%)

16 (0.19%)

\>20

Male

N (%)

8 (0.10%)

\<=20

Male

N (%)

11 (0.13%)

1988-01-01 to 1988-12-31

overall

overall

N (%)

38 (0.45%)

\>20

overall

N (%)

19 (0.23%)

\<=20

overall

N (%)

19 (0.23%)

overall

Female

N (%)

26 (0.31%)

Male

N (%)

12 (0.14%)

\>20

Male

N (%)

6 (0.07%)

\<=20

Male

N (%)

6 (0.07%)

Female

N (%)

13 (0.15%)

\>20

Female

N (%)

13 (0.15%)

1989-01-01 to 1989-12-31

overall

overall

N (%)

98 (1.17%)

\<=20

overall

N (%)

66 (0.79%)

\>20

overall

N (%)

32 (0.38%)

overall

Male

N (%)

66 (0.79%)

Female

N (%)

32 (0.38%)

\<=20

Female

N (%)

16 (0.19%)

\>20

Female

N (%)

16 (0.19%)

Male

N (%)

16 (0.19%)

\<=20

Male

N (%)

50 (0.60%)

1990-01-01 to 1990-12-31

overall

overall

N (%)

127 (1.51%)

\<=20

overall

N (%)

84 (1.00%)

\>20

overall

N (%)

43 (0.51%)

overall

Female

N (%)

31 (0.37%)

Male

N (%)

96 (1.14%)

\>20

Female

N (%)

23 (0.27%)

\<=20

Female

N (%)

8 (0.10%)

Male

N (%)

76 (0.90%)

\>20

Male

N (%)

20 (0.24%)

1991-01-01 to 1991-12-31

overall

overall

N (%)

163 (1.94%)

\>20

overall

N (%)

41 (0.49%)

\<=20

overall

N (%)

122 (1.45%)

overall

Male

N (%)

71 (0.85%)

Female

N (%)

92 (1.10%)

\<=20

Male

N (%)

55 (0.65%)

\>20

Male

N (%)

16 (0.19%)

\<=20

Female

N (%)

67 (0.80%)

\>20

Female

N (%)

25 (0.30%)

1992-01-01 to 1992-12-31

overall

overall

N (%)

173 (2.06%)

\<=20

overall

N (%)

119 (1.42%)

\>20

overall

N (%)

54 (0.64%)

overall

Female

N (%)

93 (1.11%)

Male

N (%)

80 (0.95%)

\<=20

Female

N (%)

68 (0.81%)

\>20

Female

N (%)

25 (0.30%)

\<=20

Male

N (%)

51 (0.61%)

\>20

Male

N (%)

29 (0.35%)

1993-01-01 to 1993-12-31

overall

overall

N (%)

104 (1.24%)

\>20

overall

N (%)

71 (0.85%)

\<=20

overall

N (%)

33 (0.39%)

overall

Female

N (%)

37 (0.44%)

Male

N (%)

67 (0.80%)

\>20

Male

N (%)

47 (0.56%)

\<=20

Male

N (%)

20 (0.24%)

\>20

Female

N (%)

24 (0.29%)

\<=20

Female

N (%)

13 (0.15%)

1994-01-01 to 1994-12-31

overall

overall

N (%)

112 (1.33%)

\>20

overall

N (%)

72 (0.86%)

\<=20

overall

N (%)

40 (0.48%)

overall

Male

N (%)

71 (0.85%)

Female

N (%)

41 (0.49%)

\<=20

Male

N (%)

17 (0.20%)

\>20

Male

N (%)

54 (0.64%)

\<=20

Female

N (%)

23 (0.27%)

\>20

Female

N (%)

18 (0.21%)

1995-01-01 to 1995-12-31

overall

overall

N (%)

103 (1.23%)

\>20

overall

N (%)

72 (0.86%)

\<=20

overall

N (%)

31 (0.37%)

overall

Female

N (%)

61 (0.73%)

Male

N (%)

42 (0.50%)

\>20

Male

N (%)

38 (0.45%)

\<=20

Male

N (%)

4 (0.05%)

Female

N (%)

27 (0.32%)

\>20

Female

N (%)

34 (0.40%)

1996-01-01 to 1996-12-31

overall

overall

N (%)

135 (1.61%)

\>20

overall

N (%)

93 (1.11%)

\<=20

overall

N (%)

42 (0.50%)

overall

Female

N (%)

89 (1.06%)

Male

N (%)

46 (0.55%)

\>20

Male

N (%)

43 (0.51%)

\<=20

Male

N (%)

3 (0.04%)

\>20

Female

N (%)

50 (0.60%)

\<=20

Female

N (%)

39 (0.46%)

1997-01-01 to 1997-12-31

overall

overall

N (%)

141 (1.68%)

\>20

overall

N (%)

97 (1.15%)

\<=20

overall

N (%)

44 (0.52%)

overall

Female

N (%)

102 (1.21%)

Male

N (%)

39 (0.46%)

\>20

Male

N (%)

36 (0.43%)

\<=20

Male

N (%)

3 (0.04%)

\>20

Female

N (%)

61 (0.73%)

\<=20

Female

N (%)

41 (0.49%)

1998-01-01 to 1998-12-31

overall

overall

N (%)

164 (1.95%)

\>20

overall

N (%)

103 (1.23%)

\<=20

overall

N (%)

61 (0.73%)

overall

Female

N (%)

106 (1.26%)

Male

N (%)

58 (0.69%)

\>20

Male

N (%)

51 (0.61%)

\<=20

Male

N (%)

7 (0.08%)

\>20

Female

N (%)

52 (0.62%)

\<=20

Female

N (%)

54 (0.64%)

1999-01-01 to 1999-12-31

overall

overall

N (%)

255 (3.04%)

\>20

overall

N (%)

118 (1.40%)

\<=20

overall

N (%)

137 (1.63%)

overall

Male

N (%)

83 (0.99%)

Female

N (%)

172 (2.05%)

\<=20

Male

N (%)

6 (0.07%)

\>20

Male

N (%)

77 (0.92%)

\<=20

Female

N (%)

131 (1.56%)

\>20

Female

N (%)

41 (0.49%)

2000-01-01 to 2000-12-31

overall

overall

N (%)

285 (3.39%)

\<=20

overall

N (%)

83 (0.99%)

\>20

overall

N (%)

202 (2.40%)

overall

Female

N (%)

114 (1.36%)

Male

N (%)

171 (2.04%)

\<=20

Female

N (%)

79 (0.94%)

\>20

Female

N (%)

35 (0.42%)

\<=20

Male

N (%)

4 (0.05%)

\>20

Male

N (%)

167 (1.99%)

2001-01-01 to 2001-12-31

overall

overall

N (%)

225 (2.68%)

\>20

overall

N (%)

156 (1.86%)

\<=20

overall

N (%)

69 (0.82%)

overall

Female

N (%)

91 (1.08%)

Male

N (%)

134 (1.60%)

\>20

Male

N (%)

118 (1.40%)

\<=20

Male

N (%)

16 (0.19%)

Female

N (%)

53 (0.63%)

\>20

Female

N (%)

38 (0.45%)

2002-01-01 to 2002-12-31

overall

overall

N (%)

189 (2.25%)

\>20

overall

N (%)

135 (1.61%)

\<=20

overall

N (%)

54 (0.64%)

overall

Male

N (%)

107 (1.27%)

Female

N (%)

82 (0.98%)

\<=20

Male

N (%)

14 (0.17%)

\>20

Male

N (%)

93 (1.11%)

\<=20

Female

N (%)

40 (0.48%)

\>20

Female

N (%)

42 (0.50%)

2003-01-01 to 2003-12-31

overall

overall

N (%)

219 (2.61%)

\<=20

overall

N (%)

71 (0.85%)

\>20

overall

N (%)

148 (1.76%)

overall

Female

N (%)

125 (1.49%)

Male

N (%)

94 (1.12%)

\>20

Female

N (%)

68 (0.81%)

\<=20

Female

N (%)

57 (0.68%)

Male

N (%)

14 (0.17%)

\>20

Male

N (%)

80 (0.95%)

2004-01-01 to 2004-12-31

overall

overall

N (%)

195 (2.32%)

\<=20

overall

N (%)

60 (0.71%)

\>20

overall

N (%)

135 (1.61%)

overall

Male

N (%)

82 (0.98%)

Female

N (%)

113 (1.35%)

\>20

Female

N (%)

71 (0.85%)

\<=20

Female

N (%)

42 (0.50%)

\>20

Male

N (%)

64 (0.76%)

\<=20

Male

N (%)

18 (0.21%)

2005-01-01 to 2005-12-31

overall

overall

N (%)

241 (2.87%)

\>20

overall

N (%)

163 (1.94%)

\<=20

overall

N (%)

78 (0.93%)

overall

Female

N (%)

137 (1.63%)

Male

N (%)

104 (1.24%)

\>20

Male

N (%)

75 (0.89%)

\<=20

Male

N (%)

29 (0.35%)

Female

N (%)

49 (0.58%)

\>20

Female

N (%)

88 (1.05%)

2006-01-01 to 2006-12-31

overall

overall

N (%)

246 (2.93%)

\>20

overall

N (%)

168 (2.00%)

\<=20

overall

N (%)

78 (0.93%)

overall

Male

N (%)

139 (1.65%)

Female

N (%)

107 (1.27%)

\<=20

Male

N (%)

50 (0.60%)

\>20

Male

N (%)

89 (1.06%)

\<=20

Female

N (%)

28 (0.33%)

\>20

Female

N (%)

79 (0.94%)

2007-01-01 to 2007-12-31

overall

overall

N (%)

253 (3.01%)

\>20

overall

N (%)

171 (2.04%)

\<=20

overall

N (%)

82 (0.98%)

overall

Male

N (%)

159 (1.89%)

Female

N (%)

94 (1.12%)

\<=20

Male

N (%)

66 (0.79%)

\>20

Male

N (%)

93 (1.11%)

Female

N (%)

78 (0.93%)

\<=20

Female

N (%)

16 (0.19%)

2008-01-01 to 2008-12-31

overall

overall

N (%)

214 (2.55%)

\>20

overall

N (%)

150 (1.79%)

\<=20

overall

N (%)

64 (0.76%)

overall

Female

N (%)

74 (0.88%)

Male

N (%)

140 (1.67%)

\>20

Male

N (%)

92 (1.10%)

\<=20

Male

N (%)

48 (0.57%)

\>20

Female

N (%)

58 (0.69%)

\<=20

Female

N (%)

16 (0.19%)

2009-01-01 to 2009-12-31

overall

overall

N (%)

239 (2.85%)

\<=20

overall

N (%)

71 (0.85%)

\>20

overall

N (%)

168 (2.00%)

overall

Female

N (%)

76 (0.90%)

Male

N (%)

163 (1.94%)

\>20

Female

N (%)

64 (0.76%)

\<=20

Female

N (%)

12 (0.14%)

Male

N (%)

59 (0.70%)

\>20

Male

N (%)

104 (1.24%)

2010-01-01 to 2010-12-31

overall

overall

N (%)

199 (2.37%)

\<=20

overall

N (%)

31 (0.37%)

\>20

overall

N (%)

168 (2.00%)

overall

Female

N (%)

62 (0.74%)

Male

N (%)

137 (1.63%)

\<=20

Female

N (%)

8 (0.10%)

\>20

Female

N (%)

54 (0.64%)

\<=20

Male

N (%)

23 (0.27%)

\>20

Male

N (%)

114 (1.36%)

2011-01-01 to 2011-12-31

overall

overall

N (%)

195 (2.32%)

\<=20

overall

N (%)

29 (0.35%)

\>20

overall

N (%)

166 (1.98%)

overall

Male

N (%)

143 (1.70%)

Female

N (%)

52 (0.62%)

\>20

Female

N (%)

36 (0.43%)

\<=20

Female

N (%)

16 (0.19%)

\>20

Male

N (%)

130 (1.55%)

\<=20

Male

N (%)

13 (0.15%)

2012-01-01 to 2012-12-31

overall

overall

N (%)

177 (2.11%)

\<=20

overall

N (%)

50 (0.60%)

\>20

overall

N (%)

127 (1.51%)

overall

Male

N (%)

92 (1.10%)

Female

N (%)

85 (1.01%)

\<=20

Female

N (%)

36 (0.43%)

\>20

Female

N (%)

49 (0.58%)

Male

N (%)

78 (0.93%)

\<=20

Male

N (%)

14 (0.17%)

2013-01-01 to 2013-12-31

overall

overall

N (%)

292 (3.48%)

\<=20

overall

N (%)

78 (0.93%)

\>20

overall

N (%)

214 (2.55%)

overall

Female

N (%)

117 (1.39%)

Male

N (%)

175 (2.08%)

\>20

Female

N (%)

59 (0.70%)

\<=20

Female

N (%)

58 (0.69%)

Male

N (%)

20 (0.24%)

\>20

Male

N (%)

155 (1.85%)

2014-01-01 to 2014-12-31

overall

overall

N (%)

375 (4.46%)

\>20

overall

N (%)

312 (3.71%)

\<=20

overall

N (%)

63 (0.75%)

overall

Male

N (%)

142 (1.69%)

Female

N (%)

233 (2.77%)

\<=20

Male

N (%)

14 (0.17%)

\>20

Male

N (%)

128 (1.52%)

Female

N (%)

184 (2.19%)

\<=20

Female

N (%)

49 (0.58%)

2015-01-01 to 2015-12-31

overall

overall

N (%)

294 (3.50%)

\<=20

overall

N (%)

83 (0.99%)

\>20

overall

N (%)

211 (2.51%)

overall

Female

N (%)

166 (1.98%)

Male

N (%)

128 (1.52%)

\>20

Female

N (%)

106 (1.26%)

\<=20

Female

N (%)

60 (0.71%)

Male

N (%)

23 (0.27%)

\>20

Male

N (%)

105 (1.25%)

2016-01-01 to 2016-12-31

overall

overall

N (%)

306 (3.64%)

\<=20

overall

N (%)

30 (0.36%)

\>20

overall

N (%)

276 (3.29%)

overall

Female

N (%)

166 (1.98%)

Male

N (%)

140 (1.67%)

\>20

Female

N (%)

158 (1.88%)

\<=20

Female

N (%)

8 (0.10%)

Male

N (%)

22 (0.26%)

\>20

Male

N (%)

118 (1.40%)

2017-01-01 to 2017-12-31

overall

overall

N (%)

408 (4.86%)

\<=20

overall

N (%)

20 (0.24%)

\>20

overall

N (%)

388 (4.62%)

overall

Male

N (%)

246 (2.93%)

Female

N (%)

162 (1.93%)

\>20

Female

N (%)

162 (1.93%)

Male

N (%)

226 (2.69%)

\<=20

Male

N (%)

20 (0.24%)

2018-01-01 to 2018-12-31

overall

overall

N (%)

442 (5.26%)

\>20

overall

N (%)

378 (4.50%)

\<=20

overall

N (%)

64 (0.76%)

overall

Female

N (%)

206 (2.45%)

Male

N (%)

236 (2.81%)

\>20

Male

N (%)

172 (2.05%)

\<=20

Male

N (%)

64 (0.76%)

\>20

Female

N (%)

206 (2.45%)

2019-01-01 to 2019-12-31

overall

overall

N (%)

536 (6.38%)

\>20

overall

N (%)

536 (6.38%)

overall

Female

N (%)

216 (2.57%)

Male

N (%)

320 (3.81%)

\>20

Female

N (%)

216 (2.57%)

Male

N (%)

320 (3.81%)

overall

overall

overall

N (%)

8,400 (100.00%)

\>20

overall

N (%)

5,471 (65.13%)

\<=20

overall

N (%)

2,929 (34.87%)

overall

Female

N (%)

4,188 (49.86%)

Male

N (%)

4,212 (50.14%)

\<=20

Female

N (%)

1,752 (20.86%)

Male

N (%)

1,177 (14.01%)

\>20

Female

N (%)

2,436 (29.00%)

Male

N (%)

3,035 (36.13%)

episode; observation_period

Number of records

1957-01-01 to 1957-12-31

overall

overall

N (%)

1 (1.00%)

\<=20

overall

N (%)

1 (1.00%)

overall

Male

N (%)

1 (1.00%)

\<=20

Male

N (%)

1 (1.00%)

1958-01-01 to 1958-12-31

overall

overall

N (%)

2 (2.00%)

\<=20

overall

N (%)

2 (2.00%)

overall

Female

N (%)

1 (1.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

1 (1.00%)

Male

N (%)

1 (1.00%)

1959-01-01 to 1959-12-31

overall

overall

N (%)

2 (2.00%)

\<=20

overall

N (%)

2 (2.00%)

overall

Female

N (%)

1 (1.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

1 (1.00%)

Male

N (%)

1 (1.00%)

1960-01-01 to 1960-12-31

overall

overall

N (%)

2 (2.00%)

\<=20

overall

N (%)

2 (2.00%)

overall

Female

N (%)

1 (1.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

1 (1.00%)

Male

N (%)

1 (1.00%)

1961-01-01 to 1961-12-31

overall

overall

N (%)

2 (2.00%)

\<=20

overall

N (%)

2 (2.00%)

overall

Female

N (%)

1 (1.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

1 (1.00%)

Male

N (%)

1 (1.00%)

1962-01-01 to 1962-12-31

overall

overall

N (%)

2 (2.00%)

\<=20

overall

N (%)

2 (2.00%)

overall

Female

N (%)

1 (1.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

1 (1.00%)

Male

N (%)

1 (1.00%)

1963-01-01 to 1963-12-31

overall

overall

N (%)

4 (4.00%)

\<=20

overall

N (%)

4 (4.00%)

overall

Female

N (%)

3 (3.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

3 (3.00%)

Male

N (%)

1 (1.00%)

1964-01-01 to 1964-12-31

overall

overall

N (%)

4 (4.00%)

\<=20

overall

N (%)

4 (4.00%)

overall

Female

N (%)

3 (3.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

3 (3.00%)

Male

N (%)

1 (1.00%)

1965-01-01 to 1965-12-31

overall

overall

N (%)

5 (5.00%)

\<=20

overall

N (%)

5 (5.00%)

overall

Female

N (%)

4 (4.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

4 (4.00%)

Male

N (%)

1 (1.00%)

1966-01-01 to 1966-12-31

overall

overall

N (%)

4 (4.00%)

\<=20

overall

N (%)

4 (4.00%)

overall

Female

N (%)

3 (3.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

3 (3.00%)

Male

N (%)

1 (1.00%)

1967-01-01 to 1967-12-31

overall

overall

N (%)

5 (5.00%)

\<=20

overall

N (%)

5 (5.00%)

overall

Female

N (%)

4 (4.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

4 (4.00%)

Male

N (%)

1 (1.00%)

1968-01-01 to 1968-12-31

overall

overall

N (%)

5 (5.00%)

\<=20

overall

N (%)

5 (5.00%)

overall

Female

N (%)

4 (4.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

4 (4.00%)

Male

N (%)

1 (1.00%)

1969-01-01 to 1969-12-31

overall

overall

N (%)

6 (6.00%)

\<=20

overall

N (%)

6 (6.00%)

overall

Female

N (%)

4 (4.00%)

Male

N (%)

2 (2.00%)

\<=20

Female

N (%)

4 (4.00%)

Male

N (%)

2 (2.00%)

1970-01-01 to 1970-12-31

overall

overall

N (%)

6 (6.00%)

\<=20

overall

N (%)

6 (6.00%)

overall

Female

N (%)

4 (4.00%)

Male

N (%)

2 (2.00%)

\<=20

Female

N (%)

4 (4.00%)

Male

N (%)

2 (2.00%)

1971-01-01 to 1971-12-31

overall

overall

N (%)

7 (7.00%)

\<=20

overall

N (%)

7 (7.00%)

overall

Female

N (%)

5 (5.00%)

Male

N (%)

2 (2.00%)

\<=20

Female

N (%)

5 (5.00%)

Male

N (%)

2 (2.00%)

1972-01-01 to 1972-12-31

overall

overall

N (%)

8 (8.00%)

\<=20

overall

N (%)

7 (7.00%)

\>20

overall

N (%)

1 (1.00%)

overall

Female

N (%)

6 (6.00%)

Male

N (%)

2 (2.00%)

\>20

Female

N (%)

1 (1.00%)

\<=20

Female

N (%)

5 (5.00%)

Male

N (%)

2 (2.00%)

1973-01-01 to 1973-12-31

overall

overall

N (%)

9 (9.00%)

\>20

overall

N (%)

3 (3.00%)

\<=20

overall

N (%)

6 (6.00%)

overall

Male

N (%)

3 (3.00%)

Female

N (%)

6 (6.00%)

\<=20

Male

N (%)

2 (2.00%)

\>20

Female

N (%)

2 (2.00%)

\<=20

Female

N (%)

4 (4.00%)

\>20

Male

N (%)

1 (1.00%)

1974-01-01 to 1974-12-31

overall

overall

N (%)

10 (10.00%)

\<=20

overall

N (%)

7 (7.00%)

\>20

overall

N (%)

3 (3.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

6 (6.00%)

\<=20

Male

N (%)

3 (3.00%)

Female

N (%)

4 (4.00%)

\>20

Female

N (%)

2 (2.00%)

Male

N (%)

1 (1.00%)

1975-01-01 to 1975-12-31

overall

overall

N (%)

10 (10.00%)

\>20

overall

N (%)

3 (3.00%)

\<=20

overall

N (%)

7 (7.00%)

overall

Male

N (%)

4 (4.00%)

Female

N (%)

6 (6.00%)

\>20

Female

N (%)

2 (2.00%)

Male

N (%)

1 (1.00%)

\<=20

Male

N (%)

3 (3.00%)

Female

N (%)

4 (4.00%)

1976-01-01 to 1976-12-31

overall

overall

N (%)

13 (13.00%)

\>20

overall

N (%)

4 (4.00%)

\<=20

overall

N (%)

9 (9.00%)

overall

Female

N (%)

8 (8.00%)

Male

N (%)

5 (5.00%)

\<=20

Female

N (%)

5 (5.00%)

Male

N (%)

4 (4.00%)

\>20

Female

N (%)

3 (3.00%)

Male

N (%)

1 (1.00%)

1977-01-01 to 1977-12-31

overall

overall

N (%)

15 (15.00%)

\<=20

overall

N (%)

11 (11.00%)

\>20

overall

N (%)

4 (4.00%)

overall

Female

N (%)

9 (9.00%)

Male

N (%)

6 (6.00%)

\>20

Female

N (%)

3 (3.00%)

Male

N (%)

1 (1.00%)

\<=20

Female

N (%)

6 (6.00%)

Male

N (%)

5 (5.00%)

1978-01-01 to 1978-12-31

overall

overall

N (%)

17 (17.00%)

\>20

overall

N (%)

4 (4.00%)

\<=20

overall

N (%)

13 (13.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

10 (10.00%)

\>20

Female

N (%)

3 (3.00%)

Male

N (%)

1 (1.00%)

\<=20

Male

N (%)

6 (6.00%)

Female

N (%)

7 (7.00%)

1979-01-01 to 1979-12-31

overall

overall

N (%)

17 (17.00%)

\<=20

overall

N (%)

13 (13.00%)

\>20

overall

N (%)

4 (4.00%)

overall

Male

N (%)

8 (8.00%)

Female

N (%)

9 (9.00%)

\>20

Female

N (%)

3 (3.00%)

Male

N (%)

1 (1.00%)

\<=20

Male

N (%)

7 (7.00%)

Female

N (%)

6 (6.00%)

1980-01-01 to 1980-12-31

overall

overall

N (%)

16 (16.00%)

\>20

overall

N (%)

3 (3.00%)

\<=20

overall

N (%)

13 (13.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\>20

Female

N (%)

3 (3.00%)

\<=20

Male

N (%)

7 (7.00%)

Female

N (%)

6 (6.00%)

1981-01-01 to 1981-12-31

overall

overall

N (%)

16 (16.00%)

\>20

overall

N (%)

5 (5.00%)

\<=20

overall

N (%)

11 (11.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

9 (9.00%)

\>20

Female

N (%)

5 (5.00%)

\<=20

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

1982-01-01 to 1982-12-31

overall

overall

N (%)

17 (17.00%)

\<=20

overall

N (%)

12 (12.00%)

\>20

overall

N (%)

5 (5.00%)

overall

Male

N (%)

7 (7.00%)

Female

N (%)

10 (10.00%)

\<=20

Male

N (%)

7 (7.00%)

Female

N (%)

5 (5.00%)

\>20

Female

N (%)

5 (5.00%)

1983-01-01 to 1983-12-31

overall

overall

N (%)

15 (15.00%)

\<=20

overall

N (%)

10 (10.00%)

\>20

overall

N (%)

5 (5.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

9 (9.00%)

\>20

Female

N (%)

4 (4.00%)

Male

N (%)

1 (1.00%)

\<=20

Male

N (%)

5 (5.00%)

Female

N (%)

5 (5.00%)

1984-01-01 to 1984-12-31

overall

overall

N (%)

16 (16.00%)

\>20

overall

N (%)

7 (7.00%)

\<=20

overall

N (%)

9 (9.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

10 (10.00%)

\>20

Male

N (%)

2 (2.00%)

Female

N (%)

5 (5.00%)

\<=20

Female

N (%)

5 (5.00%)

Male

N (%)

4 (4.00%)

1985-01-01 to 1985-12-31

overall

overall

N (%)

18 (18.00%)

\<=20

overall

N (%)

10 (10.00%)

\>20

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

12 (12.00%)

\>20

Male

N (%)

2 (2.00%)

Female

N (%)

6 (6.00%)

\<=20

Female

N (%)

6 (6.00%)

Male

N (%)

4 (4.00%)

1986-01-01 to 1986-12-31

overall

overall

N (%)

18 (18.00%)

\<=20

overall

N (%)

10 (10.00%)

\>20

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

12 (12.00%)

\<=20

Female

N (%)

6 (6.00%)

Male

N (%)

4 (4.00%)

\>20

Male

N (%)

2 (2.00%)

Female

N (%)

6 (6.00%)

1987-01-01 to 1987-12-31

overall

overall

N (%)

16 (16.00%)

\<=20

overall

N (%)

8 (8.00%)

\>20

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

10 (10.00%)

\<=20

Female

N (%)

5 (5.00%)

Male

N (%)

3 (3.00%)

\>20

Male

N (%)

3 (3.00%)

Female

N (%)

5 (5.00%)

1988-01-01 to 1988-12-31

overall

overall

N (%)

16 (16.00%)

\>20

overall

N (%)

8 (8.00%)

\<=20

overall

N (%)

8 (8.00%)

overall

Male

N (%)

6 (6.00%)

Female

N (%)

10 (10.00%)

\>20

Male

N (%)

3 (3.00%)

Female

N (%)

5 (5.00%)

\<=20

Female

N (%)

5 (5.00%)

Male

N (%)

3 (3.00%)

1989-01-01 to 1989-12-31

overall

overall

N (%)

20 (20.00%)

\>20

overall

N (%)

10 (10.00%)

\<=20

overall

N (%)

10 (10.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

10 (10.00%)

\>20

Male

N (%)

4 (4.00%)

\<=20

Male

N (%)

6 (6.00%)

\>20

Female

N (%)

6 (6.00%)

\<=20

Female

N (%)

4 (4.00%)

1990-01-01 to 1990-12-31

overall

overall

N (%)

22 (22.00%)

\<=20

overall

N (%)

11 (11.00%)

\>20

overall

N (%)

11 (11.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

10 (10.00%)

\<=20

Male

N (%)

7 (7.00%)

Female

N (%)

4 (4.00%)

\>20

Male

N (%)

5 (5.00%)

Female

N (%)

6 (6.00%)

1991-01-01 to 1991-12-31

overall

overall

N (%)

24 (24.00%)

\<=20

overall

N (%)

12 (12.00%)

\>20

overall

N (%)

12 (12.00%)

overall

Male

N (%)

12 (12.00%)

Female

N (%)

12 (12.00%)

\>20

Male

N (%)

5 (5.00%)

\<=20

Male

N (%)

7 (7.00%)

\>20

Female

N (%)

7 (7.00%)

\<=20

Female

N (%)

5 (5.00%)

1992-01-01 to 1992-12-31

overall

overall

N (%)

26 (26.00%)

\<=20

overall

N (%)

12 (12.00%)

\>20

overall

N (%)

14 (14.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

\<=20

Female

N (%)

6 (6.00%)

Male

N (%)

6 (6.00%)

\>20

Male

N (%)

7 (7.00%)

Female

N (%)

7 (7.00%)

1993-01-01 to 1993-12-31

overall

overall

N (%)

26 (26.00%)

\>20

overall

N (%)

17 (17.00%)

\<=20

overall

N (%)

9 (9.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

13 (13.00%)

\>20

Male

N (%)

10 (10.00%)

\<=20

Female

N (%)

6 (6.00%)

Male

N (%)

3 (3.00%)

\>20

Female

N (%)

7 (7.00%)

1994-01-01 to 1994-12-31

overall

overall

N (%)

26 (26.00%)

\>20

overall

N (%)

18 (18.00%)

\<=20

overall

N (%)

8 (8.00%)

overall

Female

N (%)

14 (14.00%)

Male

N (%)

12 (12.00%)

\>20

Male

N (%)

9 (9.00%)

Female

N (%)

9 (9.00%)

\<=20

Female

N (%)

5 (5.00%)

Male

N (%)

3 (3.00%)

1995-01-01 to 1995-12-31

overall

overall

N (%)

25 (25.00%)

\>20

overall

N (%)

18 (18.00%)

\<=20

overall

N (%)

7 (7.00%)

overall

Female

N (%)

14 (14.00%)

Male

N (%)

11 (11.00%)

\>20

Female

N (%)

8 (8.00%)

Male

N (%)

10 (10.00%)

\<=20

Female

N (%)

6 (6.00%)

Male

N (%)

1 (1.00%)

1996-01-01 to 1996-12-31

overall

overall

N (%)

28 (28.00%)

\<=20

overall

N (%)

8 (8.00%)

\>20

overall

N (%)

20 (20.00%)

overall

Female

N (%)

16 (16.00%)

Male

N (%)

12 (12.00%)

\<=20

Female

N (%)

7 (7.00%)

Male

N (%)

1 (1.00%)

\>20

Female

N (%)

9 (9.00%)

Male

N (%)

11 (11.00%)

1997-01-01 to 1997-12-31

overall

overall

N (%)

29 (29.00%)

\<=20

overall

N (%)

9 (9.00%)

\>20

overall

N (%)

20 (20.00%)

overall

Female

N (%)

17 (17.00%)

Male

N (%)

12 (12.00%)

\>20

Female

N (%)

9 (9.00%)

\<=20

Female

N (%)

8 (8.00%)

Male

N (%)

1 (1.00%)

\>20

Male

N (%)

11 (11.00%)

1998-01-01 to 1998-12-31

overall

overall

N (%)

32 (32.00%)

\<=20

overall

N (%)

10 (10.00%)

\>20

overall

N (%)

22 (22.00%)

overall

Female

N (%)

18 (18.00%)

Male

N (%)

14 (14.00%)

\<=20

Female

N (%)

8 (8.00%)

Male

N (%)

2 (2.00%)

\>20

Female

N (%)

10 (10.00%)

Male

N (%)

12 (12.00%)

1999-01-01 to 1999-12-31

overall

overall

N (%)

36 (36.00%)

\>20

overall

N (%)

25 (25.00%)

\<=20

overall

N (%)

11 (11.00%)

overall

Female

N (%)

19 (19.00%)

Male

N (%)

17 (17.00%)

\<=20

Female

N (%)

9 (9.00%)

\>20

Female

N (%)

10 (10.00%)

\<=20

Male

N (%)

2 (2.00%)

\>20

Male

N (%)

15 (15.00%)

2000-01-01 to 2000-12-31

overall

overall

N (%)

36 (36.00%)

\>20

overall

N (%)

25 (25.00%)

\<=20

overall

N (%)

11 (11.00%)

overall

Female

N (%)

17 (17.00%)

Male

N (%)

19 (19.00%)

\>20

Female

N (%)

8 (8.00%)

Male

N (%)

17 (17.00%)

\<=20

Female

N (%)

9 (9.00%)

Male

N (%)

2 (2.00%)

2001-01-01 to 2001-12-31

overall

overall

N (%)

39 (39.00%)

\<=20

overall

N (%)

12 (12.00%)

\>20

overall

N (%)

27 (27.00%)

overall

Female

N (%)

18 (18.00%)

Male

N (%)

21 (21.00%)

\>20

Female

N (%)

9 (9.00%)

Male

N (%)

18 (18.00%)

\<=20

Female

N (%)

9 (9.00%)

Male

N (%)

3 (3.00%)

2002-01-01 to 2002-12-31

overall

overall

N (%)

37 (37.00%)

\<=20

overall

N (%)

11 (11.00%)

\>20

overall

N (%)

26 (26.00%)

overall

Female

N (%)

16 (16.00%)

Male

N (%)

21 (21.00%)

\<=20

Female

N (%)

8 (8.00%)

\>20

Male

N (%)

18 (18.00%)

Female

N (%)

8 (8.00%)

\<=20

Male

N (%)

3 (3.00%)

2003-01-01 to 2003-12-31

overall

overall

N (%)

36 (36.00%)

\>20

overall

N (%)

25 (25.00%)

\<=20

overall

N (%)

11 (11.00%)

overall

Female

N (%)

16 (16.00%)

Male

N (%)

20 (20.00%)

\<=20

Female

N (%)

8 (8.00%)

Male

N (%)

3 (3.00%)

\>20

Female

N (%)

8 (8.00%)

Male

N (%)

17 (17.00%)

2004-01-01 to 2004-12-31

overall

overall

N (%)

39 (39.00%)

\>20

overall

N (%)

28 (28.00%)

\<=20

overall

N (%)

11 (11.00%)

overall

Female

N (%)

18 (18.00%)

Male

N (%)

21 (21.00%)

\>20

Female

N (%)

11 (11.00%)

\<=20

Female

N (%)

7 (7.00%)

\>20

Male

N (%)

17 (17.00%)

\<=20

Male

N (%)

4 (4.00%)

2005-01-01 to 2005-12-31

overall

overall

N (%)

39 (39.00%)

\<=20

overall

N (%)

11 (11.00%)

\>20

overall

N (%)

28 (28.00%)

overall

Female

N (%)

19 (19.00%)

Male

N (%)

20 (20.00%)

\>20

Female

N (%)

12 (12.00%)

\<=20

Female

N (%)

7 (7.00%)

\>20

Male

N (%)

16 (16.00%)

\<=20

Male

N (%)

4 (4.00%)

2006-01-01 to 2006-12-31

overall

overall

N (%)

41 (41.00%)

\<=20

overall

N (%)

10 (10.00%)

\>20

overall

N (%)

31 (31.00%)

overall

Female

N (%)

19 (19.00%)

Male

N (%)

22 (22.00%)

\>20

Female

N (%)

13 (13.00%)

\<=20

Female

N (%)

6 (6.00%)

\>20

Male

N (%)

18 (18.00%)

\<=20

Male

N (%)

4 (4.00%)

2007-01-01 to 2007-12-31

overall

overall

N (%)

37 (37.00%)

\<=20

overall

N (%)

9 (9.00%)

\>20

overall

N (%)

28 (28.00%)

overall

Female

N (%)

15 (15.00%)

Male

N (%)

22 (22.00%)

\<=20

Male

N (%)

6 (6.00%)

Female

N (%)

3 (3.00%)

\>20

Female

N (%)

12 (12.00%)

Male

N (%)

16 (16.00%)

2008-01-01 to 2008-12-31

overall

overall

N (%)

35 (35.00%)

\>20

overall

N (%)

27 (27.00%)

\<=20

overall

N (%)

8 (8.00%)

overall

Female

N (%)

14 (14.00%)

Male

N (%)

21 (21.00%)

\<=20

Male

N (%)

6 (6.00%)

Female

N (%)

2 (2.00%)

\>20

Female

N (%)

12 (12.00%)

Male

N (%)

15 (15.00%)

2009-01-01 to 2009-12-31

overall

overall

N (%)

35 (35.00%)

\<=20

overall

N (%)

7 (7.00%)

\>20

overall

N (%)

28 (28.00%)

overall

Male

N (%)

23 (23.00%)

Female

N (%)

12 (12.00%)

\<=20

Male

N (%)

5 (5.00%)

Female

N (%)

2 (2.00%)

\>20

Male

N (%)

18 (18.00%)

Female

N (%)

10 (10.00%)

2010-01-01 to 2010-12-31

overall

overall

N (%)

29 (29.00%)

\<=20

overall

N (%)

5 (5.00%)

\>20

overall

N (%)

24 (24.00%)

overall

Male

N (%)

20 (20.00%)

Female

N (%)

9 (9.00%)

\>20

Male

N (%)

16 (16.00%)

Female

N (%)

8 (8.00%)

\<=20

Male

N (%)

4 (4.00%)

Female

N (%)

1 (1.00%)

2011-01-01 to 2011-12-31

overall

overall

N (%)

27 (27.00%)

\>20

overall

N (%)

22 (22.00%)

\<=20

overall

N (%)

5 (5.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

9 (9.00%)

\<=20

Male

N (%)

3 (3.00%)

Female

N (%)

2 (2.00%)

\>20

Male

N (%)

15 (15.00%)

Female

N (%)

7 (7.00%)

2012-01-01 to 2012-12-31

overall

overall

N (%)

29 (29.00%)

\>20

overall

N (%)

23 (23.00%)

\<=20

overall

N (%)

6 (6.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

11 (11.00%)

\>20

Male

N (%)

15 (15.00%)

Female

N (%)

8 (8.00%)

\<=20

Male

N (%)

3 (3.00%)

Female

N (%)

3 (3.00%)

2013-01-01 to 2013-12-31

overall

overall

N (%)

30 (30.00%)

\<=20

overall

N (%)

5 (5.00%)

\>20

overall

N (%)

25 (25.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

12 (12.00%)

\>20

Male

N (%)

16 (16.00%)

Female

N (%)

9 (9.00%)

\<=20

Male

N (%)

2 (2.00%)

Female

N (%)

3 (3.00%)

2014-01-01 to 2014-12-31

overall

overall

N (%)

32 (32.00%)

\>20

overall

N (%)

27 (27.00%)

\<=20

overall

N (%)

5 (5.00%)

overall

Male

N (%)

18 (18.00%)

Female

N (%)

14 (14.00%)

\<=20

Female

N (%)

4 (4.00%)

Male

N (%)

1 (1.00%)

\>20

Male

N (%)

17 (17.00%)

Female

N (%)

10 (10.00%)

2015-01-01 to 2015-12-31

overall

overall

N (%)

30 (30.00%)

\>20

overall

N (%)

26 (26.00%)

\<=20

overall

N (%)

4 (4.00%)

overall

Male

N (%)

17 (17.00%)

Female

N (%)

13 (13.00%)

\<=20

Female

N (%)

3 (3.00%)

Male

N (%)

1 (1.00%)

\>20

Male

N (%)

16 (16.00%)

Female

N (%)

10 (10.00%)

2016-01-01 to 2016-12-31

overall

overall

N (%)

28 (28.00%)

\<=20

overall

N (%)

3 (3.00%)

\>20

overall

N (%)

25 (25.00%)

overall

Male

N (%)

16 (16.00%)

Female

N (%)

12 (12.00%)

\<=20

Female

N (%)

2 (2.00%)

Male

N (%)

1 (1.00%)

\>20

Male

N (%)

15 (15.00%)

Female

N (%)

10 (10.00%)

2017-01-01 to 2017-12-31

overall

overall

N (%)

28 (28.00%)

\<=20

overall

N (%)

2 (2.00%)

\>20

overall

N (%)

26 (26.00%)

overall

Male

N (%)

19 (19.00%)

Female

N (%)

9 (9.00%)

\>20

Male

N (%)

17 (17.00%)

Female

N (%)

9 (9.00%)

\<=20

Male

N (%)

2 (2.00%)

2018-01-01 to 2018-12-31

overall

overall

N (%)

21 (21.00%)

\>20

overall

N (%)

20 (20.00%)

\<=20

overall

N (%)

1 (1.00%)

overall

Male

N (%)

13 (13.00%)

Female

N (%)

8 (8.00%)

\>20

Male

N (%)

12 (12.00%)

Female

N (%)

8 (8.00%)

\<=20

Male

N (%)

1 (1.00%)

2019-01-01 to 2019-12-31

overall

overall

N (%)

14 (14.00%)

\>20

overall

N (%)

14 (14.00%)

overall

Male

N (%)

10 (10.00%)

Female

N (%)

4 (4.00%)

\>20

Male

N (%)

10 (10.00%)

Female

N (%)

4 (4.00%)

overall

overall

overall

N (%)

100 (100.00%)

\>20

overall

N (%)

48 (48.00%)

\<=20

overall

N (%)

52 (52.00%)

overall

Female

N (%)

50 (50.00%)

Male

N (%)

50 (50.00%)

\>20

Male

N (%)

27 (27.00%)

Female

N (%)

21 (21.00%)

\<=20

Female

N (%)

29 (29.00%)

Male

N (%)

23 (23.00%)

CDMConnector::[cdmDisconnect](https://darwin-eu.github.io/omopgenerics/reference/cdmDisconnect.html)(cdm
= cdm) \# }
