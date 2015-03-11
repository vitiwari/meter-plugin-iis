boundary-iis-plugin
-------------------
A Boundary plugin that collects metrics from IIS performance counters.

## Prerequisites

### Supported OS

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |       |    v    |         |      |

#### Boundary Meter Versions V4.0 Or Greater REQUIRED

To get the new meter:

    curl -fsS \
        -d "{\"token\":\"<your API token here>\"}" \
        -H "Content-Type: application/json" \
        "https://meter.boundary.com/setup_meter" > setup_meter.sh
    chmod +x setup_meter.sh
    ./setup_meter.sh


To run this plugin you need Powershell

### Plugin Setup

No special setup is required (except basic configuration of options).

#### Plugin Configuration Fields

|Setting Name          |Identifier      |Type     |Description                                                                              |
|:---------------------|----------------|---------|:----------------------------------------------------------------------------------------|
|Poll Interval         |pollInterval    |integer  |How often (in milliseconds) to poll the Couchbase node for metrics (default: 5000).      |

### Metrics Collected
Tracks the following metrics for IIS/ASP.NET.

| Metric Name | Description | Category |
|:------------|:-----------:|:--------:|
| IIS_GENERAL_CPU_USAGE| Average percentage of processor time occupied.| General |
| IIS_GENERAL_CPU_QUEUE_LENGTH | The processor queue is being filled up with threads when the server's processor are busy servicing other threads at the moment. If this counter is usually above 2 and the %  of Processor Time remains on high levels, then the processor are considered a bottleneck in the system.| General |
| IIS_GENERAL_MEMORY_FREE | Refers to the amount of physical memory on the system that can be used by new processes.| General |
| IIS_GENERAL_MEMORY_PAGE_PER_SECOND | Refers to the amount of read and write request from memory to disk.| General |
| IIS_GENERAL_DISK_TIME | Refers to the percentage of time the disk was occupied. | General |
| IIS_GENERAL_NETWORK_BYTES_PER_SECOND | Refers to the total amount of bytes over the network | General |
| IIS_ASPNET_REQUESTS_PER_SECOND | Shows the throughput o the ASP.NET application on the server. | IIS/ASP.NET |
| IIS_ASPNET_RESTARTS | Indicates the number of restarts of the application in the server's uptime. | IIS/ASP.NET |
| IIS_ASPNET_REQUEST_WAIT_TIME | Shows the amount of time that the last request was held in the queue. | IIS/ASP.NET |
| IIS_ASPNET_REQUESTS_QUEUED | The queue fills up with requests that wait to be processed. | IIS/ASP.NET |
| IIS_ASPNET_EXECPTIONS_THROWN_PER_SECOND | Shows the number of exceptions per second that the application is throwing. | IIS/ASP.NET |
| IIS_ASPNET_TOTAL_COMMITTED_BYTES | Shows the amount of virtual memory reserved for the application on the paging file. | IIS/ASP.NET |
| IIS_SERVICE_GET_REQUESTS_PER_SECOND | Measures the amount of GET requests processed in a second.| IIS/ASP.NET |
| IIS_SERVICE_POST_REQUESTS_PER_SECOND | Measures the amount of POST requests processed in a second.| IIS/ASP.NET |
| IIS_SERVICE_CURRENT_CONNECTIONS | Shows the number of active connections with the Web Service.| IIS/ASP.NET

### References
For a detailed explanation of performance counters collected see this link: [http://blog.monitis.com/2012/04/02/important-iis7-counters/](http://blog.monitis.com/2012/04/02/important-iis7-counters/).
