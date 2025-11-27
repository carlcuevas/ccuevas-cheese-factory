# Buscar la AMI más reciente de Amazon Linux 2023
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Cuenta oficial de Amazon Linux

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "web" {
  count = 3

  ami           = data.aws_ami.al2023.id
  instance_type = local.instance_type
  subnet_id     = module.vpc.private_subnets[count.index]
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash
    dnf -y update
    dnf -y install nginx
    systemctl enable nginx
    systemctl start nginx

    # --- CONFIGURACIÓN DE IMÁGENES ---
    # Aquí definimos qué queso mostrar según el número de servidor (0, 1 o 2)
    if [ "${count.index}" -eq 0 ]; then
       # Servidor 1
       IMG_URL="https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Swiss_cheese_cubes.jpg/800px-Swiss_cheese_cubes.jpg"
       QUESO_NOMBRE="Queso Suizo (Server 1)"
    elif [ "${count.index}" -eq 1 ]; then
       # Servidor 2
       IMG_URL="https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Cheddar_cheese.jpg/800px-Cheddar_cheese.jpg"
       QUESO_NOMBRE="Queso Cheddar (Server 2)"
    else
       # Servidor 3
       IMG_URL="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Parmigiano_reggiano_piece.jpg/800px-Parmigiano_reggiano_piece.jpg"
       QUESO_NOMBRE="Queso Parmesano (Server 3)"
    fi

    # --- CREAR PÁGINA WEB ---
    cat > /usr/share/nginx/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>The Cheese Factory</title>
      <style>
        body { font-family: sans-serif; background: #fff7dc; text-align: center; padding-top: 50px; }
        .card { 
          display: inline-block; 
          padding: 20px; 
          background: white; 
          border-radius: 10px; 
          box-shadow: 0 4px 10px rgba(0,0,0,0.1); 
          max-width: 400px;
        }
        img { border-radius: 8px; margin-top: 15px; width: 100%; height: auto; }
        h1 { color: #e67e22; }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>🏭 The Cheese Factory 🏭</h1>
        <h3>Servido desde: ${local.name_prefix}-web-${count.index + 1}</h3>
        <h2>Hoy ofrecemos:</h2>
        <h1 style="color: #333;">$QUESO_NOMBRE</h1>
        
        <img src="$IMG_URL" alt="Queso del dia">
        
        <p><br><small>Desplegado automáticamente por Terraform</small></p>
      </div>
    </body>
    </html>
    HTML
  EOF

  tags = merge(
    local.common_tags,
    {
      Name = format("%s-web-%d", local.name_prefix, count.index + 1)
    }
  )
}
# Adjuntar cada instancia al Target Group del ALB
resource "aws_lb_target_group_attachment" "web_attachments" {
  count            = length(aws_instance.web)
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

