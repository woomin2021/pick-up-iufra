# CLAUDE.md - Pickup Platform Infrastructure

## 프로젝트 개요
픽업 예약 플랫폼의 AWS 인프라를 Terraform으로 구성하는 프로젝트

## 팀 구성
- 인프라 팀 2명 (콘솔 + Terraform 병행)
- 백엔드 팀은 별도 (Pod 배포는 나중에)

---

## 아키텍처 요약

### AWS 리전
- ap-northeast-2 (서울)

### VPC 구성 (10.0.0.0/16)
| Subnet | CIDR | 용도 |
|--------|------|------|
| Public AZ-a | 10.0.1.0/24 | ALB, NAT GW |
| Public AZ-c | 10.0.2.0/24 | ALB (대기), NAT GW |
| EKS AZ-a | 10.0.3.0/24 | Worker Node |
| EKS AZ-c | 10.0.4.0/24 | Worker Node |
| 실시간 AZ-a | 10.0.5.0/24 | SQS, Redis |
| 실시간 AZ-c | 10.0.6.0/24 | SQS, Redis Replica |
| 데이터 AZ-a | 10.0.7.0/24 | RDS Primary |
| 데이터 AZ-c | 10.0.8.0/24 | RDS Replica |

### 주요 리소스
- **EKS**: Cluster + Node Group (t3.large x2 per AZ)
- **RDS**: PostgreSQL 15, Multi-AZ, t3.small
- **ElastiCache**: Redis 7.x, cache.t3.micro
- **S3**: 이미지, 로그, 백업 버킷
- **SQS**: 예약 큐 + DLQ
- **ALB**: HTTPS (443), WAF 연결

---

## Terraform 폴더 구조

```
pickup-infra/
├── environments/
│   ├── dev/
│   │   ├── main.tf          # 모듈 호출
│   │   ├── variables.tf     # 변수 정의
│   │   ├── terraform.tfvars # 개발 환경 값
│   │   └── backend.tf       # S3 백엔드
│   └── prod/
│       └── (동일 구조)
│
├── modules/
│   ├── vpc/          # VPC, Subnet, IGW, NAT, Route Table, SG
│   ├── eks/          # EKS Cluster, Node Group, IRSA
│   ├── rds/          # PostgreSQL, Subnet Group, RDS Proxy
│   ├── elasticache/  # Redis Cluster
│   ├── s3/           # S3 Buckets, Lifecycle
│   ├── sqs/          # SQS Queue, DLQ, SNS
│   └── alb/          # ALB, Target Group, WAF
│
├── iam/              # IAM Roles/Policies (별도 관리)
├── versions.tf       # Terraform/Provider 버전
└── README.md
```

---

## 모듈별 상세

### modules/vpc
- VPC (10.0.0.0/16)
- Subnet 8개 (Public 2, EKS 2, 실시간 2, 데이터 2)
- Internet Gateway
- NAT Gateway x2 (각 AZ)
- Route Table (Public, Private)
- Security Groups (EKS, RDS, Redis, ALB)

### modules/eks
- EKS Cluster (버전 1.29)
- Managed Node Group
    - 인스턴스: t3.large
    - 노드 수: min 2, desired 2, max 4 (per AZ)
- OIDC Provider (IRSA용)
- ECR Repository

### modules/rds
- RDS PostgreSQL 15
- 인스턴스: db.t3.small (dev) / db.t3.medium (prod)
- Multi-AZ: 활성화
- 자동 백업: 7일
- RDS Proxy (커넥션 풀링)
- Subnet Group
- Parameter Group

### modules/elasticache
- Redis 7.x
- 노드: cache.t3.micro (dev) / cache.t3.small (prod)
- Multi-AZ: Replica 1개
- Subnet Group
- Parameter Group

### modules/s3
- pickup-{env}-images (상품 이미지)
- pickup-{env}-logs (애플리케이션 로그)
- pickup-{env}-backup (DB 스냅샷)
- Lifecycle: 90일 후 Glacier

### modules/sqs
- pickup-{env}-reservation-queue (예약 큐)
- pickup-{env}-reservation-dlq (Dead Letter Queue)
- SNS Topic (Slack 알림용)

### modules/alb
- Application Load Balancer
- HTTPS Listener (443)
- HTTP → HTTPS 리다이렉트
- Target Group (EKS 연결용)
- WAF Web ACL

---

## 작업 담당

| 담당 | 모듈 |
|------|------|
| 나 | vpc, eks, alb |
| 팀원 | rds, elasticache, s3, sqs |

---

## Naming Convention

```
{project}-{env}-{resource}

예시:
- pickup-dev-vpc
- pickup-dev-eks-cluster
- pickup-dev-rds-postgres
- pickup-dev-redis
- pickup-dev-alb
```

---

## 작업 순서 (의존성)

1. **vpc/** - 모든 리소스의 기반
2. **rds/, elasticache/** - VPC 완료 후 병렬 가능
3. **eks/** - VPC 완료 후
4. **s3/, sqs/** - 독립적, 언제든 가능
5. **alb/** - VPC, EKS 완료 후

---

## 주의사항

1. **tfstate는 S3에 저장** - 로컬 저장 금지 (협업 충돌)
2. **Secrets는 terraform.tfvars에 넣지 말것** - Secrets Manager 사용
3. **태그 필수** - Project, Environment, ManagedBy
4. **모듈 outputs 활용** - vpc_id, subnet_ids 등 다른 모듈에서 참조

---

## 자주 쓰는 명령어

```bash
# 초기화
cd environments/dev
terraform init

# 계획 확인
terraform plan

# 적용
terraform apply

# 특정 모듈만 적용
terraform apply -target=module.vpc

# 상태 확인
terraform state list
```

---

## EKS Pod 배포 (백엔드 팀 - 나중에)

인프라 팀은 여기까지만! 아래는 백엔드 팀이 나중에 작업:
- Deployment YAML
- Service, Ingress
- HPA 설정
- ArgoCD Application

---

## 참고 링크

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
