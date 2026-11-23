---
name: karrito-media-guard
description: Reglas técnicas obligatorias de compresión multimedia, límites de tamaño y ahorro de tokens de IA antes de invocar la Edge Function `procesar-lista` en Karrito. Usar siempre que se grabe audio, se capture/seleccione una imagen o se procese cualquier entrada con IA.
---

# Regla obligatoria de compresión multimedia y ahorro de IA en Karrito

Esta skill establece los controles estrictos que la aplicación Flutter (`karrito_app/`) debe aplicar **en el cliente antes de enviar cualquier solicitud** a la Edge Function `procesar-lista` en Supabase.

## 1. Dictado por voz (Audio M4A/AAC)
- Grabar exclusivamente en formato **M4A / AAC-LC** (`AudioEncoder.aacLc`) con bitrate de **48 kbps** (`bitRate: 48000`, `sampleRate: 16000` o `22050`, 1 canal mono) mediante el paquete `record`.
- **Rechazo obligatorio en cliente antes de subir**:
  - Duración máxima permitida: **60 segundos** (`maxAudioDurationSeconds = 60`). Al alcanzar los 60 segundos se detiene automáticamente o se rechaza con aviso claro en español argentino.
  - Peso máximo permitido: **500 KB** (`maxAudioBytes = 500 * 1024`). Si el archivo resultante supera 500 KB, se rechaza localmente y se borra el archivo temporal sin enviarlo a Supabase.
- Enviar únicamente `audio_base64` y `audio_mime_type: 'audio/m4a'` a `procesar-lista`, y **eliminar el archivo temporal** del dispositivo apenas termina el envío o si el usuario cancela.

## 2. Escaneo de fotos y capturas de pantalla (JPEG)
- Toda fotografía tomada con cámara o captura de pantalla elegida desde galería (`image_picker`) debe comprimirse obligatoriamente con `flutter_image_compress` antes de convertirla a base64:
  - Lado mayor máximo: **`1024 px`** (`minWidth: 1024`, `minHeight: 1024`, preservando relación de aspecto sin agrandar imágenes más chicas).
  - Formato obligatorio: **JPEG** (`CompressFormat.jpeg`).
  - Calidad obligatoria: **`75%`** (`quality: 75`).
- Enviar únicamente `image_base64` y `image_mime_type: 'image/jpeg'` a `procesar-lista` y descartar los bytes/temporales al finalizar (las listas en papel o capturas nunca se almacenan de forma permanente).

## 3. Ahorro obligatorio de tokens de Gemini
- Para toda carga de texto (manual o importador de recetas/proyectos), **siempre consultar primero `local_learned_items`** en Drift antes de invocar `procesar-lista`.
- Solo los productos desconocidos o bloques complejos/conversacionales que no existen en el aprendizaje local pueden disparar una llamada remota a Gemini (`procesar-lista`).
- Respetar la puerta de plan en cliente y servidor: audio e imágenes son exclusivos del plan **`pro_3usd`**; en planes `free` y `basic_2usd` abrir `PlansScreen` sin invocar `procesar-lista`.
