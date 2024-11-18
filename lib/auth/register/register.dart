import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:chivero/components/password_text_field.dart';
import 'package:chivero/components/text_form_builder.dart';
import 'package:chivero/utils/validation.dart';
import 'package:chivero/view_models/auth/register_view_model.dart';
import 'package:chivero/widgets/indicators.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String _userType = 'Musico'; // Valor predeterminado para el tipo de usuario

  @override
  Widget build(BuildContext context) {
    RegisterViewModel viewModel = Provider.of<RegisterViewModel>(context);
    return LoadingOverlay(
      progressIndicator: circularProgress(context),
      isLoading: viewModel.loading,
      child: Scaffold(
        key: viewModel.scaffoldKey,
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 10),
            Text(
              'Bienvenido a ChiveroApp!!!\nLa aplicación para encontrar músicos',
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            SizedBox(height: 30.0),
            buildForm(viewModel, context),
            SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿Ya tiene una cuenta?  '),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  buildForm(RegisterViewModel viewModel, BuildContext context) {
    return Form(
      key: viewModel.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _userType,
            items: [
              DropdownMenuItem(
                child: Text("Músico"),
                value: 'Musico',
              ),
              DropdownMenuItem(
                child: Text("Contratista"),
                value: 'Contratista',
              ),
            ],
            onChanged: (String? newValue) {
              setState(() {
                _userType = newValue!;
              });
            },
            onSaved: (String? value) {
              viewModel.setUserType(value ?? 'Musico');
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Ionicons.person_outline),
              hintText: "Tipo de usuario",
            ),
          ),
          SizedBox(height: 20.0),
          TextFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.person_outline,
            hintText: "Nombre de Usuario",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateName,
            onSaved: (String val) {
              viewModel.setName(val);
            },
            focusNode: viewModel.usernameFN,
            nextFocusNode: viewModel.emailFN,
          ),
          SizedBox(height: 20.0),
          TextFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.mail_outline,
            hintText: "Correo Electrónico",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateEmail,
            onSaved: (String val) {
              viewModel.setEmail(val);
            },
            focusNode: viewModel.emailFN,
            nextFocusNode: viewModel.countryFN,
          ),
          SizedBox(height: 20.0),
                    TextFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.pin_outline,
            hintText: "País",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateName,
            onSaved: (String val) {
              viewModel.setCountry(val);
            },
            focusNode: viewModel.countryFN, // Focus para País
            nextFocusNode: viewModel.cityFN, // Focus al siguiente campo (Ciudad)
          ),
          SizedBox(height: 20.0),
          TextFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.pin_outline,
            hintText: "Ciudad",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validateName,
            onSaved: (String val) {
              viewModel.setCity(val);
            },
            focusNode: viewModel.cityFN, // Focus para Ciudad
            nextFocusNode: viewModel.districtFN, // Focus al siguiente campo (Distrito)
          ),
          SizedBox(height: 20.0),
          TextFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.pin_outline,
            hintText: "Distrito",
            textInputAction: TextInputAction.done,
            validateFunction: Validations.validateName,
            onSaved: (String val) {
              viewModel.setDistrict(val);
            },
            focusNode: viewModel.districtFN, // Focus para Distrito
            nextFocusNode: null, // No hay siguiente campo después de Distrito
          ),

          if (_userType == 'Musico') ...[
            SizedBox(height: 20.0),
            DropdownButtonFormField<String>(
              items: [
                DropdownMenuItem(child: Text("Guitarra"), value: 'Guitarra'),
                DropdownMenuItem(child: Text("Piano"), value: 'Piano'),
                DropdownMenuItem(child: Text("Batería"), value: 'Batería'),
                DropdownMenuItem(child: Text("Violín"), value: 'Violín'),
              ],
              onChanged: (String? value) {
                setState(() {
                  viewModel.setInstrument(value!);
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Ionicons.musical_note_outline),
                hintText: "Selecciona tu instrumento",
              ),
            ),
            SizedBox(height: 20.0),
            TextFormBuilder(
              enabled: !viewModel.loading,
              prefix: Ionicons.school_outline,
              hintText: "Lugar de estudio",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateName,
              onSaved: (String val) {
                viewModel.setStudyPlace(val);
              },
            ),
          ],
          if (_userType == 'Contratista') ...[
            SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Selecciona los tipos de eventos:"),
                CheckboxListTile(
                  value: viewModel.eventTypes.contains('Bodas'),
                  title: Text("Bodas"),
                  onChanged: (bool? value) {
                    setState(() {
                      viewModel.toggleEventType('Bodas');
                    });
                  },
                ),
                CheckboxListTile(
                  value: viewModel.eventTypes.contains('Tocadas'),
                  title: Text("Tocadas"),
                  onChanged: (bool? value) {
                    setState(() {
                      viewModel.toggleEventType('Tocadas');
                    });
                  },
                ),
                CheckboxListTile(
                  value: viewModel.eventTypes.contains('Conciertos Sinfónicos'),
                  title: Text("Conciertos Sinfónicos"),
                  onChanged: (bool? value) {
                    setState(() {
                      viewModel.toggleEventType('Conciertos Sinfónicos');
                    });
                  },
                ),
              ],
            ),
          ],
          SizedBox(height: 20.0),
          PasswordFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.lock_closed_outline,
            suffix: Ionicons.eye_outline,
            hintText: "Contraseña",
            textInputAction: TextInputAction.next,
            validateFunction: Validations.validatePassword,
            obscureText: true,
            onSaved: (String val) {
              viewModel.setPassword(val);
            },
            focusNode: viewModel.passFN,
            nextFocusNode: viewModel.cPassFN,
          ),
          SizedBox(height: 20.0),
          PasswordFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.lock_open_outline,
            hintText: "Confirmar Contraseña",
            textInputAction: TextInputAction.done,
            validateFunction: Validations.validatePassword,
            submitAction: () => viewModel.register(context),
            obscureText: true,
            onSaved: (String val) {
              viewModel.setConfirmPass(val);
            },
            focusNode: viewModel.cPassFN,
          ),
          SizedBox(height: 25.0),
          Container(
            height: 45.0,
            width: 180.0,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.secondary),
              ),
              child: Text(
                'Registrarse'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => viewModel.register(context),
            ),
          ),
        ],
      ),
    );
  }
}
