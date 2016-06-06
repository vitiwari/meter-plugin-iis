# TrueSight Pulse IIS Meter Plugin

A meter plugin plugin that collects metrics from IIS performance counters.

### Prerequisites

#### Supported OS

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   -   |    v    |    -    |  -   |

#### Boundary Meter versions v4.2 or later

- To install new meter go to Settings->Installation or [see instructions](https://help.boundary.com/hc/en-us/sections/200634331-Installation).
- To upgrade the meter to the latest version - [see instructions](https://help.boundary.com/hc/en-us/articles/201573102-Upgrading-the-Boundary-Meter). 

### Plugin Setup

None

### Plugin Configuration Fields

|Field Name        |Description                                                                       |
|:-----------------|:---------------------------------------------------------------------------------|
|Source            |The source to display in the legend for the data                                  |
|Poll Interval (ms)|The Poll Interval in milliseconds to poll for metrics                             |
 
### Metrics Collected

| Metric Name                             | Description                                                                               |
|:----------------------------------------|:------------------------------------------------------------------------------------------|
|IIS\_HTTP\_SERVICE\_CURRENT\_URIS\_CACHED|Total number of URIs currently cached by the kernel                                        |
|IIS\_HTTP\_SERVICE\_TOTAL\_FLUSHED\_URIS |Total number of URIs that have been removed from the kernel URI cache since service startup|
|IIS\_HTTP\_SERVICE\_TOTAL\_URIS\_CACHED  |Total number of URIs added to the kernel since service startup                             |
|IIS\_HTTP\_SERVICE\_URI\_CACHE\_FLUSHES  |Total number of kernel URI cache flushes (complete or partial) since service startup       |
|IIS\_HTTP\_SERVICE\_URI\_CACHE\_HITS     |Total number of successful lookups in the kernel URI cache                                 |
|IIS\_HTTP\_SERVICE\_URI\_CACHE\_MISSES   |Total number of unsuccessful lookups in the kernel URI cache                               |
