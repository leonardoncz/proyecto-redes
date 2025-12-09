# Configurar el proveedor de AWS
provider "aws" {
  region = "us-east-1" #norte de virginia
}

# Definir la versión del proveedor a usar
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Usa una versión reciente
    }
  }
  
  backend "s3" {
    bucket         = "proyectoredes-tfstate-4892"
    key            = "aws-infra/terraform.tfstate"      #La ruta dentro del bucket
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"                  #Tabla creada
    encrypt        = true
  }
}