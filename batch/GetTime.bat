@echo Windows Management Instrumentation Command-line (WMIC) usage

@for /f %%I in ('wmic OS get LocalDateTime ^| find "."') do @set D=%%I
@echo Full LocalDateTime string: %D%
@echo Local Date Time : %D:~0,14%
@echo Local Date Time : %D:~0,4%-%D:~4,2%-%D:~6,2% %D:~8,2%:%D:~10,2%:%D:~12,2%
