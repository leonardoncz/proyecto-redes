from flask import Flask, render_template, request, redirect, url_for
from conexion import get_db_data, insert_employee
import locale

app = Flask(__name__)

def calcular_nomina(salario_bruto):
    afp = salario_bruto * 0.10       
    impuesto = salario_bruto * 0.08 
    neto = salario_bruto - afp - impuesto
    return {
        'bruto': salario_bruto,
        'afp': afp,
        'impuesto': impuesto,
        'neto': neto
    }

@app.route('/')
def dashboard():
    # 1. Traer datos de Azure
    raw_data, error = get_db_data()
    empleados_procesados = []
    total_gasto = 0
    
    if raw_data:
        for emp in raw_data:
            salario = float(emp[4]) if len(emp) > 4 else 0 
            calculos = calcular_nomina(salario)
            total_gasto += salario
            
            empleados_procesados.append({
                'id': emp[0],
                'nombre': emp[1],
                'puesto': emp[2],
                'depto': emp[5] if len(emp) > 5 else 'General',
                'calculos': calculos
            })

    return render_template('dashboard.html',empleados=empleados_procesados,total_gasto=total_gasto,total_emp=len(empleados_procesados),error=error)

@app.route('/construccion')
def construccion():
    return render_template('construccion.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
