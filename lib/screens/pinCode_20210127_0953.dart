import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../classes/persona.dart';
import '../classes/notificacion.dart';
import '../styles/styles.dart';

class PinCode extends StatefulWidget {
  final Persona _persona;
  final bool ok = false;
  PinCode(this._persona);

  @override
  _PinCodeState createState() => _PinCodeState(_persona);
}

class _PinCodeState extends State<PinCode> {
  final Persona _persona;
  _PinCodeState(this._persona);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.lightGreen[100],
        Colors.lightGreen[300],
      ], begin: Alignment.topRight)),
      child: PinCodeScreen(_persona),
    ));
  }
}

class PinCodeScreen extends StatefulWidget {
  final Persona persona;
  final bool ok = false;

  PinCodeScreen(this.persona);

  @override
  _PinCodeScreenState createState() => _PinCodeScreenState(persona);
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final Persona persona;
  _PinCodeScreenState(this.persona);

  List<String> pinActual = ['', '', '', ''];
  TextEditingController controlPinUno = TextEditingController();
  TextEditingController controlPinDos = TextEditingController();
  TextEditingController controlPinTres = TextEditingController();
  TextEditingController controlPinCuatro = TextEditingController();
  int pinIndex = 0;

  var bordeExteriorEntrada = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(color: Colors.transparent),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          construirBotonSalir(),
          Container(
            alignment: Alignment(0, 0.5),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                construirTextoPin(),
                SizedBox(height: 40.0),
                construirFilaPIN(),
              ],
            ),
          ),
          construirPanelNumerico()
        ],
      ),
    );
  }

  construirBotonSalir() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              onPressed: () {
                cerrarPinCode(false);
              },
              height: 50.0,
              minWidth: 50.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Icon(
                Icons.clear,
                color: Colors.black,
              ),
            ))
      ],
    );
  }

  cerrarPinCode(bool ok) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, ok);
    } else {
      SystemNavigator.pop();
    }
  }

  construirTextoPin() {
    return Text(
      "PIN Seguridad",
      style: Styles.defaultText,
    );
  }

  construirFilaPIN() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        NumeroPIN(
          outlineInputBorder: bordeExteriorEntrada,
          textEditingController: controlPinUno,
        ),
        NumeroPIN(
          outlineInputBorder: bordeExteriorEntrada,
          textEditingController: controlPinDos,
        ),
        NumeroPIN(
          outlineInputBorder: bordeExteriorEntrada,
          textEditingController: controlPinTres,
        ),
        NumeroPIN(
          outlineInputBorder: bordeExteriorEntrada,
          textEditingController: controlPinCuatro,
        )
      ],
    );
  }

  construirPanelNumerico() {
    return Expanded(
        child: Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TeclaNumerica(
                          numero: 1,
                          onPressed: () {
                            gestionarNotificacion(pinIndexSetup('1', persona));
                          },
                        ),
                        TeclaNumerica(
                          numero: 2,
                          onPressed: () {
                            gestionarNotificacion(pinIndexSetup('2', persona));
                          },
                        ),
                        TeclaNumerica(
                          numero: 3,
                          onPressed: () {
                            gestionarNotificacion(pinIndexSetup('3', persona));
                          },
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TeclaNumerica(
                          numero: 4,
                          onPressed: () {
                            gestionarNotificacion(pinIndexSetup('4', persona));
                          },
                        ),
                        TeclaNumerica(
                          numero: 5,
                          onPressed: () {
                            gestionarNotificacion(pinIndexSetup('5', persona));
                          },
                        ),
                        TeclaNumerica(
                          numero: 6,
                          onPressed: () {
                            gestionarNotificacion(pinIndexSetup('6', persona));
                          },
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TeclaNumerica(
                          numero: 7,
                          onPressed: () {
                            gestionarNotificacion(pinIndexSetup('7', persona));
                          },
                        ),
                        TeclaNumerica(
                          numero: 8,
                          onPressed: () {
                            gestionarNotificacion(pinIndexSetup('8', persona));
                          },
                        ),
                        TeclaNumerica(
                          numero: 9,
                          onPressed: () {
                            gestionarNotificacion(pinIndexSetup('9', persona));
                          },
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          width: 60.0,
                          child: MaterialButton(
                            onPressed: null,
                            child: SizedBox(),
                          ),
                        ),
                        TeclaNumerica(
                          numero: 0,
                          onPressed: () {
                            gestionarNotificacion(pinIndexSetup('0', persona));
                          },
                        ),
                        Container(
                          width: 60.0,
                          child: MaterialButton(
                              height: 60.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60.0),
                              ),
                              onPressed: () {
                                removeLastPin();
                              },
                              child: Icon(Icons.backspace, size: 36)),
                        )
                      ],
                    )
                  ],
                ))));
  }

  int gestionarNotificacion(int resultado) {
    int _resultado = resultado;
    if (resultado < 0) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            Future.delayed(Duration(seconds: 2), () {
              Navigator.of(context).pop(true);
            });
            return Notificacion(
                tipo: 1,
                titulo: 'Error',
                mensaje: 'PIN Incorrecto. Vuelta a intentarlo.');
          });
      clearPin();
    }
    return _resultado;
  }

  int pinIndexSetup(String text, Persona persona) {
    int resultado = 0;
    print('Indice actual: $pinIndex');
    if (pinIndex == 0) {
      pinIndex = 1;
    } else if (pinIndex < 4) {
      pinIndex++;
    }

    setPin(pinIndex, text);
    pinActual[pinIndex - 1] = text;
    String strPin = '';
    pinActual.forEach((e) {
      strPin += e;
    });
    if (pinIndex == 4) {
      print('Pin introducido: $strPin');
      if (persona.password == strPin) {
        print('Pin correcto');
        resultado = 1;
        cerrarPinCode(true);
      } else {
        print('Pin incorrecto');
        resultado = -1;
      }
    }
    return resultado;
  }

  removeLastPin() {
    print('removeLastPin inicio -> Indice actual: $pinIndex');
    if (pinIndex == 0) {
      pinIndex = 0;
    } else if (pinIndex <= 4) {
      setPin(pinIndex, '');
      pinActual[pinIndex - 1] = '';
      pinIndex--;
    } else {
      setPin(pinIndex, '');
      pinActual[pinIndex - 1] = '';
    }
    print('removeLastPin fin -> Indice actual: $pinIndex');
  }

  clearPin() {
    int i = 4;
    for (i = 4; i > 0; i--) {
      setPin(i, '');
      pinActual[i - 1] = '';
    }
    pinIndex = 0;
  }

  setPin(int n, String text) {
    switch (n) {
      case 1:
        controlPinUno.text = text;
        break;
      case 2:
        controlPinDos.text = text;
        break;
      case 3:
        controlPinTres.text = text;
        break;
      case 4:
        controlPinCuatro.text = text;
        break;
    }
    print('Pin introducido -> pos: $n, valor: $text');
  }
}

class NumeroPIN extends StatelessWidget {
  final TextEditingController textEditingController;
  final OutlineInputBorder outlineInputBorder;

  NumeroPIN({this.textEditingController, this.outlineInputBorder});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      child: TextField(
          controller: textEditingController,
          enabled: false,
          obscureText: true,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(16.0),
            border: outlineInputBorder,
            filled: true,
            fillColor: Colors.white30,
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21.0,
            color: Colors.white,
          )),
    );
  }
}

class TeclaNumerica extends StatelessWidget {
  final int numero;
  final Function() onPressed;
  TeclaNumerica({this.numero, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.0,
      height: 70.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.lightGreen[50].withOpacity(0.5),
      ),
      alignment: Alignment.center,
      child: MaterialButton(
        padding: EdgeInsets.all((8.0)),
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        height: 90.0,
        child: Text('$numero',
            textAlign: TextAlign.center, style: Styles.defaultText),
      ),
    );
  }
}
