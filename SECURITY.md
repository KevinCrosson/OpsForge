# OpsForge Security Policy

OpsForge enforces strict security practices to ensure contributor safety, compliance, and ecosystem integrity.  
This document defines secure coding standards, vulnerability reporting, and contributor responsibilities.

---

## 🔐 Secure Coding Practices
- Follow least-privilege principles in all modules.  
- Validate inputs and sanitize outputs to prevent injection attacks.  
- Use UTF-8 encoding consistently across scripts and documentation.  
- Enforce CI/CD hygiene with automated validation and audit logging.  
- Respect module boundaries:
  - **BuildMate** → software-only (construction SaaS workflows, compliance logging, project ops).  
  - **DroneOps** → all drone hardware and aerial intelligence (surveying, surveillance, counter‑drone, telemetry).  

---

## 🛡️ Vulnerability Reporting
OpsForge maintains a responsible disclosure process.  
- Report vulnerabilities privately via GitHub Issues using the **“Security Disclosure”** label.  
- Do not disclose vulnerabilities publicly until remediation is confirmed.  
- Follow the process in [SECURITY-DISCLOSURE.md](SECURITY-DISCLOSURE.md).  

---

## 🚫 Prohibited Actions
- Unauthorized commercial use of OpsForge modules.  
- Mixing drone hardware references into BuildMate (software-only).  
- Circumventing CI/CD validation or audit logging.  
- Public disclosure of unpatched vulnerabilities.  

---

## 📬 Contact
For security concerns or vulnerability disclosures:

- **Email** → kevin.crosson@outlook.com  
- **LinkedIn** → [https://www.linkedin.com/in/kcrosson1977](https://www.linkedin.com/in/kcrosson1977)  
- **GitHub Issues** → Use the **“Security Disclosure”** label for private reporting  

---

## 🚀 Strategic Positioning
OpsForge is designed to be a **modular, compliant, and enterprise-ready ecosystem**.  
Security practices ensure contributors and enterprises can engage responsibly while respecting boundaries:
- **BuildMate = software-only.**  
- **DroneOps = all drone hardware/aerial intelligence.**