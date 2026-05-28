# SetupHub v3.0

Tool WPF PowerShell per automatizzare la preparazione di workstation Windows.

## Funzioni principali

- Installazione software tramite WinGet.
- Catalogo esteso con oltre 90 applicazioni.
- Rimozione opzionale di bloatware Windows.
- Profili predefiniti: Essential, Business, Developer, Cybersecurity, Multimedia, Gaming, Home, Clean, Complete.
- Profili personalizzati salvabili/caricabili in JSON.
- UI selezionabile in italiano e inglese.
- Report finale HTML/CSV e log TXT nella cartella `reports`.
- Sezione Credits.

## Avvio

Eseguire `Start_SetupHub.cmd` come amministratore, oppure lanciare:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\SetupHub_Setup.ps1
```

## Note su Microsoft Office

La voce `Microsoft 365 Apps / Office` usa il package WinGet `Microsoft.Office` e richiede una licenza/account Microsoft valido. In ambienti aziendali può essere preferibile usare `Microsoft Office Deployment Tool` con configuration XML personalizzato.

## Cartelle generate

- `profiles`: profili software personalizzati in JSON.
- `reports`: report HTML, CSV e log TXT generati a fine installazione.
