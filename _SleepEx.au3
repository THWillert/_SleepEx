Global $_SLEEPEX_CORR

Main()

Func Main()
    ; Laufzeitkorrektur fuer _SleepEx()
    ; - stimmt nicht ganz, macht aber dennoch das Ergebnis etwas genauer
    _SleepEx_Corr()
    ConsoleWrite($_SLEEPEX_CORR & @CRLF)

    MsgBox(0,"2 Minuten, 15 Sekunden und 4 ms:", _2MS("0:2:15:4"))

    Local $t = TimerInit()
    _SleepEx("00:00:02:0100") ; 2 sec, 100 ms
    ConsoleWrite(TimerDiff($t) & @CRLF)

    Local $t = TimerInit()
    _SleepEx("0:0:0:4") ; 4 ms !!!
    ConsoleWrite(TimerDiff($t) & @CRLF)

    Local $t = TimerInit()
    Sleep(_MS("0:0:1:20")) ; 1 sec 20 ms
    ConsoleWrite(TimerDiff($t) & @CRLF)

    $t = TimerInit()
    _SleepEx(2) ; 2 sec
    ConsoleWrite(TimerDiff($t) & @CRLF)

    $t = TimerInit()
    _SleepEx(1, "m") ; 1 min
    ConsoleWrite(TimerDiff($t) & @CRLF)


EndFunc   ;==>Main

; #FUNCTION# ===================================================================
; Name ..........: _SleepEx_Corr
; Description ...: Correction time for _SleepEx
; AutoIt Version : V3.3.0.0
; Syntax ........: _SleepEx_Corr()
; Parameter(s): .: $iMax        - Optional: (Default = 10) : max correction time
; Return Value ..: Success      - Global var $_SLEEPEX_CORR
;                  Failure      -
; Author(s) .....: Thorsten Willert
; Date ..........: Sat Feb 06 14:10:40 CET 2010
; ==============================================================================
Func _SleepEx_Corr($iMax = 10)
    Local $Time = 0, $t
    If Not IsDeclared("_SLEEPEX_CORR") Then Assign("_SLEEPEX_CORR", 0, 2)
    For $i = 0 To 4
        $t = TimerInit()
        _SleepEx("00:00:00:200")
        $Time += TimerDiff($t) - 200
    Next
    $_SLEEPEX_CORR = $Time / 5
    If $_SLEEPEX_CORR > $iMax Then $_SLEEPEX_CORR = $iMax
EndFunc   ;==>_SleepEx_Corr

; #FUNCTION# ===================================================================
; Name ..........: _SleepEx
; Description ...: Extended sleep
; AutoIt Version : V3.3.0.0
; Requirement(s).: _MS(), _HighPrecisionSleep()
; Syntax ........: _SleepEx($vTime[, $sBase = "s"])
; Parameter(s): .: $vTime       - in ms
;                  $sBase       - Optional: (Default = "s") :
;                               | d = day
;                               | h = hour
;                               | m = minute
;                               | s = second
;                               | ms = millisecond
; Return Value ..: Success      - 1
;                  Failure      - 0
; Author(s) .....: Thorsten Willert
; Date ..........: Sat Feb 06 15:15:31 CET 2010
; Example .......: Yes
; _SleepEx("0:0:2:100") ; 2 sec, 100 ms
; ==============================================================================
Func _SleepEx($vTime, $sBase = "s")
    If Not IsString($vTime) And $vTime < 1 Then Return 0
    $vTime = _MS($vTime, $sBase, True, False)
    Local $iaMS[1]

    If $vTime < 2147483647 Then
        If IsDeclared("_SLEEPEX_CORR") And $vTime >= 500 Then $vTime -= $_SLEEPEX_CORR
        _HighPrecisionSleep($vTime * 1000)
        Return SetError(@error, 0, Not @error)
    Else
        Local $iTMP = $vTime
        Local $t = TimerInit()
        While $iTMP > 2147483647
            $iTMP -= 2147483647
            If IsDeclared("_SLEEPEX_CORR") Then $iTMP -= $_SLEEPEX_CORR
            $iaMS[UBound($iaMS) - 1] = $iTMP * 1000
            ReDim $iaMS[UBound($iaMS) + 1]
        WEnd
        $iaMS[0] -= TimerDiff($t) * 1000

        For $i = 0 To UBound($iaMS) - 2
            _HighPrecisionSleep($iaMS[$i])
            If @error Then Return SetError(@error, 0, 0)
        Next
        Return SetError(0, 0, 1)
    EndIf
