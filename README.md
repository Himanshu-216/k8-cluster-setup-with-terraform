
---

## ⚙️ What It Does  

- Provisions a **VPC, subnets, and networking**  
- Launches **EC2 instances** for Kubernetes master & worker nodes  
- Bootstraps cluster using `master.sh` and `worker.sh` scripts  
- Outputs useful info (IPs, DNS, etc.)  

---

## 🚀 Getting Started  

### 1️⃣ Prerequisites  
- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed  
- AWS CLI configured (`aws configure`)  
- SSH keypair for EC2  

### 2️⃣ Initialize Terraform  
```bash
cd dev
terraform init
