from flask import Flask, render_template

import socket

from conexion import get_connection

app = Flask(__name__)

@app.route('/')
def dashboard():
    # Obtenemos la IP local de este servidor (AWS) para mostrarla
    server_ip = socket.gethostbyname(socket.gethostname())
    
    # Llamamos a la función de conexión
    data, error = get_connection()
    
    return render_template('index.html', data=data, error=error, server_ip=server_ip)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000) #alternativa puerto 5432