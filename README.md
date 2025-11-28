# OpsForge

OpsForge is the umbrella repository that unifies multiple technical modules into a single ecosystem.  
It provides governance, CI/CD workflows, and contributor onboarding standards across all subprojects.

## 📂 Repository Structure

- **NetworkAudit/**  
  Security and forensic monitoring suite. Includes packet capture, ARP/TCP logging, USB event tracking, and dashboard integration.

- **BuildMate/**  
  Backend automation and metadata tooling. Provides credential hygiene, dependency locking, and contributor onboarding scripts.

- **SmartSecurity/**  
  Access control and video monitoring policies. Includes device control documentation and employee consent workflows.

- **DroneOps/**  
  Counter‑UAS and aerial intelligence modules. Roadmaps and compliance documentation for drone operations.

- **Scripts/**  
  Centralized PowerShell and Python utilities for metadata generation, changelog validation, and CI/CD enforcement.

- **Docs/**  
  Governance, compliance, contributor checklists, and roadmap documentation for the entire OpsForge ecosystem.

- **PSModules/**  
  PowerShell modules for documentation automation and symbol hygiene testing.

---

## 🌐 Background

Originally developed as **NetworkAudit**, this project has expanded into a broader ecosystem.  
OpsForge now serves as the top‑level repository, with NetworkAudit as one of several modules.  
This restructuring ensures:
- Unified governance and contributor standards  
- Centralized `.gitignore` and linting rules  
- Clear separation of modules for scalability and commercial readiness  

---

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/KevinCrosson/OpsForge.git
   cd OpsForge

Perfect — let’s scaffold a merged README.md that resolves your conflict and clearly explains the new OpsForge umbrella repo while preserving context from NetworkAudit.

📄 Suggested Merged README.md
# OpsForge

OpsForge is the umbrella repository that unifies multiple technical modules into a single ecosystem.  
It provides governance, CI/CD workflows, and contributor onboarding standards across all subprojects.

## 📂 Repository Structure

- **NetworkAudit/**  
  Security and forensic monitoring suite. Includes packet capture, ARP/TCP logging, USB event tracking, and dashboard integration.

- **BuildMate/**  
  Backend automation and metadata tooling. Provides credential hygiene, dependency locking, and contributor onboarding scripts.

- **SmartSecurity/**  
  Access control and video monitoring policies. Includes device control documentation and employee consent workflows.

- **DroneOps/**  
  Counter‑UAS and aerial intelligence modules. Roadmaps and compliance documentation for drone operations.

- **Scripts/**  
  Centralized PowerShell and Python utilities for metadata generation, changelog validation, and CI/CD enforcement.

- **Docs/**  
  Governance, compliance, contributor checklists, and roadmap documentation for the entire OpsForge ecosystem.

- **PSModules/**  
  PowerShell modules for documentation automation and symbol hygiene testing.

---

## 🌐 Background

Originally developed as **NetworkAudit**, this project has expanded into a broader ecosystem.  
OpsForge now serves as the top‑level repository, with NetworkAudit as one of several modules.  
This restructuring ensures:
- Unified governance and contributor standards  
- Centralized `.gitignore` and linting rules  
- Clear separation of modules for scalability and commercial readiness  

---

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/KevinCrosson/OpsForge.git
   cd OpsForge


2. Install dependencies for each module as needed (see module‑specific READMEs).

3. Review onboarding documentation in Docs/CONTRIBUTOR-CHECKLIST.md.


## 📜 Governance

OpsForge enforces:

- Root .gitignore for all modules
- CI/CD workflows (.github/workflows/) for linting and status dashboards
- Contributor guidelines (CONTRIBUTING.md, CODE_OF_CONDUCT.md)
- Security disclosures (SECURITY.md, SECURITY-DISCLOSURE.md)


## 📈 Roadmap

- NetworkAudit → Commercial release with dashboards and licensing
- BuildMate → Metadata automation and audit‑friendly workflows
- SmartSecurity → Expanded access control and video monitoring features
- DroneOps → Counter‑UAS compliance and operational readiness


### 📬 Contact

- Email: kevin.crosson@outlook.com
- LinkedIn: https://www.linkedin.com/in/kcrosson1977
- GitHub Issues: Use labels Commercial Licensing or Security Disclosure for private issues
