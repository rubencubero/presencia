import 'package:presencia/classes/persona.dart';
import '../classes/http.dart';

class MockPersonas extends Persona {
  static final List<Persona> personas = [];

  static Future<List<Persona>> getPersonas() async {
    try {
      personas.clear();
      var result = await httpGet('personas/75');
      if (result.ok) {
        var listaPersonas = result.data as List<dynamic>;
        listaPersonas.forEach((persona) {
          personas.add(Persona(
              id: persona['id'].toString(),
              idTarjeta: persona['idtarjeta'].toString(),
              descripcion: persona['descri'].toString(),
              password: persona['pwd'].toString()));
        });
      }
    } catch (e) {
      print(e);
    }

    return personas;
  }

  static Persona encontrarPersonaIdTarjeta(
      List<Persona> listaPersonas, String idTarjeta) {
    return listaPersonas.firstWhere((p) => p.idTarjeta == idTarjeta,
        orElse: () {
      return null;
    });
  }
}
