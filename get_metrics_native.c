#define _UNICODE
#define UNICODE
#include <tchar.h>
#include <windows.h>
#include <pdh.h>
#include <pdhmsg.h>
#include <stdio.h>
#include <wchar.h>
#include <stdlib.h>

BOOL WINAPI GetCounterValues(LPTSTR serverName, int n, _TCHAR** instances);
BOOL WINAPI OutputError(_TCHAR *pMessage, DWORD returnCode);

int main(int argc, _TCHAR *argv[])
{
    int resultCode = 0; 
    DWORD dwErrorCode = PDH_NO_DATA;

    if (GetCounterValues(NULL, argc-1, &argv[1]) != ERROR_SUCCESS)
    {
      resultCode = 1;
    }
    return resultCode;
}

BOOL WINAPI OutputError(_TCHAR *pMessage, DWORD dwErrorCode)
{
    HANDLE hPdhLibrary = NULL;
    LPWSTR pErrorMessage = NULL;
    DWORD_PTR pArgs[] = { (DWORD_PTR)L"<collectionname>" };

    hPdhLibrary = LoadLibrary(_TEXT("pdh.dll"));
    if (NULL == hPdhLibrary)
    {
        fwprintf(stderr, _TEXT("LoadLibrary() failed with %lu\n"), GetLastError());
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
                       (LPWSTR)&pErrorMessage,
                       0, NULL))
    {
        fwprintf(stderr, _TEXT("Format message failed with 0x%x\n"), GetLastError());
        return;
    }

    fwprintf(stderr, _TEXT("%s, return code: %x \"%s\"\n"), pMessage, dwErrorCode, pErrorMessage);
    LocalFree(pErrorMessage);
    return ERROR_SUCCESS;
}

BOOL WINAPI GetCounterValues(LPTSTR serverName, int instancesCount, _TCHAR **instances)
{
    // Set to standard out to be unbuffered so we do not have to flush
    // each time we write out metric measurements
    setbuf(stdout, NULL);
    
    PDH_STATUS status;

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
        { NULL, _TEXT("processor"), _TEXT("_total"), NULL, -1, _TEXT("% processor time")},
        { NULL, _TEXT("system"), NULL, NULL, -1, _TEXT("processor queue length")},
        { NULL, _TEXT("memory"), NULL, NULL, -1, _TEXT("available bytes")},
        { NULL, _TEXT("memory"), NULL, NULL, -1, _TEXT("pages/sec")},
        { NULL, _TEXT("physicaldisk"), _TEXT("_total"), NULL, -1 , _TEXT("% disk time")},
        { NULL, _TEXT("asp.net applications"), _TEXT("__total__"), NULL, -1, _TEXT("requests/sec")},
        { NULL, _TEXT("asp.net"), NULL, NULL, -1, _TEXT("application restarts")},
        { NULL, _TEXT("asp.net"), NULL, NULL, -1, _TEXT("request wait time")},
        { NULL, _TEXT("asp.net"), NULL, NULL, -1, _TEXT("requests queued")},
        { NULL, _TEXT(".net clr exceptions"), _TEXT("_global_"), NULL, -1, _TEXT("# of exceps thrown / sec")},
        { NULL, _TEXT(".net clr memory"), _TEXT("_global_"), NULL, -1, _TEXT("# total committed bytes")},
        { NULL, _TEXT("web service"), _TEXT("_total"), NULL, -1, _TEXT("get requests/sec")},
        { NULL, _TEXT("web service"), _TEXT("_total"), NULL, -1, _TEXT("post requests/sec")},
        { NULL, _TEXT("web service"), _TEXT("_total"), NULL, -1, _TEXT("current connections")}
    };

    const int cpeTmplCount = sizeof(cpeTmpl) / sizeof(cpeTmpl[0]);
    const int countersCount = cpeTmplCount;
    int i, j;

    HCOUNTER *hCounter = malloc(sizeof(HCOUNTER) * countersCount);
    PDH_COUNTER_PATH_ELEMENTS *cpe = malloc(sizeof(PDH_COUNTER_PATH_ELEMENTS) * countersCount);

    _TCHAR szFullPath[MAX_PATH];
    _TCHAR szMessage[MAX_PATH];
    DWORD cbPathSize;

    int result = -1;

    PDH_FMT_COUNTERVALUE counterValue;

    // Only do this setup once.
    status = PdhOpenQuery(NULL, 0, &hQuery);
    if (status != ERROR_SUCCESS)
    {
        OutputError(_TEXT("PdhOpenQuery() failed"), status);
        return result;
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


        status = PdhMakeCounterPath(&cpe[index], szFullPath, &cbPathSize, 0);
        if (status != ERROR_SUCCESS)
        {
            OutputError(_TEXT("PdhMakeCounterPath() failed"), status);
            return result;
        }

        status = PdhAddCounter(hQuery, szFullPath, 0, &hCounter[index]);
        if (status != ERROR_SUCCESS)
        {
            swprintf(szMessage, sizeof(szMessage), _TEXT("PdhAddCounter() failed for \"%s\""), cpe[index].szCounterName);
            OutputError(szMessage, status);
            return result;
        }
    }

    for (i = 0; i < 2; i++)
    {
        Sleep(100);

        // Collect data as often as you need to.
        status = PdhCollectQueryData(hQuery);
        if (status != ERROR_SUCCESS)
        {
            OutputError(_TEXT("PdhCollectQuery() failed"), status);
            return result;
        }

        if (i == 0) continue;

        // Extract the calculated performance counter value for each counter or instance.
        for (j = 0; j < countersCount; j++)
        {
            status = PdhGetFormattedCounterValue(hCounter[j], PDH_FMT_DOUBLE, NULL, &counterValue);
            if (status != ERROR_SUCCESS)
            {
                wsprintf(szMessage, _TEXT("PdhGetFormattedCounterValue() failed for %d"), hCounter[j]);
                OutputError(szMessage, status);
                continue;
            }
            if (cpe[j].szInstanceName)
            {
                fwprintf(stdout, _TEXT("%s(%s)\\%s:%3.3f\n"),
                    cpe[j].szObjectName,
                    cpe[j].szInstanceName,
                    cpe[j].szCounterName,
                    counterValue.doubleValue);
            }
            else
                fwprintf(stdout, _TEXT("%s\\%s:%3.3f\n"),
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