EndFunc   ;==>_SleepEx

; #FUNCTION# ===================================================================
; Name ..........: _MS
; Description ...: Converts to ms
; AutoIt Version : V3.3.0.0
; Syntax ........: _MS($vTime[, $sBase = "s"[, $bCorr = True[, $bSleep = True]]])
; Parameter(s): .: $vTime       - int + $sBase
;                               | "0:0:0:0" = hour:minute:second:millisecond
;                  $sBase       - Optional: (Default = "s") :
;                               | d = day
;                               | h = hour
;                               | m = minute
;                               | s = second
;                               | ms = millisecond
;                  $bCorr       - Optional: (Default = True) : subtracts the functions runtime from the return value
;                  $bSleep      - Optional: (Default = True) : limits the return value for sleep to 2147483647 and sets @error to 3
; Return Value ..: Success      - ms
;                  Failure      - 0 / @error = 3, 2147483647
;                  @ERROR       - 1 = incorrect format for "0:0:0:0"
;                               | 2 = incorrect $sBase parameter
;                               | 3 = $vTime > 2147483647 if $bSleep = True
; Author(s) .....: Thorsten Willert
; Date ..........: Sat Feb 06 15:25:11 CET 2010
; Example .......: Yes
; $iMS = _MS(2) ; 2 sec
; $iMS = _MS(1, "m") ; 1 min
; ==============================================================================
Func _MS($vTime, $sBase = "s", $bCorr = True, $bSleep = True)
    Local $t = TimerInit()
    Local $iRet = 0
    Local $aTMP
    Local $aBase[4] = ["h", "d", "s", "ms"]

    While 1
        If StringInStr($vTime, ":") Then
            $aTMP = StringSplit($vTime, ":", 2)
            If @error Or UBound($aTMP) <> 4 Then Return SetError(1, 0, 0)
            For $i = 0 To 3
                If $aTMP[$i] Then $iRet += _MS(Int($aTMP[$i]), $aBase[$i], $bCorr)
            Next
            ExitLoop
        Else
            Switch $sBase
                Case "ms"
                    $iRet = $vTime
                    ExitLoop
                Case "s"
                    $iRet = $vTime * 1000
                    ExitLoop
                Case "m"
                    $iRet = $vTime * 60000
                    ExitLoop
                Case "h"
                    $iRet = $vTime * 360000
                    ExitLoop
                Case "d"
                    $iRet = $vTime * 86400000
                    ExitLoop
                Case Else
                    Return SetError(2, 0, 0)
            EndSwitch
        EndIf
    WEnd

    ; maximum sleep time (24h)
    If $bSleep And $iRet > 2147483647 Then Return SetError(3, 0, 2147483647)

    If $bCorr = True Then Return $iRet - TimerDiff($t)

    Return $iRet
EndFunc   ;==>_MS

Func _2MS($vTime)
    Return _MS($vTime, "", False, False)
EndFunc

; #FUNCTION#;===============================================================================
;
; Name...........: _HighPrecisionSleep()
; Description ...: Sleeps down to 0.1 microseconds
; Syntax.........: _HighPrecisionSleep( $iMicroSeconds, $hDll=False)
; Parameters ....:  $iMicroSeconds      - Amount of microseconds to sleep
;                  $hDll  - Can be supplied so the UDF doesn't have to re-open the dll all the time.
; Return values .: None
; Author ........: Andreas Karlsson (monoceres)
; Modified.......:
; Remarks .......: Even though this has high precision you need to take into consideration that it will take some time for autoit to call the function.
; Related .......:
; Link ..........;
; Example .......; No
;
;;==========================================================================================
Func _HighPrecisionSleep($iMicroSeconds, $hDll = False)
    Local $hStruct, $bLoaded
    If Not $hDll Then
        $hDll = DllOpen("ntdll.dll")
        If $hDLL = -1 Then Return SetError(1)
        $bLoaded = True
    EndIf
    $hStruct = DllStructCreate("int64 time;")
    DllStructSetData($hStruct, "time", -1 * ($iMicroSeconds * 10))
    DllCall($hDll, "dword", "ZwDelayExecution", "int", 0, "ptr", DllStructGetPtr($hStruct))
    If $bLoaded Then DllClose($hDll)
EndFunc   ;==>_HighPrecisionSleep
