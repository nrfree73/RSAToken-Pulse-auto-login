#include <MsgBoxConstants.au3>
#include <Constants.au3>
#include <StringConstants.au3>
#include <Misc.au3>
#Include <file.au3>
#include <Crypt.au3>

$idrh=@UserName ; votre Idrh récupéré par variable systeme
$idrh=StringReplace($idrh,"_a","") ;inhiber si on veut passer par compte admin CORP

$Pin=""
$tokenname=""
$passcode="" ;code à 6 chiffres

if  FileExists(@scriptdir & "\" & $idrh & "_Pin.rsa") Then ;existe !
$file=FileOpen(@scriptdir & "\" & $idrh & "_Pin.rsa",0)
$line=FileReadLine($file,1)
$Pin=BinaryToString($line)
if $Pin="" Then
   fileclose($file)
   FileDelete(@scriptdir & "\" & $idrh & "_Pin.rsa")
   MsgBox(0,"no pin !","restart tool to write Pin",9)
   Exit
   EndIf
Else
$Pin=InputBox("RSA Pin ?","renseignez votre code PIN RSA Token","")
$file=FileOpen(@scriptdir & "\" & $idrh & "_Pin.rsa",2)
FileWriteLine($file,Stringtobinary($Pin) & @crlf)
fileclose($file)
MsgBox(0,"Info !","file created in: " & @crlf & @scriptdir & "\" & $idrh & "_Pin.rsa",7)
EndIf

$idrh=$idrh & "@laposte.fr"
;$Pin = "6007"  ;votre PIN Token RSA Logiciel
;$tokenname="000517188111" ; à renseigner !

Run("C:\Program Files (x86)\RSA SecurID Software Token\SecurID.exe","", @SW_MAXIMIZE )
sleep(1500)
;$hWin = WinGetHandle("[CLASS:QWidget; TITLE:" & $tokenname & " - RSA SecurID Token]", "")
$hWin = WinGetHandle("[CLASS:QWidget]", "")

while 1
 if WinActive("[CLASS:QWidget]") Then ; ; INSTANCE:4
WinActivate($hWin)
ClipPut($Pin)
Send("^v")
Send("{ENTER}")
clipput("")
$hCtrl = ControlGetHandle($hWin, "", "[CLASS:QWidget; INSTANCE:4]")
ControlFocus($hWin, "", $hCtrl)
sleep(500)

Send("{TAB}")
Send("{ENTER}")

MsgBox(0,"logon Pulse Secure..","Press [OK] when RSA Token ready with at last 10 seconds...")
$passcode = ClipGet()

	ExitLoop
	EndIf
 WEnd


; tooltip("press button [copy] when ready",5,5)
Local $hDLL = DllOpen("user32.dll")
While 1
   exitloop ;inhiber loop
    If _IsPressed(0x01,$hDLL) Then                                        ; Check if left mouse button is clicked.
       sleep(500)
     $passcode = ClipGet()
	 ToolTip("",5,5)
	 ExitLoop ;sortir de la boucle !
    EndIf
WEnd
ProcessClose("SecurID.exe")
;MsgBox(0,"","username: " & $idrh & @crlf & "token: " & $passcode)

if $passcode="" Then
   MsgBox(0,"Warning !","RSA Token..." & @crlf & "mdp non recupéré !" & @crlf & "fin du programme !",7)
Exit
EndIf


;;; Pulse secure

AutoItSetOption("SendKeyDelay", 10)

; tooltip("press button [F12], sending user and password, when 'connection: LBR 335 DSEM' is ready for connection !" & @crlf & "press button [ESC] : exit program...",5,5,$idrh & " passcode: " & $passcode)

Run("C:\Program Files (x86)\Common Files\Pulse Secure\JamUI\Pulse.exe -show","", @SW_MAXIMIZE )
sleep(1500)
$hWin = WinGetHandle("[CLASS:JamShadowClass]", "")
WinActivate($hWin)

;ControlClick("[CLASS:JamShadowClass]", "", "[ClassnameNN:JAM_BitmapButton8]")
ControlClick("[CLASS:JamShadowClass]", "", "[ID:10104]") ;instance:8 clic connexion Bouton

$hWin = WinGetHandle("[Handle:0x0016063E]", "") ;userID & pssword window PS
WinActivate($hWin)
tooltip("waiting for Pulse Secure login window ..." & @crlf & "Credentials: " & $idrh & " ; " & $passcode,5,5 ,"DSEM/EAPI69/NR  ( press [ESC] to exit program, if required... )")

while 1
    ; tooltip("waiting for Pulse Secure login window ...",5,5,1,   $TIP_BALLOON )
;	TrayTip("logon Pulse Secure", "waiting for Pulse Secure login window..." & @crlf & "and then send credentials...", 10, $TIP_ICONASTERISK)
Local $hDLL = DllOpen("user32.dll")

 if WinActive("[Title:Connectez-vous à : LBR 335 DSEM]") Then

	; if WinActive("[Title:Connectez-vous à : LBR 335 DSEM 'RSA' token niko]") Then


$hWin = WinGetHandle("[CLASS:JamShadowClass]", "") ;userID & pssword window PS
WinActivate($hWin)
ControlClick("[CLASS:Button]", "", "[ID:2]")

tooltip("Sending Pulse Secure password ...",5,5)
       ;sleep(250)
     Send($idrh)
	   sleep(250)
	 Send("{TAB}")
	 sleep(250)
	 send($passcode)
	 sleep(250)
	 Send("{TAB}")
	 sleep(250)
	 send("{ENTER}")
     tooltip("",5,5)


ExitLoop
	; Exit
	 EndIf

 If _IsPressed("1B",$hDLL) Then ;exit program
	Exit
	EndIf

WEnd
;

;;;

Exit