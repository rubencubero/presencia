import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presencia/classes/notificacion.dart';
import 'package:presencia/classes/parte.dart';
import '../classes/persona.dart';
import '../styles/styles.dart';
import 'pinCode.dart';

class ListadoPersonas extends StatelessWidget {
  final List<Persona> _personas;

  ListadoPersonas(this._personas);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Presencia', style: Styles.defaultText)),
        body: GridView.count(
            crossAxisCount: 5, children: _buildGridCards(context)));
  }

  List<Widget> _buildGridCards(BuildContext context) {
    return List.generate(_personas.length, (index) {
      var persona = this._personas[index];
      return InkResponse(
          onTap: () => _navegarPinCode(context, persona),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 5 / 2,
                    child: Image.asset('assets/images/user_solid.png'),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${persona.descripcion}',
                          style: Styles.cardText,
                        ),
                        SizedBox(height: 1.0),
                      ],
                    ),
                  ),
                ]),
          ));
    });
  }

  void _navegarPinCode(BuildContext context, Persona persona) async {
    final resultado = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => PinCode(persona.password)));
    if (resultado) {
      var resultado = await Parte.registrarLectura(persona, 313);
      print(resultado.toString());
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            Future.delayed(Duration(seconds: 2), () {
              Navigator.of(context).pop(true);
            });
            return Notificacion(
                tipo: 3, titulo: 'Registrado', mensaje: resultado);
          });

      cerrarListadoPersonas(context);
    }
  }

  cerrarListadoPersonas(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }
}
