import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nomeet/index_screen.dart';
import 'package:location/location.dart';
import 'package:nomeet/selfie_screen.dart';

enum LoadingState {
  LOADING,
  ERROR,
  NOT_LOADING
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  static Dio dio = Dio(BaseOptions(
    validateStatus: (_) => true
  ));

  static String username, password;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nomeet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  LoadingState loadingState = LoadingState.NOT_LOADING;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String errorStr = '';
  String lat = '';
  String lng = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    _locationData = await location.getLocation();
    lat = '${_locationData.latitude}';
    lng = '${_locationData.longitude}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'nomeet',
            ),
            Text(
              errorStr,
              style: TextStyle(color: Colors.red),
            ),
            TextFormField(
              controller: usernameController,
              validator: (v) {
                if(v.toUpperCase() != v.toLowerCase()) {
                  return v;
                } return '';
              },
              decoration: InputDecoration(
                hintText: 'username'
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'password',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: loadingState == LoadingState.LOADING ? [CircularProgressIndicator()] :
              <Widget>[
                OutlineButton(
                  child: Text('login'),
                  onPressed: () async {
                    setState(() {
                      loadingState = LoadingState.LOADING;
                    });
                    try {
                      Map<String, String> formData = {
                        'username' : usernameController.text,
                        'password' : passwordController.text,
                      };
                      debugPrint('test login');
                      Response res = await MyApp.dio.post('http://10.0.2.2:5000/login', data: FormData.fromMap(formData));
                      debugPrint('signup received: ${res.data}');
                      if(res.data ['success'] == true) {
                        debugPrint('yay');
                        MyApp.username = usernameController.text;
                        MyApp.password = passwordController.text;
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => IndexScreen()));
                      } else {
                        debugPrint('fuck');
                        setState(() {
                          loadingState = LoadingState.ERROR;
                          errorStr = 'try a new password';
                        });
                      }
                    } catch(e) {
                      setState(() {
                        loadingState = LoadingState.ERROR;
                      });
                    }
                  },
                ),
                OutlineButton(
                  child: Text('sign up'),
                  onPressed: () async {
                    try {
                      setState(() {
                        loadingState = LoadingState.LOADING;
                      });
                      Map<String, String> formData = {
                        'username' : usernameController.text,
                        'password' : passwordController.text,
                        'name' : '',
                        'lat' : lat,
                        'lng' : lng
                      };
                      debugPrint('sigining up sending: $formData}');
                      Response res = await MyApp.dio.post('http://10.0.2.2:5000/signup', data: FormData.fromMap(formData));
                      debugPrint('signup received: ${res.data}');
                      if(res.data['success'] == true) {
                        debugPrint('yay');
                        MyApp.username = usernameController.text;
                        MyApp.password = passwordController.text;
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SelfieScreen()));
                      } else {
                        debugPrint('fuck');
                        setState(() {
                          loadingState = LoadingState.ERROR;
                          errorStr = 'error';
                        });
                      }
                    } catch(e) {
                      setState(() {
                        loadingState = LoadingState.ERROR;
                      });
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
