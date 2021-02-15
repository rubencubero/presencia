import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:presencia/mocks/mock_personas.dart';
import 'package:presencia/screens/pinCode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'listadoPersonas.dart';
import 'configuracion.dart';
import '../classes/persona.dart';
import '../classes/tarjeta.dart';
import '../classes/parte.dart';
import '../classes/notificacion.dart';
import '../styles/styles.dart';

class LecturaTarjeta extends StatelessWidget {
  final List<Persona> _personas;
  final SharedPreferences prefs;
  final Tarjeta _tarjeta = Tarjeta(codigoMagnetico: '', lecturaActiva: false);

  LecturaTarjeta(this._personas, this.prefs);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              'Presencia',
              style: Styles.defaultText,
            ),
            actions: _renderizarOpcionesAppBar(context)),
        body: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (RawKeyEvent event) async {
              String resultado =
                  await _capturarTeclaPulsada(event, context, _tarjeta);
              if (resultado.length != 0) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Notificacion(
                          tipo: Notificacion.warning,
                          titulo: 'Alerta',
                          mensaje: resultado);
                    });
              }
            },
            autofocus: true,
            child: _renderizarMensajeTarjeta(
                'Pase la tarjeta para identificarse')));
  }

  List<Widget> _renderizarOpcionesAppBar(BuildContext context) {
    return <Widget>[
      Padding(
          padding: EdgeInsets.only(right: 20),
          child: Container(
              child: Row(children: <Widget>[
            _navBarIconoListadoPersonas(context),
            _navBarIconoConfiguracion(context, prefs)
          ])))
    ];
  }

  Widget _navBarIconoListadoPersonas(BuildContext context) {
    return GestureDetector(
        onTap: () => _navegarListadoPersonas(context),
        child: Icon(Icons.perm_identity_rounded, size: 46.0));
  }

  Widget _navBarIconoConfiguracion(
      BuildContext context, SharedPreferences prefs) {
    return GestureDetector(
        onTap: () => _navegarConfiguracion(context, prefs, '5738'),
        child: Icon(Icons.settings, size: 46.0));
  }

  Widget _renderizarMensajeTarjeta(String texto) {
    return Container(
        alignment: Alignment(0, 0),
        child: Text(texto, style: Styles.mensajeBandaMagneticaText));
  }

  void _navegarListadoPersonas(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ListadoPersonas(_personas, prefs)));
  }

  void _navegarConfiguracion(
      BuildContext context, SharedPreferences prefs, String pin) async {
    final resultado = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => PinCode(pin)));
    if (resultado) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => Configuracion(prefs, true)));
    }
  }

  Future<String> _capturarTeclaPulsada(
      RawKeyEvent event, BuildContext context, Tarjeta tarjeta) async {
    String mensaje = '';
    //Captura solo el keydown para evitar duplicaciones
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      print('- Estado lectura: ${tarjeta.getLecturaActiva()}');

      //** NOTA IMPORTANTE, el teclado configurado en el dispositivo tiene que ser QWERTY UK para que el caracter inicial sea
      //; y el final  ? pero el sistema lo detectará como un / con un SHIFT delante*/
      print('- Tecla pulsada: ' + event.logicalKey.keyLabel.toString());

      //Activamos la lectura
      if (event.isKeyPressed(LogicalKeyboardKey.semicolon)) {
        print('- [#CB activado]');
        tarjeta.setLecturaActiva(true);
      }

      //Capturamos la tecla si la lectura esta activada
      if (tarjeta.getLecturaActiva() == true) {
        tarjeta.setCodigoMagnetico(
            tarjeta.getcodigoMagnetico() + event.logicalKey.keyLabel);
        print('- Código actual: ${tarjeta.getcodigoMagnetico()}');
      }

      //Capturamos el final del código mágnetico
      if (event.isKeyPressed(LogicalKeyboardKey.shiftLeft) &&
          event.isKeyPressed(LogicalKeyboardKey.slash) &&
          tarjeta.getLecturaActiva() == true) {
        //Analizamos el CB y buscamos al usuario en el listado por el id de tarjeta pos:10 len:4
        if (tarjeta.getcodigoMagnetico().length > 14) {
          String idTarjeta =
              tarjeta.getcodigoMagnetico().toString().substring(10, 14);
          //if (tarjeta.getcodigoMagnetico().length > 5) {
          //String idTarjeta = tarjeta.getcodigoMagnetico().substring(1, 5);
          if (idTarjeta.length > 0) {
            Persona personaLeida = validarUsuarioTarjeta(idTarjeta, _personas);
            if (personaLeida != null) {
              /*Parte parte = await Parte.getParteActivo(personaLeida);
              mensaje = await registrarLectura(parte, personaLeida);*/
              var resultado =
                  await Parte.registrarLectura(personaLeida, 282, prefs);
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.of(context).pop(true);
                    });
                    return Notificacion(
                        tipo: resultado.toLowerCase().contains('salida')
                            ? Notificacion.logout
                            : Notificacion.login,
                        titulo: 'Registrado',
                        mensaje: resultado);
                  });
            } else {
              /*mensaje =
                  'ERROR. Persona con tarjeta $idTarjeta no encontrada. Avisar a informática.';*/
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    Future.delayed(Duration(seconds: 3), () {
                      Navigator.of(context).pop(true);
                    });
                    return Notificacion(
                        tipo: Notificacion.error,
                        titulo: 'Error',
                        mensaje:
                            'Persona con tarjeta $idTarjeta no encontrada. Avisar a informática.');
                  });
            }
          }
        }

        print(
            '- Código magnetico capturado: ${tarjeta.getcodigoMagnetico.toString()}');
        tarjeta.setLecturaActiva(false);
        tarjeta.setCodigoMagnetico('');
        print('- Resultado lectura: $mensaje');
      }
    }
    return mensaje;
  }
}

Persona validarUsuarioTarjeta(String idTarjeta, List<Persona> personas) {
  return MockPersonas.encontrarPersonaIdTarjeta(personas, idTarjeta);
}
