# Configurar el proveedor de AWS
provider "aws" {
  region = "us-east-1"
}

# Definir la versión del proveedor a usar
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Usa una versión reciente
    }
  }
}