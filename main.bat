:: SCRIPT FORENSE PARA RECOPILAR EVIDENCIAS VOLÁTILES
:: INFORMACIÓN OBTENIDA DE: INCIBE
@ECHO OFF
setlocal enabledelayedexpansion

:: CHECKEO DE PERMISOS
echo Se requieren permisos administrativos. Detectando permisos...

net session >nul 2>&1
if %errorLevel% == 0 (
    echo EXITO - Permisos administrativos confirmados.
    cd "%~d0%~p0"
) else (
    echo ERROR - Los permisos actuales son inadecuados.
    echo WARNING - Si continuas sin permisos de administrador, puede que algunas cosas no funcionen.
    set /p quest="Quieres continuar sin permisos de administrador? [S/n]: "
    if not "!quest!"=="S" if not "!quest!"=="s" (
        goto end
    )
)



:: MAIN
set log=%date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%
set ruta=%~d0%~p0output\%log%

mkdir "%ruta%"


:: VOLATIL
echo.
echo Recopilando Fecha y Hora del Sistema...
date /t > "%ruta%\FechaYHoraDeInicio.txt"
time /t >> "%ruta%\FechaYHoraDeInicio.txt"

echo.
echo Recopilando Informacion de la Red: Estado, Conexiones Activas, Puertos TCP y UDP abiertos...
    :: Estado de la red
    ipconfig /all > "%ruta%\EstadoDeLaRed.txt"
    :: Conexiones NetBIOS establecidas
    nbtstat -S > "%ruta%\ConexionesNetBIOSEstablecidas.txt"
    :: Ficheros transferidos recientemente mediante NetBIOS
    net file > "%ruta%\FicherosCopiadosMedianteNetBIOS.txt"
    :: Conexiones activas o puertos abiertos
    netstat -an |findstr /i "estado listening established" > "%ruta%\PuertosAbiertos.txt"
    netstat -anob > "%ruta%\AplicacionesConPuertosAbiertos.txt"

echo.
echo Recopilando Registro de Windows...
reg export HKEY_CLASSES_ROOT "%ruta%\HKCR.reg"
reg export HKEY_CURRENT_USER "%ruta%\HKCU.reg"
reg export HKEY_LOCAL_MACHINE "%ruta%\HKLM.reg"
reg export HKEY_USERS "%ruta%\HKU.reg"
reg export HKEY_CURRENT_CONFIG "%ruta%\HKCC.reg"

echo.
echo Recopilando Listado de Archivos y Directorios...
dir /t:w /a /s /o:d c:\ > "%ruta%\ListadoFicherosPorFechaDeModificacion.txt"
dir /t:a /a /s /o:d c:\ > "%ruta%\ListadoFicherosPorUltimoAcceso.txt"
dir /t:c /a /s /o:d c:\ > "%ruta%\ListadoFicherosPorFechaDeCreacion.txt"

echo.
echo Recopilando Datos Almacenados en Cache Navegadores...
copy "%UserProfile%\AppData\Local\Google\Chrome\User Data\Default\Web Data" "%ruta%\Web Data"

::copy %UserProfile%\AppData\Roaming\Mozilla\Firefox\Profiles\<random>\formhistory.sqlite "%ruta%\formhistory.sqlite"
mkdir "%ruta%\PerfilesFirefox"
xcopy %UserProfile%\AppData\Roaming\Mozilla\Firefox\Profiles\* "%ruta%\PerfilesFirefox\" /E /H /C /I

echo.
echo Recopilando Historial de los Principales Navegadores...
"%~d0%~p0BrowsingHistoryView.exe" /HistorySource 2 /LoadIE 1 /LoadFirefox 1 /LoadChrome 1 /LoadSafari 1 /stab "%ruta%\Historial.txt"

echo.
echo Recopilando Ultimas Busquedas en los Principales Motores de Busqueda...
"%~d0%~p0MyLastSearch.exe" /stab "%ruta%\UltimasBusquedas.txt"

echo.
echo Recopilando Unidades Mapeadas...
net use > "%ruta%\UnidadesMapeadas.txt"

echo.
echo Recopilando Carpetas Compartidas...
net share > "%ruta%\CarpetasCompartidas.txt"


:: NO VOLATIL
echo.
echo Recopilando Informacion del sistema...
systeminfo > "%ruta%\InformacionDelSistema.txt"

echo.
echo Recopilando Variables de entorno...
path > "%ruta%\VariablesDeEntorno.txt"

echo.
echo Recopilando Archivo hosts...
type c:\windows\system32\drivers\etc\hosts > "%ruta%\FicheroHosts.txt"

echo.
echo Recopilando Inicios de sesion realizados...
"%~d0%~p0NetUsers.exe" /History > "%ruta%\HistoricoUsuariosLogueados.txt"

echo.
echo Recopilando Ultimas acciones realizadas por el usuario...
"%~d0%~p0LastActivityView.exe" /stab "%ruta%\UltimasAcciones.txt"

echo.
echo Recopilando Tareas programadas...
schtasks > "%ruta%\TareasProgramadas.txt"

echo.
echo Recopilando Dispositivos USB conectados...
reg export "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\USBSTOR" "%ruta%\USBSTOR.reg"
reg export "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Enum\USB" "%ruta%\USB.reg"
reg export "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\DeviceClasses" "%ruta%\DeviceClasses.reg"
reg export "HKEY_LOCAL_MACHINE\System\MountedDevices" "%ruta%\MountedDevices.reg"

echo.
echo Recopilando Software instalado...
reg export "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" "%ruta%\SoftwareInstalado.reg"

echo.
echo.
echo EXITO - El analisis forense se ha completado con EXITO. Los archivos se han guardado en:
echo %ruta%

:fin
PAUSE