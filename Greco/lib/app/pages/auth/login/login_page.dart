import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/app/pages/auth/login/login_vm.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/router/router.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/widgets/widgets.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  // final _usernameController =
  //     TextEditingController(text: "nongdangreco@gmail.com");
  // final _passwordController = TextEditingController(text: "123456");
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _willSaved = true;

  final _vm = LoginVM();
  final _rxBag = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    _bindViewModel();
  }

  @override
  void dispose() {
    super.dispose();
    _rxBag.dispose();
    _vm.dispose();
  }

  void _bindViewModel() {
    _vm.output.response.listen((response) async {
      var (credential, user) = response;
      await Session.startAuthenticatedSession(credential, user);
      context.router.replaceAll([const HomeRoute()]);
    }).addTo(_rxBag);

    _vm.output.prevLoginInfo.listen((info) {
      var (username, password, willSave) = info;

      setState(() {
        _usernameController.text = username;
        _passwordController.text = password;
        _willSaved = willSave;
      });
    }).addTo(_rxBag);

    _vm.input.reload.add(null);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      error: _vm.errorTracker.asAppError(),
      isLoading: _vm.activityTracker.isRunningAny(),
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _headerWidget()),
            _fieldsContainerWidget(),
          ],
        ),
      ),
    );
  }

  Widget _headerWidget() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/img_login_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
              child: Image.asset(
            'images/ic_logo.png',
            width: 180,
            fit: BoxFit.fitWidth,
          )),
        ),
        Positioned.fill(
          top: null,
          child: Container(
            height: 32,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldsContainerWidget() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        child: Form(
          key: _formKey,
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Đăng nhập",
                style: AppTheme.textStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 16),
              _usernameField(),
              const SizedBox(height: 8),
              _passwordField(),
              const SizedBox(height: 16),
              _loginButton(),
              const SizedBox(height: 8),
              _saveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Container _loginButton() {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: TextButton(
        onPressed: () {
          if (_formKey.currentState?.validate() == true) {
            _vm.input.login.add((
              _usernameController.text,
              _passwordController.text,
              _willSaved,
            ));
          }
        },
        child: Text(
          "Đăng nhập",
          style: AppTheme.textStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return SecuredField(
      controller: _passwordController,
      icon: const Icon(Icons.lock, size: 20),
      hintText: "Mật khẩu",
      validator: (value) {
        int length = value?.length ?? 0;
        if (length < 6) {
          return "Mật khẩu phải có ít nhất 6 ký tự";
        }
        return null;
      },
    );
  }

  Widget _usernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person, size: 20),
        hintText: "Tài khoản",
      ),
      validator: (value) {
        if (value?.isNotEmpty ?? false) {
          return null;
        }
        return "Nhập số điện thoại hoặc email";
      },
    );
  }

  Widget _saveButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _willSaved = !_willSaved;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
            value: _willSaved,
            onChanged: null,
          ),
          Text(
            'Lưu thông tin đăng nhập',
            style: AppTheme.textStyle(
              color: AppTheme.primaryColor,
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }
}
