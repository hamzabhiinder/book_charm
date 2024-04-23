// import 'package:book_charm/screens/authentication/services/auth1/auth_user.dart';

// import 'auth_providor.dart';
// import 'firebase_auth_provider1.dart';

// class AuthService implements AuthProvider {
//   final FirebaseAuthProvider provider;
//   const AuthService(this.provider);

//   factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

//   @override
//   Future<AuthUser> createUser({
//     required String email,
//     required String password,
//   }) =>
//       provider.createUser(
//         email: email,
//         password: password,
//       );

//   @override
//   AuthUser? get currentUser => provider.currentUser;

//   @override
//   Future<AuthUser> logIn({
//     required String email,
//     required String password,
//   }) =>
//       provider.logIn(
//         email: email,
//         password: password,
//       );
//   @override
//   Future<void> logOut() => provider.logOut();

//   @override
//   Future<void> sendEmailVerification() => provider.sendEmailVerification();

//   @override
//   Future<void> initialize() => provider.initialize();

//   @override
//   Future<void> sendPasswordReset({required String toEmail}) =>
//       provider.sendPasswordReset(toEmail: toEmail);
// }
