# _SleepEx
Funktionssammlung für AutoIt, für ein präziseres Sleep und eine einfachere Angabe von Millisekunden



## Funktionsaufruf und Beispiel

```autoit
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
```

Ergebnisse in Millisekunden:
```
0.182804220570591
2107.88064147315
4.27925162528962
1021.42623648781
2000.37281600462
60096.8887882523
```

## Voraussetzungen

AutoIt


## Installation

Als Funktion in das eigene Programm kopieren, oder als UDF in das Include Verzeichnis von AutoIt kopieren.


## Diskusion und Vorschläge

[autoit.de](https://autoit.de/thread/17556-sleepex-und-ms-konvertierung-von-ms/)

## ToDo


## Authors
Thorsten Willert

Andreas Karlsson (monoceres) - Function: _HighPrecisionSleep

[Homepage](http://www.thorsten-willert.de/)

## Lizenz
Das Ganze steht unter der [MIT](https://github.com/THWillert/HomeMatic_CSS/blob/master/LICENSE) Lizenz
.
