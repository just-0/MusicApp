class Validations {
  static String? validateName(String? value) {
    if (value!.isEmpty) return 'Se requiere nombre de Usuario.';
    final RegExp nameExp = new RegExp(r'^[A-za-zğüşöçİĞÜŞÖÇ ]+$');
    if (!nameExp.hasMatch(value))
      return 'Sólo carácteres alfabéticos';
  }

  static String? validateEmail(String? value, [bool isRequried = true]) {
    if (value!.isEmpty && isRequried) return 'Se requiere una dirección de correo electrónico';
    final RegExp nameExp = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!nameExp.hasMatch(value) && isRequried)
      return 'Dirección de Corre Electrónico Invalido.';
  }

  static String? validatePassword(String? value) {
    if (value!.isEmpty || value.length < 6)
      return 'Por favor ingresar una contraseña valida.';
  }
}
