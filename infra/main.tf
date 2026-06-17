provider "aws" {
  region = "us-east-1" # Defino el proveedor de cloud (AWS) junto con la región donde se desplegarán los servicios (Norte de Virginia)
}

# Servicio S3
resource "aws_s3_bucket" "bucket_textos" {
  bucket        = "texto-a-audio-izan-2026" # Nombre del bucket s3
  force_destroy = true                      # Permite que el bucket sea eliminado incluso si contiene objetos (útil para desarrollo, pero peligroso en producción)
}

# Servicio de Rol con IAM
resource "aws_iam_role" "lambda_ejecucion" { # Rol que tiene permisos para ejecutar la función lambda
  name = "rol_ejecucion_lambda_text"         # Nombre del rol
  assume_role_policy = jsonencode({          # Política de confianza
    Version = "2012-10-17"                   # Version de la política de confianza
    Statement = [{                           #Declaracion
      Action = "sts:AssumeRole"              # Accion que se permite
      Effect = "Allow"                       # Efecto que se permite
      Principal = {
        Service = "lambda.amazonaws.com" # Servicio que tiene permisos para ejecutar la función lambda
      }
    }]
  })
}

# Compresión de la lambda en un archivo zip

data "archive_file" "codigo_lambda_zip" {
  type        = "zip"                                   # Tipo de archivo que se va a crear
  source_dir  = "${path.module}/../src"                 # ruta donde se encuentra la lambda de python
  output_path = "${path.module}/../lambda_function.zip" # ruta donde se guardara el archivo zip
}

# Servicio Lambda
resource "aws_lambda_function" "lambda_texto" {                              # Definición de la función lambda
  filename         = data.archive_file.codigo_lambda_zip.output_path         # Archivo zip de la lambda
  function_name    = "convertidor_texto_a_voz"                               # Nombre de la función lambda
  role             = aws_iam_role.lambda_ejecucion.arn                       # ARN del rol de IAM
  handler          = "lambda_function.lambda_handler"                        # nombre del archivo python . nombre de la funcion
  runtime          = "python3.12"                                            # version de python
  source_code_hash = data.archive_file.codigo_lambda_zip.output_base64sha256 # hash del archivo zip para detectar cambios

  #Variables de entorno (No hay que poner los valores fijos en el código de terraform si queremos tener seguridad, usamos variables de entorno)
  environment {
    variables = {
      BUCKET_NOMBRE = aws_s3_bucket.bucket_textos.bucket # Nombre del bucket s3
    }
  }
}
