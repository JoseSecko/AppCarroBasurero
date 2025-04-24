import functions_framework
from flask import request, jsonify
import requests
from PIL import Image
from PIL.ExifTags import TAGS, GPSTAGS
import io

def obtener_metadatos(image_bytes):
    image = Image.open(io.BytesIO(image_bytes))
    exif_info = image._getexif()
    datos = {}

    if not exif_info:
        return {}

    for tag_id, value in exif_info.items():
        tag = TAGS.get(tag_id, tag_id)

        if tag == 'GPSInfo':
            gps_info = {}
            for t in value:
                sub_tag = GPSTAGS.get(t, t)
                gps_info[sub_tag] = value[t]
            datos['GPSInfo'] = gps_info
        elif tag in ['Make', 'Model', 'DateTime']:
            datos[tag] = str(value)

    return datos

def convertir_a_decimal(coord, ref):
    if not coord or len(coord) != 3:
        return None

    grados = float(coord[0])
    minutos = float(coord[1])
    segundos = float(coord[2])

    decimal = grados + (minutos / 60.0) + (segundos / 3600.0)
    if ref in ['S', 'W']:
        decimal = -decimal
    return decimal

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
            return jsonify({'error': 'No se pudo descargar la imagen'}), 400

        datos_exif = obtener_metadatos(response.content)

        gps_info = datos_exif.get('GPSInfo', {})
        lat = gps_info.get('GPSLatitude')
        lat_ref = gps_info.get('GPSLatitudeRef')
        lon = gps_info.get('GPSLongitude')
        lon_ref = gps_info.get('GPSLongitudeRef')

        lat_decimal = convertir_a_decimal(lat, lat_ref) if lat and lat_ref else None
        lon_decimal = convertir_a_decimal(lon, lon_ref) if lon and lon_ref else None

        return jsonify({
            'esValida': True if datos_exif else False,
            'datos': {
                'Make': datos_exif.get('Make', ''),
                'Model': datos_exif.get('Model', ''),
                'DateTime': datos_exif.get('DateTime', ''),
                'Latitude': lat_decimal,
                'Longitude': lon_decimal
            }
        })

    except Exception as e:
        print("🔥 Error:", str(e))
        return jsonify({'error': str(e)}), 500

