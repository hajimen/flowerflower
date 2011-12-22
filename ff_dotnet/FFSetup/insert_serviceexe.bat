FOR /f "DELIMS=" %%A IN ('..\select_serviceexe.bat') DO SET SEXE=%%A
cscript /nologo "..\WiRunSQL.vbs" "flowerflower_server_setup.msi" "INSERT INTO ServiceControl (ServiceControl, Name, Event, Component_) VALUES ('c53ade34', 'FFScheduler', '32', '%SEXE%')"
