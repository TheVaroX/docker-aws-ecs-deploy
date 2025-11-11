# docker-aws-ecs-deploy

Imagen Docker todo-en-uno para pipelines de CI/CD que necesitan construir, publicar imágenes en AWS ECR y desplegar en AWS ECS.

## 📋 Descripción

Imagen Docker minimalista basada en Alpine Linux que integra todas las herramientas necesarias para:

- Construir imágenes Docker
- Autenticarse y publicar en AWS ECR
- Desplegar automáticamente en AWS ECS
- Ejecutar scripts de infraestructura

Compatible con cualquier plataforma de CI/CD: GitLab CI, GitHub Actions, Jenkins, CircleCI, etc.

## 🛠️ Herramientas Incluidas

| Herramienta | Versión |
|-------------|---------|
| Alpine Linux | latest |
| Docker CLI | 28.3.3 |
| AWS CLI | 1.42.70 |
| ecs-deploy | latest |
| Bash | 5.2.37 |
| curl, jq, git | latest |

## 🎯 Propósito

Esta imagen resuelve la necesidad de un entorno CI/CD ligero y eficiente que incluya:
- Docker CLI para construir imágenes
- AWS CLI para autenticación en ECR
- Script ecs-deploy para actualizaciones de servicios ECS
- Shell robusto y compatible con Alpine

## 🚀 Uso Básico

### GitLab CI

```yaml
image: thevarox/docker-aws-ecs-deploy:v1.1

services:
  - name: docker:25-dind
    command: ["--tls=false"]

variables:
  DOCKER_HOST: "tcp://docker:2375"
  DOCKER_TLS_CERTDIR: ""

build:
  stage: build
  script:
    - aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ECR_REGISTRY
    - docker build -t $IMAGE_TAG .
    - docker push $IMAGE_TAG

deploy:
  stage: deploy
  script:
    - ecs-deploy --cluster "$ECS_CLUSTER" --service-name "$ECS_SERVICE" --image "$IMAGE_TAG" --timeout 1800
```

### GitHub Actions

```yaml
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    container: thevarox/docker-aws-ecs-deploy:v1.1
    steps:
      - uses: actions/checkout@v3
      
      - name: Login to AWS ECR
        run: aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${{ secrets.AWS_ECR_REGISTRY }}
      
      - name: Build and push image
        run: |
          docker build -t ${{ secrets.AWS_ECR_REGISTRY }}/my-app:latest .
          docker push ${{ secrets.AWS_ECR_REGISTRY }}/my-app:latest
      
      - name: Deploy to ECS
        run: ecs-deploy --cluster "${{ secrets.ECS_CLUSTER }}" --service-name "${{ secrets.ECS_SERVICE }}" --image "${{ secrets.AWS_ECR_REGISTRY }}/my-app:latest" --timeout 1800
```

### Jenkins

```groovy
pipeline {
    agent {
        docker {
            image 'thevarox/docker-aws-ecs-deploy:v1.1'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    stages {
        stage('Build') {
            steps {
                sh '''
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${AWS_ECR_REGISTRY}
                    docker build -t ${AWS_ECR_REGISTRY}/my-app:${BUILD_NUMBER} .
                    docker push ${AWS_ECR_REGISTRY}/my-app:${BUILD_NUMBER}
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                sh '''
                    ecs-deploy --cluster "${ECS_CLUSTER}" --service-name "${ECS_SERVICE}" --image "${AWS_ECR_REGISTRY}/my-app:${BUILD_NUMBER}" --timeout 1800
                '''
            }
        }
    }
}
```

## 📝 Comandos Comunes

### Autenticar en AWS ECR
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ECR_REGISTRY
```

### Construir imagen Docker
```bash
docker build -t $IMAGE_TAG --build-arg ENV=production .
docker push $IMAGE_TAG
```

### Desplegar en ECS
```bash
ecs-deploy --cluster "my-cluster" --service-name "my-service" --image "my-image:latest" --timeout 1800
```

## ⚠️ Notas Importantes

**Importante**: Los comandos deben estar en una sola línea sin saltos de línea con `\`:

```bash
# ✅ CORRECTO
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ECR_REGISTRY

# ❌ INCORRECTO
aws ecr get-login-password --region us-east-1 \
    | docker login --username AWS --password-stdin $AWS_ECR_REGISTRY
```

## 🐛 Troubleshooting

| Error | Causa | Solución |
|-------|-------|----------|
| "Cannot perform an interactive login from a non TTY device" | Comando docker login con saltos de línea | Mantener comando en una sola línea |
| "docker: 'docker buildx build' requires 1 argument" | Problema de parsing en comandos con saltos | Usar una sola línea para todo el comando |

## 📦 Construcción

```bash
# Multi-plataforma (amd64, arm64)
docker buildx build --platform linux/amd64,linux/arm64 -t {{tu_usuario}}/docker-aws-ecs-deploy:{{tag}} --push .

# Local
docker build -t docker-aws-ecs-deploy:{{tag}} .
```

## 🔗 Referencias

- [AWS ECR](https://docs.aws.amazon.com/ecr/)
- [AWS ECS](https://docs.aws.amazon.com/ecs/)
- [ecs-deploy](https://github.com/silinternational/ecs-deploy)
- [Alpine Linux](https://alpinelinux.org/)
- [Docker](https://www.docker.com/)

## 📄 Licencia

Ver archivo `LICENSE`.