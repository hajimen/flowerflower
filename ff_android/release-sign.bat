set PATH=%PATH%;%JAVA_HOME%\bin
jarsigner -verbose -keystore C:\Users\Yotsuya\.android\release.keystore bin\ff_android-release-unsigned.apk kouchabutton-2
C:\Users\Yotsuya\bin\android-sdk-windows\tools\zipalign -v 4 bin\ff_android-release-unsigned.apk bin\ff_android-release.apk
