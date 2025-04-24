import functions_framework
from flask import jsonify, request
import requests
from PIL import Image
from PIL.ExifTags import TAGS
import io

def obtener_datos_basicos(image_bytes):
    image = Image.open(io.BytesIO(image_bytes))
    exif_info = image._getexif()
    datos = {}

    if not exif_info:
        return {}

    for tag_id, value in exif_info.items():
        tag = TAGS.get(tag_id, tag_id)
        if tag in ['Make', 'Model', 'DateTime']:
            datos[tag] = str(value)

    return datos

@functions_framework.http
def verificar_imagen(request):
    print("📥 Imagen URL recibida")
    try:
        data = request.get_json()
        image_url = data.get('imageUrl')

        if not image_url:
            return jsonify({'error': 'Falta URL de la imagen'}), 400
        print("🔄 Descargando imagen...")
        response = requests.get(image_url)
        print(f"🖼️ Código de respuesta: {response.status_code}")
        if response.status_code != 200:
            print("❌ Error al descargar imagen:", response.content)
        datos_exif = obtener_datos_basicos(response.content)

        if datos_exif:
            return jsonify({
                'esValida': True,
                'mensaje': 'Metadatos encontrados.',
                'datos': datos_exif
            })
        else:
            return jsonify({
                'esValida': False,
                'mensaje': 'No se encontraron metadatos relevantes.',
                'datos': {}
            })

    except Exception as e:
        print("🔥 Error:", str(e))
        return jsonify({'error': str(e)}), 500
