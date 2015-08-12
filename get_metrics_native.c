#include <windows.h>
#include <pdh.h>
#include <stdio.h>
#include <stdlib.h>

BOOL WINAPI GetCounterValues(LPTSTR serverName, int n, char** instances);
BOOL WINAPI OutputError(int returnCode);

int main(int argc, char *argv[])
{
    int resultCode =
    if (GetCounterValues(NULL, argc-1, &argv[1]) != ERROR_SUCCESS) {
      resultCode = 1
    }
    return resultCode;
}

BOOL WINAPI OutputError(DWORD messageId)
{
    HANDLE hPdhLibrary = NULL;
    LPWSTR pMessage = NULL;
    DWORD_PTR pArgs[] = { (DWORD_PTR)L"<collectionname>" };
    DWORD dwErrorCode = PDH_PLA_ERROR_ALREADY_EXISTS;

    hPdhLibrary = LoadLibrary(L"pdh.dll");
    if (NULL == hPdhLibrary)
    {
        wprintf(L"LoadLibrary failed with %lu\n", GetLastError());
        return;
    }

    // Use the arguments array if the message contains insertion points, or you
    // can use FORMAT_MESSAGE_IGNORE_INSERTS to ignore the insertion points.

    if (!FormatMessage(FORMAT_MESSAGE_FROM_HMODULE |
                       FORMAT_MESSAGE_ALLOCATE_BUFFER |
                       FORMAT_MESSAGE_ARGUMENT_ARRAY,
                       hPdhLibrary,
                       dwErrorCode,
                       0,
                       (LPWSTR)&pMessage,
                       0,
                       //NULL))
                       (va_list*)pArgs))
    {
        wprintf(L"Format message failed with 0x%x\n", GetLastError());
        return;
    }

    wprintf(L"Formatted message: %s\n", pMessage);
    LocalFree(pMessage);
    return ERROR_SUCCESS;
}

BOOL WINAPI GetCounterValues(LPTSTR serverName, int instancesCount, char **instances)
{
    // Set to standard out to be unbuffered so we do not have to flush
    // each time we write out metric measurements
    setbuf(stdout, NULL);
    
    PDH_STATUS s;

    HQUERY hQuery;

    // Array to specify the performance object, counter and instance for
    // which performance data should be collected.

    // typedef struct _PDH_COUNTER_PATH_ELEMENTS {
    //   LPTSTR  szMachineName;
    //   LPTSTR  szObjectName;
    //   LPTSTR  szInstanceName;
    //   LPTSTR  szParentInstance;
    //   DWORD   dwInstanceIndex;
    //   LPTSTR  szCounterName;
    // } PDH_COUNTER_PATH_ELEMENTS, *PPDH_COUNTER_PATH_ELEMENTS;

    // Each element in the array is a PDH_COUNTER_PATH_ELEMENTS structure.
    PDH_COUNTER_PATH_ELEMENTS cpeTmpl[] =
    {
        { NULL, "processor", "_total", NULL, -1, "% processor time"},
        { NULL, "system", NULL, NULL, -1, "processor queue length"},
        { NULL, "memory", NULL, NULL, -1, "available bytes"},
        { NULL, "memory", NULL, NULL, -1, "pages/sec"},
        { NULL, "physicaldisk", "_total", NULL, -1 , "% disk time"},
        { NULL, "asp.net applications", "__total__", NULL, -1, "requests/sec"},
        { NULL, "asp.net", NULL, NULL, -1, "application restarts"},
        { NULL, "asp.net", NULL, NULL, -1, "request wait time"},
        { NULL, "asp.net", NULL, NULL, -1, "requests queued"},
        { NULL, ".net clr exceptions", "_global_", NULL, -1, "# of exceps thrown / sec"},
        { NULL, ".net clr memory", "_global_", NULL, -1, "# total committed bytes"},
        { NULL, "web service", "_total", NULL, -1, "get requests/sec"},
        { NULL, "web service", "_total", NULL, -1, "post requests/sec"},
        { NULL, "web service", "_total", NULL, -1, "current connections"}
    };

    const int cpeTmplCount = sizeof(cpeTmpl) / sizeof(cpeTmpl[0]);
    const int countersCount = cpeTmplCount;
    int i, j;

    HCOUNTER *hCounter = malloc(sizeof(HCOUNTER) * countersCount);
    PDH_COUNTER_PATH_ELEMENTS *cpe = malloc(sizeof(PDH_COUNTER_PATH_ELEMENTS) * countersCount);

    char szFullPath[MAX_PATH];
    DWORD cbPathSize;

    int ret = -1;

    PDH_FMT_COUNTERVALUE counterValue;

    // Only do this setup once.
    s = PdhOpenQuery(NULL, 0, &hQuery)
    if (s != ERROR_SUCCESS)
    {
        OutputError(s);
        return ret;
    }

    for (j = 0; j < cpeTmplCount; j++) {
        
        int index = i * cpeTmplCount + j;

        cbPathSize = sizeof(szFullPath);

        PDH_COUNTER_PATH_ELEMENTS cpeTmplItem = cpeTmpl[j];

        cpe[index].szMachineName = cpeTmplItem.szMachineName;
        cpe[index].szInstanceName = cpeTmplItem.szInstanceName;
        cpe[index].szObjectName = cpeTmplItem.szObjectName;
        cpe[index].szParentInstance = cpeTmplItem.szParentInstance;
        cpe[index].dwInstanceIndex = cpeTmplItem.dwInstanceIndex;
        cpe[index].szCounterName = cpeTmplItem.szCounterName;


        s = PdhMakeCounterPath(&cpe[index], szFullPath, &cbPathSize, 0);
        if (s != ERROR_SUCCESS)
        {
            fprintf(stderr,"MCP failed %08x\n", s);
            return ret;
        }

        if ((s = PdhAddCounter(hQuery, szFullPath, 0, &hCounter[index]))
            != ERROR_SUCCESS)
        {
            fprintf(stderr, "PAC failed %08x for %s\n", s, cpe[index].szCounterName);
            //return ret;
        }
    }

    for (i = 0; i < 2; i++)
    {
        Sleep(100);

        // Collect data as often as you need to.
        if ((s = PdhCollectQueryData(hQuery)) != ERROR_SUCCESS)
        {
            fprintf(stderr, "PCQD failed %08x\n", s);
            return ret;
        }

        if (i == 0) continue;

        // Extract the calculated performance counter value for each counter or instance.
        for (j = 0; j < countersCount; j++)
        {
        // boundary-plugin-iis: PGFCV failed 800007d8 8510384
            if ((s = PdhGetFormattedCounterValue(hCounter[j], PDH_FMT_DOUBLE,
                NULL, &counterValue)) != ERROR_SUCCESS)
            {
                fprintf(stderr, "PGFCV failed %08x %d\n", s, hCounter[j]);
                continue;
            }
            if (cpe[j].szInstanceName)
            {
                fprintf(stdout, "%s(%s)\\%s:%3.3f\n",
                    cpe[j].szObjectName,
                    cpe[j].szInstanceName,
                    cpe[j].szCounterName,
                    counterValue.doubleValue);
            }
            else
                fprintf(stdout, "%s\\%s:%3.3f\n",
                    cpe[j].szObjectName,
                    cpe[j].szCounterName,
                    counterValue.doubleValue);
        }
    }

    // Remove all the counters from the query.
    for (i = 0; i < countersCount; i++)
    {
        PdhRemoveCounter(hCounter[i]);
    }

    // Only do this cleanup once.
    PdhCloseQuery(hQuery);

    free(hCounter);
    free(cpe);

    return ERROR_SUCCESS;
}
