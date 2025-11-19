import os
import psycopg2
from psycopg2 import OperationalError

def get_connection():
    try:
        db_host = os.environ.get('DB_HOST', '127.0.0.1')
        db_name = os.environ.get('DB_NAME', 'nomina_db')
        db_user = os.environ.get('DB_USER', 'postgres')
        db_password = os.environ.get('DB_PASS', '1234')

        conn = psycopg2.connect(
        #connect_timeout=5,
        user=db_user,
        password=db_password,
        host=db_host,
        database=db_name
        )

        cursor = conn.cursor()
        cursor.execute('SELECT * FROM empleados;') #consulta
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        return rows, None # Retornar (datos, error)
    
    except OperationalError as error:
        return(error)