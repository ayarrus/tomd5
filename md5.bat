@echo off
setlocal EnableDelayedExpansion

:: Inicializar valores y funciones
call :md5_init

:: Leer el archivo y calcular la longitud en bytes y bits
set "fileName=%~1"
call :read_file

:: Agregar relleno y dividir el mensaje en bloques
call :padding_and_blocks

:: Procesar cada bloque y calcular el hash MD5
call :process_blocks

:: Combinar los valores de hash y mostrar el hash MD5 final
call :md5_final

goto :eof

:: Funciones
:md5_init
set /A F1=0, G1=1, H1=2, I1=3
set /A INIT_A=0x67452301, INIT_B=0xEFCDAB89, INIT_C=0x98BADCFE, INIT_D=0x10325476
set /A A=%INIT_A%, B=%INIT_B%, C=%INIT_C%, D=%INIT_D%

:: Inicializar los valores de cambio y la tabla T
for /L %%i in (1,1,64) do (
  set /A "SHIFT_AMTS[%%i]=((%%i - 1) %% 4) * 5 + 1 + (%%i - 1) / 16 * 4"
  set /A "TABLE_T[%%i]=floor(4294967296 * abs(sin(%%i)))"
)
goto :eof

:read_file
for /F "tokens=1-3 delims=:" %%a in ('%SystemRoot%\System32\find.exe /V /N "" %fileName%') do (
  if %%a GTR 0 (
    set "line%%a=%%b"
    if "%%c" NEQ "" set "line%%a=!line%%a!:%%c"
  )
)

set "messageLenBytes=0"
for /L %%i in (1,1,65536) do (
  set "len=0"
  for %%c in (!line%%i!) do set /A "len+=1"
  set /A "messageLenBytes+=len"
  if !len! LSS 16 exit /B
)
goto :eof

:padding_and_blocks
set /A "messageLenBits=messageLenBytes * 8"
set /A "numBlocks=(messageLenBits + 64) / 512 + 1"
set /A "totalLen=numBlocks * 64"
set /A "paddingSize=totalLen - messageLenBytes"

for /L %%i in (1,1,%paddingSize%) do set "paddingBytes[%%i]=00"
set "paddingBytes[1]=80"

:: Copiar el contenido del archivo en un array
set "index=0"
for /L %%i in (1,1,65536) do (
  if "!line%%i!"=="" exit /B
  for /L %%j in (0,1,15) do (
    set "hex=!line%%i:~%%j,2!"
    if "!hex!" NEQ "" set /A "message[index++]=0x!hex!"
  )
)
goto :eof

:process_blocks
set /A "nBlocks=messageLenBytes / 64"
for /L %%i in (0,1,%nBlocks%) do (
  for /L %%j in (0,4,60) do (
    set /A "block[%%j]=message[%%i * 64 + %%j], block[%%j+1]=message[%%i * 64 + %%j + 1], block[%%j+2]=message[%%i * 64 + %%j + 2], block[%%j+3]=message[%%i * 64 + %%j + 3]"
  )

  for /L %%j in (0,1,15) do (
    set /A "M[%%j]=block[%%j * 4] + (block[%%j * 4 + 1] << 8) + (block[%%j * 4 + 2] << 16) + (block[%%j * 4 + 3] << 24)"
  )

  set /A "AA=A, BB=B, CC=C, DD=D"

  for /L %%j in (1,1,64) do (
    call :md5_round %%j
  )

  set /A "A=(A + AA) %% 4294967296, B=(B + BB) %% 4294967296, C=(C + CC) %% 4294967296, D=(D + DD) %% 4294967296"
)
goto :eof

:md5_round
set /A "round=%1"
set /A "F=0, G=0"
if !round! LSS 17 (
  set /A "F=(B & C) | ((~B) & D), G=round - 1"
) else if !round! LSS 33 (
  set /A "F=(D & B) | ((~D) & C), G=(5 * round + 1) %% 16"
) else if !round! LSS 49 (
  set /A "F=B ^ C ^ D, G=(3 * round + 5) %% 16"
) else (
  set /A "F=C ^ (B | (~D)), G=(7 * round) %% 16"
)

set /A "TEMP=D, D=C, C=B"
set /A "B=B + (((A + F + TABLE_T[round] + M[G]) << SHIFT_AMTS[round]) | ((A + F + TABLE_T[round] + M[G]) >> (32 - SHIFT_AMTS[round])))"
set /A "B=B %% 4294967296"
set /A "A=TEMP"
goto :eof

:md5_final
set "MD5=%A%"
call :int32_to_hex8 B
set "MD5=%MD5%%HEX8%"
call :int32_to_hex8 C
set "MD5=%MD5%%HEX8%"
call :int32_to_hex8 D
set "MD5=%MD5%%HEX8%"

echo MD5: %MD5%
goto :eof

:int32_to_hex8
set /A "value=%1, highByte=(value >> 16) & 0xFFFF, lowByte=value & 0xFFFF"
set /A "highHighNibble=(highByte >> 12) & 0xF, highLowNibble=(highByte >> 8) & 0xF, lowHighNibble=(highByte) & 0xF, lowLowNibble=(highByte << 4) >> 12"
call :hex_nibble_to_char highHighNibble
set "HEX8=%char%"
call :hex_nibble_to_char highLowNibble
set "HEX8=%HEX8%%char%"
call :hex_nibble_to_char lowHighNibble
set "HEX8=%HEX8%%char%"
call :hex_nibble_to_char lowLowNibble
set "HEX8=%HEX8%%char%"

set /A "highHighNibble=(lowByte >> 12) & 0xF, highLowNibble=(lowByte >> 8) & 0xF, lowHighNibble=(lowByte >> 4) & 0xF, lowLowNibble=lowByte & 0xF"
call :hex_nibble_to_char highHighNibble
set "HEX8=%HEX8%%char%"
call :hex_nibble_to_char highLowNibble
set "HEX8=%HEX8%%char%"
call :hex_nibble_to_char lowHighNibble
set "HEX8=%HEX8%%char%"
call :hex_nibble_to_char lowLowNibble
set "HEX8=%HEX8%%char%"
goto :eof

:hex_nibble_to_char
if %1 EQU 0 (set "char=0") else if %1 EQU 1 (set "char=1") else if %1 EQU 2 (set "char=2") else if %1 EQU 3 (set "char=3") else if %1 EQU 4 (set "char=4") else if %1 EQU 5 (set "char=5") else if %1 EQU 6 (set "char=6") else if %1 EQU 7 (set "char=7") else if %1 EQU 8 (set "char=8") else if %1 EQU 9 (set "char=9") else if %1 EQU 10 (set "char=A") else if %1 EQU 11 (set "char=B") else if %1 EQU 12 (set "char=C") else if %1 EQU 13 (set "char=D") else if %1 EQU 14 (set "char=E") else (set "char=F")
goto :eof
