provider "aws" {
  region = "us-east-1" # Defino el proveedor de cloud (AWS) junto con la región donde se desplegarán los servicios (Norte de Virginia)
}

# Servicio S3
resource "aws_s3_bucket" "bucket_textos" {
  bucket        = "texto-a-audio-izan-2026"
  force_destroy = true # Permite que el bucket sea eliminado incluso si contiene objetos (útil para desarrollo, pero peligroso en producción)
}

# Servicio de Rol con IAM
resource "aws_iam_role" "lambda_ejecucion" { # Rol que tiene permisos para ejecutar la función lambda
  name = "rol_ejecucion_lambda_text"         # Nombre del rol
  assume_role_policy = jsondecode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}
