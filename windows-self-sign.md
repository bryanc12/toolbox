# 🔏 Windows EXE Code-Signing

A quick-reference guide to **digitally signing Windows executable (.exe) files** using locally generated self-signed certificates.

> [!WARNING]  
> **Smart App Control (SAC) Restriction:** This local self-signed method will **only satisfy Windows security policies on your local machine** (and only after forcing trust). If you intend to distribute your software to external users, Windows requires a certificate chaining to an official public Certificate Authority (CA) or deployment via Microsoft Store Publishing.

---

## 🛠️ Step-by-Step Walkthrough

### Step 1: Install Windows SDK Signing Tools
1. Download the official **Windows SDK Installer**.
2. Run the setup wizard and uncheck all components **except** `Windows SDK Signing Tools for Desktop Apps`. This reduces the payload footprint down to ~16 MB.

### Step 2: Generate the Local Code-Signing Certificate
Launch **PowerShell as an Administrator** and run the following snippet:

```powershell
New-SelfSignedCertificate -Type CodeSigning -Subject "CN=MyLocalApps" -CertStoreLocation "Cert:\CurrentUser\My" -FriendlyName "Local Dev Cert"
```

### Step 3: Force Windows to Trust Your Certificate
Because this certificate is generated locally, the OS will flag it as untrusted until you manually register it:
1. Press `Win + R`, type `certmgr.msc`, and press **Enter** to open the User Certificate Manager.
2. Navigate to **Personal** > **Certificates**.
3. Right-click your newly created **MyLocalApps** certificate and select **Copy**.
4. Scroll down to **Trusted Root Certification Authorities** > **Certificates**.
5. Right-click an empty area in the main pane and select **Paste**.

### Step 4: Sign Your Executable File
Open a standard **Command Prompt as an Administrator** and change your directory to the Windows SDK binaries path:

```cmd
cd "C:\Program Files (x86)\Windows Kits\10\bin\<YOUR_SDK_VERSION>\x64"
```

Execute the `signtool.exe` utility using automated selection flags and a secure timestamping server:

```cmd
signtool sign /a /fd SHA256 /tr http://digicert.com /td SHA256 "C:\Path\To\YourApp.exe"
```

### Step 5: Verify the Digital Signature
* Try execute your binary now or
* Right-click your newly signed `.exe` file and open its **Properties**.
* Confirm the presence of a **Digital Signatures** tab showing your certificate and a valid timestamp.

---

## 🖥️ Optional: Enable Global Terminal Access (Environment Variables)

If you want to run the `signtool` command from **any folder directory** without changing directories (`cd`) first, you must add the Windows SDK directory path to your system's Environment Variables.

> [!CAUTION]
> If your terminal throws a `'signtool' is not recognized as an internal or external command` error, follow these configuration steps:

1. Press `Win + S`, type **Environment Variables**, and select **Edit the system environment variables**.
2. Click the **Environment Variables...** button at the bottom.
3. Under *System variables*, locate and select the **Path** variable, then click **Edit...**.
4. Click **New** and paste the absolute path to your `x64` toolset. For example:
   ```text
   C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64
   ```
5. Click **OK** to save and close all windows.
6. **Restart your terminal** or IDE for changes to take effect. You can now sign files globally using:
   ```cmd
   signtool sign /a /fd SHA256 /tr http://digicert.com /td SHA256 "YourApp.exe"
   ```

---

## 🔑 Command Line Flag Reference

| Flag | Function | Purpose |
| :--- | :--- | :--- |
| `/a` | Automatic Selection | Finds and picks the best matching certificate in your local store. |
| `/fd SHA256` | File Digest Algorithm | Forces the file hash computation to use modern SHA-256 encryption. |
| `/tr <URL>` | RFC 3161 Timestamp | Directs the utility to contact an external time authority server. |
| `/td SHA256` | Timestamp Digest | Ensures the counter-signature timestamp itself uses SHA-256 hashing. |

> [!NOTE]  
> Using `/tr` and `/td` ensures the application signature remains valid and executable even after your local certificate naturally expires.
