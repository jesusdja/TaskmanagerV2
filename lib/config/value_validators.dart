import 'package:flutter/cupertino.dart';

Map<String, dynamic> validateUserAddress(String input,BuildContext context) {

  Map<String, dynamic> result = {'valid' : false, 'sms' : 'No es valido.'};
  const emailRegex = r"""^[a-zA-Z]+""";
  const userRegex = ""r'^[a-zA-Z0-9]+$'"";
  if (RegExp(emailRegex).hasMatch(input)) {
    if (input.length > 4){
      if(RegExp(userRegex).hasMatch(input)){
        result['valid'] = true;
        result['sms'] = 'valido';
        return result;
      }else{
        result['valid'] = false;
        result['sms'] = "Solo se permiten letras y numeros.";
        return result;
      }
    }else{
      result['valid'] = false;
      result['sms'] = "Usuario debe contener mas de 5 caracteres.";
      return result;
    }
  } else {
    result['valid'] = false;
    result['sms'] = 'Usuario invalido. Debe comenzar con una letra.';
    return result;
  }
}

Map<String, dynamic> validateEmailAddress({required String email}) {
  Map<String, dynamic> result = {'valid' : false, 'sms' : 'No es valido.'};
  const emailRegex =
  r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
  if (RegExp(emailRegex).hasMatch(email)) {
    result['valid'] = true;
    result['sms'] = 'Correo valido.';
    return result;
  } else {
    result['valid'] = false;
    result['sms'] = 'Formato de correo inválido';
    return result;
  }
}


Map<String, dynamic> validatePassword(String input,BuildContext context) {
  Map<String, dynamic> result = {'valid' : false, 'sms' : 'No es valido.'};
  // String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$';
  String oneNumber = r'^.*[0-9].*$';
  String oneLowerCase = r'^.*[a-z].*$';
  String oneUpperCase = r'^.*[A-Z].*$';
  if (input.length < 8) {
    result['valid'] = false;
    result['sms'] = "Usá mínimo 8 caracteres";
    return result;
  } else if (!RegExp(oneNumber).hasMatch(input)) {
    result['valid'] = false;
    result['sms'] = "Debe contener al menos un número";
    return result;
  } else if (!RegExp(oneLowerCase).hasMatch(input)) {
    result['valid'] = false;
    result['sms'] = "Debe contener al menor una minúscula";
    return result;
  } else if (!RegExp(oneUpperCase).hasMatch(input)) {
    result['valid'] = false;
    result['sms'] = "Debe contener al menos una mayúscula";
    return result;
  }
  result['valid'] = true;
  result['sms'] = 'valido.';
  return result;
}