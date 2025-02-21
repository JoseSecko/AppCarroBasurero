import 'package:flutter/material.dart';


class ForoComunidadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foro de la Comunidad - Gestión de Residuos',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ForoComunidadScreen(),
    );
  }
}

class ForoComunidadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foro de la Comunidad'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderSection(),
            ForumPost(
              avatar: 'assets/foto1.jpg',
              username: 'Usuario123',
              time: 'Publicado hace 2 horas',
              content: '¿Alguien más ha tenido problemas con la recolección en la zona norte? Últimamente los horarios no se cumplen.',
            ),
            ForumReply(
              avatar: 'assets/foto2.jpg',
              username: 'Vecino456',
              time: 'Publicado hace 1 hora',
              content: '¡Sí, justo ayer pasó! Sería bueno tener notificaciones en tiempo real para saber si el camión está cerca.',
            ),
            CommentForm(),
          ],
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foro de la Comunidad',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Conversa con otros usuarios sobre la gestión de residuos en tu comunidad.',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

class ForumPost extends StatelessWidget {
  final String avatar;
  final String username;
  final String time;
  final String content;

  ForumPost({required this.avatar, required this.username, required this.time, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(avatar: avatar, username: username, time: time),
          SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text("Responder", style: TextStyle(color: Colors.green)),
            ),
          ),
        ],
      ),
    );
  }
}

class ForumReply extends StatelessWidget {
  final String avatar;
  final String username;
  final String time;
  final String content;

  ForumReply({required this.avatar, required this.username, required this.time, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(left: 16.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(avatar: avatar, username: username, time: time),
          SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class PostHeader extends StatelessWidget {
  final String avatar;
  final String username;
  final String time;

  PostHeader({required this.avatar, required this.username, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage(avatar),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(username, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}

class CommentForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Escribe tu respuesta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Comparte tu experiencia o pregunta...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Publicar"),
            ),
          ),
        ],
      ),
    );
  }
}
