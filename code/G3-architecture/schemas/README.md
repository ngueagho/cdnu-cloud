# Schémas d'architecture

Créer les schémas suivants avec [draw.io](https://draw.io) en utilisant les icônes AWS officielles.

## Schémas à produire

### 1. `01-vue-globale-10cdnu.drawio`
Vue d'ensemble des 10 VPCs interconnectés via Transit Gateway.  
Montrer : Internet → CloudFront → ALBs → Transit Gateway → 10 VPCs

### 2. `02-detail-cdnu.drawio`
Zoom sur un CDNU type (ex: cdnu-yaounde-1).  
Montrer : AZ-a et AZ-b, subnets public/privé/DB, EC2, RDS Multi-AZ, S3 VPC Endpoint

### 3. `03-ha-dr-failover.drawio`
Schéma du basculement automatique.  
Montrer : RDS Multi-AZ failover, ALB health check, ASG launch

### 4. `04-flux-applicatif.drawio`
Flux d'une requête HTTP end-to-end.  
Montrer : Utilisateur → DNS → CloudFront → ALB → EC2 → RDS + S3

## Instructions draw.io

1. Ouvrir https://draw.io
2. `Extras > Edit Diagram` pour coller du XML si besoin
3. Pour les icônes AWS : `Search Shapes > AWS`
4. Exporter en PNG (300 dpi) ET conserver le fichier .drawio source
5. Nommer les fichiers exportés : `01-vue-globale-10cdnu.png`, etc.
