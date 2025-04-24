# Usa la imagen oficial de Python
FROM python:3.11-slim

# Establece el directorio de trabajo
WORKDIR /app

# Copia el archivo de dependencias
COPY requirements.txt .

# Instala las dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Copia el resto del código
COPY . .

# Expón el puerto donde correrá el servidor Flask
EXPOSE 8080

# Comando para correr la función
CMD ["functions-framework", "--target=verificar_imagen", "--port=8080"]
