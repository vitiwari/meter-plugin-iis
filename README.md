# TrueSight Pulse IIS Meter Plugin

A meter plugin plugin that collects metrics from IIS performance counters.

### Prerequisites

Windows IIS 8.0 or later

#### Supported OS

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   -   |    v    |    -    |  -   |

### Plugin Setup

None

### Plugin Configuration Fields

|Field Name        |Description                                                                              |
|:-----------------|:----------------------------------------------------------------------------------------|
|Delay             |Amount of time in milliseconds to wait between collection of Windows performance counters|
|Source            |The source to display in the legend for the data                                         |
 
### Metrics Collected

| Metric Name                             | Description                                                                               |
|:----------------------------------------|:------------------------------------------------------------------------------------------|
|IIS\_HTTP\_SERVICE\_CURRENT\_URIS\_CACHED|Total number of URIs currently cached by the kernel                                        |
|IIS\_HTTP\_SERVICE\_TOTAL\_FLUSHED\_URIS |Total number of URIs that have been removed from the kernel URI cache since service startup|
|IIS\_HTTP\_SERVICE\_TOTAL\_URIS\_CACHED  |Total number of URIs added to the kernel since service startup                             |
|IIS\_HTTP\_SERVICE\_URI\_CACHE\_FLUSHES  |Total number of kernel URI cache flushes (complete or partial) since service startup       |
|IIS\_HTTP\_SERVICE\_URI\_CACHE\_HITS     |Total number of successful lookups in the kernel URI cache                                 |
|IIS\_HTTP\_SERVICE\_URI\_CACHE\_MISSES   |Total number of unsuccessful lookups in the kernel URI cache                               |

### Dashboard

- IIS
