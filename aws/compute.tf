# Buscador de AMI: encuentra la última ID de Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# VM (Instancia EC2) para el Servidor Web
resource "aws_instance" "web_server" {
  # Usa la ID que encontró el buscador de AMI
  ami           = data.aws_ami.amazon_linux_2.id
  
  # t2.micro está en la capa gratuita
  instance_type = "t3.micro" 
  
  # Ponlo en nuestra subred pública
  subnet_id     = aws_subnet.hub_public.id
  
  # Asigna el firewall que acabamos de crear
  vpc_security_group_ids = [aws_security_group.sg_web.id] 
  
  # Asigna una llave SSH para conectarte
  key_name      = "proyecto-redes-key" 

  user_data = <<-EOF
              #!/bin/bash
              # 1. Instala Nginx (el -y es para 'yes' automático)
              amazon-linux-extras install nginx1 -y
              
              # 2. Habilita Nginx (para que inicie en cada reinicio)
              systemctl enable nginx
              
              # 3. Inicia Nginx ahora mismo
              systemctl start nginx
              
              # 4. Crea la página HTML personalizada usando 'cat'
              cat > /usr/share/nginx/html/index.html <<'HTML_EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Proyecto Redes - AWS Server</title>
  
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      background-color: #f7f7f7;
      color: #333;
      line-height: 1.6;
      margin: 0;
      padding: 20px;
    }
    .container {
      max-width: 800px;
      margin: 20px auto;
      padding: 30px;
      background-color: #ffffff;
      border: 1px solid #ddd;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    }
    h1 {
      color: #232f3e;
      text-align: center;
      border-bottom: 2px solid #f0f0f0;
      padding-bottom: 10px;
    }
    h2 {
      color: #333;
      border-bottom: 1px solid #eee;
      padding-bottom: 5px;
      margin-top: 30px;
    }
    code {
      color: #d14;
      background-color: #f9f2f4;
      padding: 3px 6px;
      border-radius: 4px;
      font-family: monospace;
    }
    ul {
      list-style-type: square;
      background-color: #fdfdfd;
      border-left: 3px solid #007BFF;
      padding: 15px;
      padding-left: 40px;
    }
    .status-box {
      border-width: 1px;
      border-style: solid;
      padding: 20px;
      margin-top: 20px;
      border-radius: 5px;
    }
    .status-box h3 { margin-top: 0; padding-bottom: 5px; }
    .public-test {
      border-color: #FF9900; /* Naranja AWS */
      background-color: #fffaf0;
    }
    .public-test h3 { color: #FF9900; border-bottom: 1px dashed #FF9900; }
    .private-test {
      border-color: #0078D4; /* Azul Azure */
      background-color: #f0f8ff;
    }
    .private-test h3 { color: #0078D4; border-bottom: 1px dashed #0078D4; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Servidor AWS: En Línea</h1>
    <h2>¿Qué es esta página?</h2>
    <p>Esta es una página de prueba para nuestro proyecto final de <strong>Redes de Computadoras</strong>.</p>
    <h2>¿Dónde está servida?</h2>
    <p>Esta página web está siendo servida por un servidor <code>Nginx</code> que corre en una instancia (VM) <code>t3.micro</code> de <strong>Amazon Web Services (AWS)</strong>.</p>
    <ul>
      <li><strong>Proveedor:</strong> AWS</li>
      <li><strong>Región:</strong> <code>us-east-1</code> (Norte de Virginia)</li>
      <li><strong>Red (VPC):</strong> <code>VPC-Hub (10.10.0.0/16)</code></li>
      <li><strong>Servicio:</strong> Amazon EC2</li>
    </ul>
    <h2>¿Qué significa que puedas ver esto?</h2>
    <p>Depende de CÓMO hayas llegado aquí:</p>
    <div class="status-box public-test">
      <h3>Prueba 1: Acceso Público (vía Internet)</h3>
      <p>Si estás viendo esta página usando la <strong>IP Pública</strong> (ej. <code>34.200.x.x</code>), significa que nuestra configuración de AWS es correcta.</p>
    </div>
    <div class="status-box private-test">
      <h3>Prueba 2: Acceso Privado (vía VPN)</h3>
      <p>Si tú (Team Azure) estás viendo esta página usando la <strong>IP PRIVADA</strong> (<code>10.10.x.x</code>), significa que la <strong>VPN Site-to-Site</strong> (AWS ↔ Azure) está activa y funcionando.</p>
    </div>
  </div>
</body>
</html>
HTML_EOF
              EOF


  tags = {
    Name = "WebServer-Hub"
  }
}

# ------------------------------------------------
# VM de Prueba (en Prod)
# ------------------------------------------------
resource "aws_instance" "test_vm_prod" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  # ¡Importante! Vive en la subred privada de Prod
  subnet_id     = aws_subnet.prod_private.id

  # Usa el nuevo firewall privado
  vpc_security_group_ids = [aws_security_group.sg_private.id]

  # Asigna la misma llave SSH (para poder "saltar" a ella)
  key_name      = "proyecto-redes-key"
  
  # ¡Crucial! Asegurarnos de que NO tenga IP pública
  associate_public_ip_address = false

  tags = {
    Name = "TestVM-Prod"
  }
}