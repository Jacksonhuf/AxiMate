; AxiMate Ripple (Powered by CoPaw) - Windows NSIS installer.
; Built by Build-RippleWindows.ps1 after conda-pack (same layout as upstream CoPaw desktop).
; Requires: makensis, dist/win-unpacked with Ripple Desktop.vbs / .bat launchers.

!include "MUI2.nsh"
!define MUI_ABORTWARNING
!define MUI_ICON "${UNPACKED}\icon.ico"
!define MUI_UNICON "${UNPACKED}\icon.ico"

!ifndef COPAW_VERSION
  !define COPAW_VERSION "0.0.0"
!endif
!ifndef OUTPUT_EXE
  !define OUTPUT_EXE "dist\Ripple-Setup-${COPAW_VERSION}.exe"
!endif

Name "AxiMate Ripple"
OutFile "${OUTPUT_EXE}"
InstallDir "$LOCALAPPDATA\AxiMateRipple"
InstallDirRegKey HKCU "Software\AxiMateRipple" "InstallPath"
RequestExecutionLevel user

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "SimpChinese"

!ifndef UNPACKED
  !define UNPACKED "dist\win-unpacked"
!endif

Section "AxiMate Ripple" SEC01
  SetOutPath "$INSTDIR"
  File /r "${UNPACKED}\*.*"
  WriteRegStr HKCU "Software\AxiMateRipple" "InstallPath" "$INSTDIR"
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  CreateShortcut "$SMPROGRAMS\AxiMate Ripple.lnk" "$INSTDIR\Ripple Desktop.vbs" "" "$INSTDIR\icon.ico" 0
  CreateShortcut "$DESKTOP\AxiMate Ripple.lnk" "$INSTDIR\Ripple Desktop.vbs" "" "$INSTDIR\icon.ico" 0
SectionEnd

Section "Uninstall"
  Delete "$SMPROGRAMS\AxiMate Ripple.lnk"
  Delete "$DESKTOP\AxiMate Ripple.lnk"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKCU "Software\AxiMateRipple"
SectionEnd
