import 'package:shared_preferences/shared_preferences.dart';

import 'http.dart';
import 'persona.dart';
import 'package:intl/intl.dart';

class Parte {
  final int id;
  final int idpersona;
  final int idpdt;
  final int idpda;
  final String inicio;
  final String fin;
  final int idtlogin;
  final int idtlogout;
  final String observaciones;
  final String data;
  final String time;
  final String user;

  static Future<String> registrarLectura(
      Persona persona, int tipo, SharedPreferences preferences) async {
    Parte parte = await Parte.getParteActivo(persona);
    String resultado = '';

    try {
      if (parte.id == 0) {
        //Registramos la entrada
        resultado = await Parte.abrirParte(persona, tipo, preferences);
      } else {
        //Registramos la salida
        resultado = await Parte.cerrarParte(parte, persona, tipo, preferences);
      }
    } catch (e) {
      resultado = e;
    }

    return resultado;
  }

  static Future<Parte> getParteActivo(Persona persona) async {
    Parte parte;
    try {
      var result = await httpGet('parte_activo/' + persona.id);
      if (result.ok) {
        var data = result.data as List<dynamic>;
        if (data.isEmpty) {
          parte = Parte.parteVacio();
          print(
              '- No hay parte activo para el usuario ${persona.id} - ${persona.descripcion}. Registrado entrada...');
        } else {
          parte = new Parte.fromJson((result.data as List<dynamic>).first);
          print(
              '- Existe un parte activo para el usuario ${persona.id} - ${persona.descripcion}. Registrado salida...');
        }
      }
    } catch (e) {
      print(e);
    }
    return parte;
  }

  static Future<String> abrirParte(
      Persona persona, int tipo, SharedPreferences preferences) async {
    await httpPost("registrar", {
      "values": persona.id +
          ",0," +
          preferences.getInt('DeviceID').toString() +
          ",'" +
          DateFormat('yyyyMMdd kkmmss').format(DateTime.now()) +
          "','',$tipo,0,'','" +
          DateFormat('yyyy-MM-dd').format(DateTime.now()) +
          "','" +
          DateFormat('kk:mm:ss').format(DateTime.now()) +
          "','" +
          preferences.getString('DeviceName') +
          "'"
    });

    return 'Entrada registrada. Hola ${persona.descripcion}';
  }

  static Future<String> cerrarParte(Parte parte, Persona persona, int tipo,
      SharedPreferences preferences) async {
    await httpPost("cerrar_parte", {
      "values": "UPDATE presencia SET idtlogout = $tipo, fin = '" +
          DateFormat('yyyyMMdd kkmmss').format(DateTime.now()) +
          "', DATA = '" +
          DateFormat('yyyy-MM-dd').format(DateTime.now()) +
          "', TIME = '" +
          DateFormat('kk:mm:ss').format(DateTime.now()) +
          "',USER = '" +
          preferences.getString('DeviceName') +
          "' WHERE id = " +
          parte.id.toString() +
          ";"
    });

    return 'Salida registrada. Adios ${persona.descripcion}';
  }

  Parte(
      {this.id,
      this.idpersona,
      this.idpdt,
      this.idpda,
      this.inicio,
      this.fin,
      this.idtlogin,
      this.idtlogout,
      this.observaciones,
      this.data,
      this.time,
      this.user});

  static Parte parteVacio() {
    return new Parte(
        id: 0,
        idpersona: 0,
        idpdt: 0,
        idpda: 0,
        inicio: '',
        fin: '',
        idtlogin: 0,
        idtlogout: 0,
        observaciones: '',
        data: '',
        time: '',
        user: '');
  }

  factory Parte.fromJson(Map<String, dynamic> json) {
    return Parte(
      id: json['id'],
      idpersona: json['idpersona'],
      idpdt: json['idpdt'],
      idpda: json['idpda'],
      inicio: json['inicio'],
      fin: json['fin'],
      idtlogin: json['idtlogin'],
      idtlogout: json['idtlogout'],
      observaciones: json['observaciones'],
      data: json['data'],
      time: json['time'],
      user: json['user'],
    );
  }
}
