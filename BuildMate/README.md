# BuildMate Module

BuildMate provides backend and frontend tooling for OpsForge, including email integration with Google APIs.

---

## 🔒 Credentials Setup

BuildMate requires a Google OAuth client configuration to enable email integration.  
This file **must never be committed to Git**.

### Steps for Contributors

1. Copy the provided template:
   ```bash
   cp BuildMate/credentials.example.json BuildMate/credentials.json

2. Open BuildMate/credentials.json and replace:
    - YOUR_CLIENT_ID_HERE → your Google OAuth client ID
    - YOUR_CLIENT_SECRET_HERE → your Google OAuth client secret

3. Save the file locally.
   Do not commit credentials.json — it is excluded by .gitignore.

   Why?
   
      - credentials.json contains sensitive values (client_id, client_secret) that identify 
        your app.     
      - The template (credentials.example.json) is safe to commit and shows the required      
        structure.
      - Each contributor generates their own credentials in the Google Cloud Console.


### ⚙️ Running BuildMate

  1. 	Activate the root  environment:
      .venv\Scripts\activate   # Windows
      ource .venv/bin/activate # Linux/Mac

  2. 	Install dependencies:
      pip install -r BuildMate/requirements.txt

  3. 	Launch BuildMate:
      python backend/app.py


### 🛡️ Governance Notes

  - BuildMate/credentials.json → local only, ignored by Git
  - BuildMate/credentials.example.json → committed template for contributors
  - .gitignore ensures sensitive files are never tracked

---

### ✅ With this setup:

  - `.gitignore` protects secrets (`credentials.json`).  
  - Contributors use the **safe template** (`credentials.example.json`).  
  - `README.md` explains exactly how to configure credentials without risking leaks.  

---




