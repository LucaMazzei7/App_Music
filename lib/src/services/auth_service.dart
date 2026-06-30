import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Imports para poder usar Firebase
class AuthService {
  //Clase para la logica de autenticación
  final FirebaseAuth _auth = FirebaseAuth
      .instance; //Variable privada para usar Firebase Authentication
  final FirebaseFirestore _db =
      FirebaseFirestore.instance; //Nuestra base de datos

  Future<void> registrarUsuario({
    required String nombre,
    required String email,
    required String password,
    required String genero,
    required DateTime fechaNacimiento, //Datos que necesita recibir la funcion
  }) async {
    //Esto tarda, por lo que lo hacemos asincrono, para esperar que termine la operacion
    final credencial = await _auth.createUserWithEmailAndPassword(
      //Creamos la credencial que va ser = __auth, funcion de firebase
      email: email.trim(),
      password: password
          .trim(), //. trim() elimina los espacios en blanco al principio y al final
    );

    final uid = credencial
        .user!
        .uid; //Al guardar el usuario firebase genera un id unico, con esta funcion la obtenemos. el ! para asegurarse que no este vacio

    await _db.collection('usuarios').doc(uid).set({
      // collection'usuarios' , entra/crea la coleccion de usuarios
      'uid': uid,
      'nombre': nombre.trim(),
      'email': email.trim(),
      'genero': genero,
      'fechaNacimiento': Timestamp.fromDate(
        fechaNacimiento,
      ), //Cambiamos el datetime de flutter para que lo lea Firebase, ya que se guardan de diferentes maneras
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena.trim(),
      );
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }
}
